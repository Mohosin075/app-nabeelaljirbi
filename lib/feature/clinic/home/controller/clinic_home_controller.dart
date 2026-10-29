import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import '../model/appointment_model.dart';
import '../model/booking_history_model.dart';
import '../../doctors/controller/clinic_doctor_controller.dart';

class ClinicHomeController extends GetxController {
  final Rx<ClinicStatsModel> stats = ClinicStatsModel(
    doctorCount: 0,
    todayAppointment: 0,
    pendingAppointment: 0,
  ).obs;

  var isLoadingStats = false.obs;
  var isLoadingAppointments = false.obs;

  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  final RxString selectedTab = 'pending'.obs;
  final selectedDate = DateTime.now().obs;
  final RxString selectedDoctor = 'all_doctors'.obs;
  final RxnString selectedDoctorId = RxnString();

  // Use the doctors from ClinicDoctorController
  final ClinicDoctorController _doctorController =
      Get.find<ClinicDoctorController>();

  List<String> get doctorNames {
    return [
      'all_doctors',
      ..._doctorController.doctors.map((d) => d.name ?? ''),
    ];
  }

  final List<String> tabs = [
    'pending',
    'confirmed',
    'arrived',
    'completed',
    'cancelled',
    'unresolved',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchClinicStats();
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

  Future<void> fetchClinicStats() async {
    isLoadingStats.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/stats';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint('Clinic Stats Status Code: ${response.statusCode}');
      debugPrint('Clinic Stats Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          stats.value = ClinicStatsModel.fromJson(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching clinic stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> fetchBookingHistory() async {
    isLoadingAppointments.value = true;
    allAppointments.clear();

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final today = selectedDate.value;
      final dateStr = _formatDateForApi(today);
      final statuses = _getApiStatuses(selectedTab.value);

      debugPrint('Booking History Statuses: $statuses');
      debugPrint('Booking History Date: $dateStr');

      final List<AppointmentModel> combinedAppointments = [];

      final requestedDate = dateStr;
      final requestedDoctorId = selectedDoctorId.value;
      final requestedTab = selectedTab.value;
      for (final status in statuses) {
        var fetched = 0;
        for (var page = 1; page <= 1000; page++) {
          final uri = Uri.parse('${Urls.baseUrl}/clinic/booking-history')
              .replace(
                queryParameters: {
                  'status': status,
                  'consultDate': requestedDate,
                  'page': '$page',
                  'limit': '100',
                  'doctorId': ?requestedDoctorId,
                },
              );
          final response = await http.get(
            uri,
            headers: {'Authorization': token},
          );
          if (response.statusCode != 200) {
            throw Exception('Unable to load bookings');
          }
          final parsed = BookingHistoryResponse.fromJson(
            jsonDecode(response.body),
          );
          if (!parsed.success || parsed.data == null) {
            throw Exception('Invalid booking response');
          }
          final rows = parsed.data!.data;
          combinedAppointments.addAll(
            rows.map((item) => item.toAppointmentModel()),
          );
          fetched += rows.length;
          if (fetched >= parsed.data!.meta.total) break;
          if (rows.isEmpty) throw Exception('Incomplete booking response');
        }
      }
      if (requestedDate != _formatDateForApi(selectedDate.value) ||
          requestedDoctorId != selectedDoctorId.value ||
          requestedTab != selectedTab.value) {
        return;
      }
      allAppointments.assignAll(combinedAppointments);
    } catch (e) {
      debugPrint('Error fetching booking history: $e');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  List<AppointmentModel> get filteredAppointments {
    // For home, we fetch by status already, so just return all
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
          fetchClinicStats(); // Refresh stats
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

  Future<void> refreshData() async {
    await Future.wait([fetchClinicStats(), fetchBookingHistory()]);
  }
}
