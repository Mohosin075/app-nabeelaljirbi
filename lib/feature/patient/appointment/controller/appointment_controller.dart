import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/model/appointment_history_model.dart';

class AppointmentController extends GetxController {
  var selectedReviewRating = 0.obs;
  var isLoading = false.obs;
  var selectedTab =
      0.obs; // 0: Pending, 1: Confirmed, 2: Arrived, 3: Completed, 4: Cancelled

  var upcomingAppointments = <Appointment>[].obs;
  var finishedAppointments = <Appointment>[].obs;
  var allAppointments = <Appointment>[].obs;

  @override
  void onInit() {
    super.onInit();
    getAppointmentHistory();
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  List<Appointment> get filteredAppointments {
    return allAppointments.where((apt) {
      final aptStatus = apt.status?.toUpperCase() ?? '';

      switch (selectedTab.value) {
        case 0: // Pending
          return aptStatus == 'PENDING' || aptStatus == 'INPROGRESS';
        case 1: // Confirmed
          return aptStatus == 'CONFIRMED';
        case 2: // Arrived
          return aptStatus == 'ARRIVED';
        case 3: // Completed
          return aptStatus == 'COMPLETE';
        case 4: // Cancelled
          return aptStatus == 'CANCELLED';
        default:
          return true;
      }
    }).toList();
  }

  void setReviewRating(int rating) {
    selectedReviewRating.value = rating;
  }

  var isSubmittingReview = false.obs;

  Future<void> submitReview(String appointmentId) async {
    if (selectedReviewRating.value == 0) {
      Get.snackbar('error'.tr, 'please_select_rating'.tr);
      return;
    }

    isSubmittingReview.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/rating';

      debugPrint('Submitting Review: $url');
      final body = {
        "appointmentId": appointmentId,
        "rating": selectedReviewRating.value,
      };
      debugPrint('Request Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('Review Response Status: ${response.statusCode}');
      debugPrint('Review Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close bottom sheet
        Get.snackbar(
          'success'.tr,
          'review_submitted_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        getAppointmentHistory(); // Refresh list
      } else {
        final resBody = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          resBody['message'] ?? 'failed_to_submit_review'.tr,
        );
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_occurred'.tr}: $e');
      debugPrint('Error submitting review: $e');
    } finally {
      isSubmittingReview.value = false;
    }
  }

  Future<void> getAppointmentHistory() async {
    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/patient/appointment-history';

      debugPrint('Fetching Appointment History: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final model = AppointmentHistoryModel.fromJson(body);

        if (model.success == true &&
            model.data != null &&
            model.data!.data != null) {
          final allFetchedAppointments = model.data!.data!;

          // Store all appointments for tab filtering
          allAppointments.assignAll(allFetchedAppointments);

          // Clear existing
          upcomingAppointments.clear();
          finishedAppointments.clear();

          for (var apt in allFetchedAppointments) {
            // Logic to separate upcoming vs finished
            // Prioritize status over date
            bool isFinished = false;

            final status = apt.status?.toUpperCase() ?? '';

            // Only these statuses should be in finished
            if (status == 'COMPLETED' ||
                status == 'COMPLETE' ||
                status == 'CANCELLED' ||
                status == 'FINISHED') {
              isFinished = true;
            }
            // PENDING, CONFIRMED, and ARRIVED should be in upcoming

            if (isFinished) {
              finishedAppointments.add(apt);
            } else {
              upcomingAppointments.add(apt);
            }
          }
        }
      } else {
        debugPrint('Failed to fetch appointments: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  var cancellingAppointmentId = ''.obs;
  var updatingAppointmentId = ''.obs;

  Future<void> cancelAppointment(String appointmentId) async {
    cancellingAppointmentId.value = appointmentId;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/patient/appointment-cancel/$appointmentId';

      debugPrint('Cancelling Appointment: $url');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Cancel Response Status: ${response.statusCode}');
      debugPrint('Cancel Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Get.snackbar(
          'success'.tr,
          'appointment_cancelled_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        getAppointmentHistory(); // Refresh list to show updated status
      } else {
        final body = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          body['message'] ?? 'failed_to_cancel_appointment'.tr,
        );
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_occurred'.tr}: $e');
      debugPrint('Error cancelling appointment: $e');
    } finally {
      cancellingAppointmentId.value = '';
    }
  }

  Future<void> updateAppointmentStatus(String bookingId, String status) async {
    updatingAppointmentId.value = bookingId;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/clinic/update/appointment-status';

      debugPrint('Updating Appointment Status: $url');
      debugPrint('BookingId: $bookingId, Status: $status');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"bookingId": bookingId, "status": status}),
      );

      debugPrint('Update Status Response: ${response.statusCode}');
      debugPrint('Update Status Body: ${response.body}');

      if (response.statusCode == 200) {
        Get.snackbar('success'.tr, 'appointment_status_updated'.tr,
        backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,);
        getAppointmentHistory(); // Refresh list
      } else {
        final body = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          body['message'] ?? 'failed_to_update_status'.tr,
        );
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'error_occurred'.tr}: $e');
      debugPrint('Error updating appointment status: $e');
    } finally {
      updatingAppointmentId.value = '';
    }
  }
}
