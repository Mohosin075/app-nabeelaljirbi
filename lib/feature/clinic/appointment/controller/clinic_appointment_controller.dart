import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import '../../home/model/appointment_model.dart';
import '../../home/model/booking_history_model.dart';

import '../../doctors/controller/clinic_doctor_controller.dart';

class ClinicAppointmentController extends GetxController {
  final RxString selectedTab = 'pending'.obs;
  final RxString selectedDoctor = 'all_doctors'.obs;
  final RxnString selectedDoctorId = RxnString();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  // Use the doctors from ClinicDoctorController
  final ClinicDoctorController _doctorController =
      Get.find<ClinicDoctorController>();

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
    'completed',
    'cancelled',
    'unresolved',
  ];

  List<String> get doctorNames {
    return [
      'all_doctors',
      ..._doctorController.doctors.map((d) => d.name ?? ''),
    ];
  }

  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookingHistory();
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
      case 'completed':
        return ['COMPLETE'];
      case 'cancelled':
        return ['CANCELLED'];
      case 'unresolved':
        return ['NOT_UPDATED', 'NOT_SHOW'];
      default:
        return ['PENDING'];
    }
  }

  /// Format date as YYYY-MM-DD for API
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchBookingHistory({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
      currentPage.value++;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
      allAppointments.clear();
      hasMore.value = true;
    }

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final statuses = _getApiStatuses(selectedTab.value);

      final List<AppointmentModel> combinedAppointments = [];
      int combinedTotal = 0;
      bool anyHasMore = false;

      for (final status in statuses) {
        // Build URL with optional filters
        var url =
            '${Urls.baseUrl}/clinic/booking-history?status=$status&page=${currentPage.value}&limit=$itemsPerPage';

        if (selectedDoctorId.value != null) {
          url += '&doctorId=${selectedDoctorId.value}';
        }

        // Only add date parameter if date filter is applied
        if (selectedDate.value != null) {
          final dateStr = _formatDateForApi(selectedDate.value!);
          url += '&consultDate=$dateStr';
        }

        debugPrint('Booking History Request URL: $url');

        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': token},
        );

        debugPrint('Booking History Status Code: ${response.statusCode}');
        debugPrint('Booking History Response Body: ${response.body}');

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

      // Update pagination info
      totalItems.value = combinedTotal;
      totalPages.value = (combinedTotal / itemsPerPage).ceil();
      hasMore.value = anyHasMore;
    } catch (e) {
      debugPrint('Error fetching booking history: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  List<AppointmentModel> get filteredAppointments {
    // Since we fetch by status from API, just return all
    return allAppointments;
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
    fetchBookingHistory(); // Re-fetch when tab changes
  }

  void changeDoctor(String? doctorName) {
    if (doctorName == null) return;
    selectedDoctor.value = doctorName;

    if (doctorName == 'all_doctors') {
      selectedDoctorId.value = null;
    } else {
      // Find doctor ID by name
      try {
        final doc = _doctorController.doctors.firstWhere(
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
    fetchBookingHistory(); // Re-fetch when date changes
  }

  void clearDateFilter() {
    selectedDate.value = null;
    fetchBookingHistory(); // Re-fetch when date filter is cleared
  }

  Future<void> updateAppointmentStatus(String bookingId, String status) async {
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/update/appointment-status';

      final body = {'bookingId': bookingId, 'status': status};
      debugPrint('Updating Appointment: $url');
      debugPrint('Body: $body');

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Update Status Code: ${response.statusCode}');
      debugPrint('Update Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'success'.tr,
            data['message'] ?? 'status_updated_successfully'.tr,
            backgroundColor: AppColors.primaryColor,
            colorText: Colors.white,
          );
          fetchBookingHistory(); // Refresh list
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
