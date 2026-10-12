import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../home/model/appointment_model.dart';
import '../../home/model/booking_history_model.dart';
import '../../doctors/controller/clinic_doctor_controller.dart';

class ClinicAppointmentController extends GetxController {
  final RxString selectedTab = 'pending'.obs;
  final RxString selectedDoctor = 'all_doctors'.obs;
  final RxnString selectedDoctorId = RxnString();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  // Use the doctors from ClinicDoctorController if registered
  ClinicDoctorController? _doctorController;

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;

  final int itemsPerPage = 20;

  final List<String> tabs = [
    'pending',
    'confirmed',
    'arrived',
    'in_progress',
    'completed',
    'no_show',
    'cancelled',
  ];

  List<String> get doctorNames {
    if (_doctorController == null) return ['all_doctors'];
    return [
      'all_doctors',
      ..._doctorController!.doctors.map((d) => d.name ?? ''),
    ];
  }

  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  WebSocketChannel? _wsChannel;
  Timer? _periodicTimer;

  @override
  void onInit() {
    super.onInit();
    try {
      _doctorController = Get.find<ClinicDoctorController>();
    } catch (_) {
      // ClinicDoctorController might not be initialized yet
    }
    fetchBookingHistory();
    _connectWebSocket();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _wsChannel?.sink.close();
    _periodicTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    // 15-second background sync fallback
    _periodicTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchBookingHistory(silent: true);
    });
  }

  void _connectWebSocket() {
    try {
      final token = SharedPrefHelper.getAccessToken();
      if (token == null || token.isEmpty) return;

      final wsUrl = Urls.baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://')
          .replaceFirst('/api/v1', '/ws/?token=$token');

      _wsChannel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      _wsChannel?.stream.listen((message) {
        try {
          final data = jsonDecode(message);
          if (data['type'] == 'BOOKING_STATUS_CHANGED' ||
              data['type'] == 'NEW_BOOKING_REQUEST' ||
              data['type'] == 'BOOKING_CANCELLED') {
            fetchBookingHistory(silent: true);
          }
        } catch (_) {}
      }, onError: (_) {});
    } catch (_) {}
  }

  /// Convert tab name to API status values
  List<String> _getApiStatuses(String tab) {
    switch (tab) {
      case 'pending':
        return ['PENDING'];
      case 'confirmed':
        return ['CONFIRMED'];
      case 'arrived':
        return ['ARRIVED'];
      case 'in_progress':
        return ['INPROGRESS'];
      case 'completed':
        return ['COMPLETE'];
      case 'no_show':
        return ['NOT_SHOW'];
      case 'cancelled':
        return ['CANCELLED', 'REJECTED'];
      default:
        return ['PENDING'];
    }
  }

  /// Format date as YYYY-MM-DD for API
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchBookingHistory({
    bool loadMore = false,
    bool silent = false,
  }) async {
    if (loadMore) {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
      currentPage.value++;
    } else {
      if (!silent) {
        isLoading.value = true;
      }
      currentPage.value = 1;
      if (!silent) {
        allAppointments.clear();
      }
      hasMore.value = true;
    }

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final statuses = _getApiStatuses(selectedTab.value);

      final List<AppointmentModel> combinedAppointments = [];
      int combinedTotal = 0;
      bool anyHasMore = false;

      for (final status in statuses) {
        var url =
            '${Urls.baseUrl}/clinic/booking-history?status=$status&page=${currentPage.value}&limit=$itemsPerPage';

        if (selectedDoctorId.value != null) {
          url += '&doctorId=${selectedDoctorId.value}';
        }

        if (selectedDate.value != null) {
          final dateStr = _formatDateForApi(selectedDate.value!);
          url += '&consultDate=$dateStr';
        }

        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': token},
        );

        if (response.statusCode == 200) {
          final parsedResponse = BookingHistoryResponse.fromJson(
            jsonDecode(response.body),
          );

          if (parsedResponse.success && parsedResponse.data != null) {
            final newAppointments = parsedResponse.data!.data
                .map((item) => item.toAppointmentModel())
                .toList();

            combinedAppointments.addAll(newAppointments);

            final meta = parsedResponse.data!.meta;
            combinedTotal += meta.total;

            final totalPagesForStatus = (meta.total / meta.limit).ceil();
            if (currentPage.value < totalPagesForStatus) {
              anyHasMore = true;
            }
          }
        }
      }

      if (loadMore) {
        allAppointments.addAll(combinedAppointments);
      } else {
        allAppointments.assignAll(combinedAppointments);
      }

      totalItems.value = combinedTotal;
      totalPages.value = (combinedTotal / itemsPerPage).ceil();
      hasMore.value = anyHasMore;
    } catch (e) {
      debugPrint('Error fetching clinic booking history: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  List<AppointmentModel> get filteredAppointments {
    return allAppointments;
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    fetchBookingHistory();
  }

  void changeDoctor(String? doctorName) {
    if (doctorName == null) return;
    selectedDoctor.value = doctorName;

    if (doctorName == 'all_doctors' || _doctorController == null) {
      selectedDoctorId.value = null;
    } else {
      try {
        final doc = _doctorController!.doctors.firstWhere(
          (d) => d.name == doctorName,
        );
        selectedDoctorId.value = doc.doctorId;
      } catch (e) {
        selectedDoctorId.value = null;
      }
    }
    fetchBookingHistory();
  }

  void selectDate(DateTime? date) {
    selectedDate.value = date;
    fetchBookingHistory();
  }

  void clearDateFilter() {
    selectedDate.value = null;
    fetchBookingHistory();
  }

  Future<void> updateAppointmentStatus(
    String bookingId,
    String status, {
    String? reason,
  }) async {
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/update/appointment-status';

      final Map<String, dynamic> body = {
        'bookingId': bookingId,
        'status': status,
      };
      if (reason != null && reason.trim().isNotEmpty) {
        body['reason'] = reason.trim();
      }

      debugPrint('Updating Appointment: $url with body: $body');

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Update Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'success'.tr,
            data['message'] ?? 'status_updated_successfully'.tr,
            backgroundColor: AppColors.primaryColor,
            colorText: Colors.white,
          );
          fetchBookingHistory();
        } else {
          Get.snackbar(
            'error'.tr,
            data['message'] ?? 'failed_to_update_status'.tr,
          );
        }
      } else {
        Get.snackbar('error'.tr, 'failed_to_update_status'.tr);
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    }
  }

  void loadMoreAppointments() {
    fetchBookingHistory(loadMore: true);
  }

  Future<void> refreshData() async {
    await fetchBookingHistory();
  }
}
