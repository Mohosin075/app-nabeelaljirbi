import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/appointment/model/doctor_appointment_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DoctorAppointmentController extends GetxController {
  // 0: Pending, 1: Confirmed, 2: Arrived, 3: In Progress, 4: Completed, 5: No Show, 6: Cancelled
  var selectedTab = 0.obs;
  var selectedDate = Rxn<DateTime>();
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var allAppointments = <Appointment>[].obs;
  final ScrollController scrollController = ScrollController();

  // Pagination Variables
  var currentPage = 1;
  var hasNextPage = true.obs;
  final int limit = 20;

  WebSocketChannel? _wsChannel;
  Timer? _periodicTimer;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    getDoctorAppointments();
    _connectWebSocket();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _wsChannel?.sink.close();
    _periodicTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      getDoctorAppointments(silent: true);
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
            getDoctorAppointments(silent: true);
          }
        } catch (_) {}
      }, onError: (_) {});
    } catch (_) {}
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (hasNextPage.value && !isMoreLoading.value && !isLoading.value) {
        getDoctorAppointments(isLoadMore: true);
      }
    }
  }

  void selectTab(int index) {
    if (selectedTab.value != index) {
      selectedTab.value = index;
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    }
  }

  void selectDate(DateTime? date) {
    selectedDate.value = date;
    getDoctorAppointments();
  }

  List<Appointment> get filteredAppointments {
    return allAppointments.where((apt) {
      final status = apt.status?.toUpperCase() ?? 'PENDING';
      bool matchesStatus = false;

      switch (selectedTab.value) {
        case 0: // Pending
          matchesStatus = status == 'PENDING';
          break;
        case 1: // Confirmed
          matchesStatus = status == 'CONFIRMED';
          break;
        case 2: // Arrived
          matchesStatus = status == 'ARRIVED';
          break;
        case 3: // In Progress
          matchesStatus = status == 'INPROGRESS';
          break;
        case 4: // Completed
          matchesStatus = status == 'COMPLETE' || status == 'COMPLETED';
          break;
        case 5: // No Show
          matchesStatus = status == 'NOT_SHOW' ||
              status == 'NOTSHOWN' ||
              status == 'NOT_SHOWN' ||
              status == 'NO_SHOW';
          break;
        case 6: // Cancelled / Rejected
          matchesStatus = status == 'CANCELLED' || status == 'REJECTED';
          break;
        default:
          matchesStatus = true;
      }

      if (!matchesStatus) return false;

      if (selectedDate.value != null && apt.consultDate != null) {
        try {
          DateTime aptDate = DateTime.parse(apt.consultDate!);
          return aptDate.year == selectedDate.value!.year &&
              aptDate.month == selectedDate.value!.month &&
              aptDate.day == selectedDate.value!.day;
        } catch (e) {
          debugPrint('Error parsing date: $e');
        }
      }
      return true;
    }).toList();
  }

  Future<void> getDoctorAppointments({
    bool isLoadMore = false,
    bool silent = false,
  }) async {
    if (isLoadMore) {
      if (isMoreLoading.value || !hasNextPage.value) return;
      isMoreLoading.value = true;
    } else {
      if (!silent) {
        isLoading.value = true;
      }
      currentPage = 1;
      hasNextPage.value = true;
    }

    try {
      final token = SharedPrefHelper.getAccessToken();
      String url =
          '${Urls.baseUrl}/doctor/appointments?page=$currentPage&limit=$limit';

      if (selectedDate.value != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
        url = '$url&consultDate=$dateStr';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final model = DoctorAppointmentModel.fromJson(body);

        if (model.success == true &&
            model.data != null &&
            model.data!.data != null) {
          if (isLoadMore) {
            allAppointments.addAll(model.data!.data!);
          } else {
            allAppointments.assignAll(model.data!.data!);
          }

          final meta = model.data!.meta;
          if (meta != null) {
            final total = meta.total ?? 0;
            if (allAppointments.length >= total) {
              hasNextPage.value = false;
            } else {
              hasNextPage.value = true;
              currentPage++;
            }
          } else {
            hasNextPage.value = false;
          }
        }
      } else {
        debugPrint('Failed to fetch doctor appointments: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching doctor appointments: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

) async {
    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/clinic/update/appointment-status';

      final Map<String, dynamic> body = {
        'bookingId': bookingId,
        'status': status,
      };
      if (reason != null && reason.trim().isNotEmpty) {
        body['reason'] = reason.trim();
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          'status_updated_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        await getDoctorAppointments();
      } else {
        final resData = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          resData['message'] ?? 'failed_to_update_status'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }
}
