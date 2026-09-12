import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/appointment/model/doctor_appointment_model.dart';

class DoctorHomeScreenController extends GetxController {
  // Observable statistics
  var totalBook = 0.obs;
  var todayCount = 0.obs;
  var upcomingCount = 0.obs;

  // Observable appointment list
  var appointments = <Appointment>[].obs;
  var isLoading = false.obs;

  // Observable selected tab (0=Pending, 1=Upcoming, 2=Arrived, 3=Completed)
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getHomeData();
  }

  Future<void> getHomeData() async {
    isLoading.value = true;
    try {
      await Future.wait([getTodayAppointments(), getStatistics()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTodayAppointments() async {
    try {
      final token = SharedPrefHelper.getAccessToken();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String url = '${Urls.baseUrl}/doctor/appointments?consultDate=$today';

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
          final allFetched = model.data!.data!;
          final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

          // Strict local filtering for today's date to prevent future/past dates
          // that might be returned due to timezone or backend logic issues.
          final strictlyToday = allFetched
              .where((apt) => apt.consultDate?.startsWith(todayDate) ?? false)
              .toList();

          appointments.assignAll(strictlyToday);
        }
      }
    } catch (e) {
      debugPrint('Error fetching today appointments: $e');
    }
  }

  Future<void> getStatistics() async {
    // Assuming there might be a stats endpoint or we just use meta from appointments
    // For now, let's fetch all (or a large page) to get some counts if no specific endpoint
    try {
      final token = SharedPrefHelper.getAccessToken();
      String url = '${Urls.baseUrl}/doctor/appointments';

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

        if (model.success == true && model.data != null) {
          totalBook.value = model.data!.meta?.total ?? 0;

          final allData = model.data!.data ?? [];
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

          todayCount.value = allData
              .where((apt) => apt.consultDate?.startsWith(today) ?? false)
              .length;
          upcomingCount.value = allData
              .where(
                (apt) =>
                    apt.status?.toUpperCase() == 'CONFIRMED' ||
                    apt.status?.toUpperCase() == 'INPROGRESS',
              )
              .length;
        }
      }
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
    }
  }

  // Filter appointments based on selected tab
  List<Appointment> get filteredAppointments {
    return appointments.where((apt) {
      final status = apt.status?.toUpperCase() ?? 'PENDING';
      if (selectedTab.value == 0) {
        return status == 'PENDING';
      } else if (selectedTab.value == 1) {
        return status == 'CONFIRMED' || status == 'INPROGRESS';
      } else if (selectedTab.value == 2) {
        return status == 'ARRIVED';
      } else {
        return status == 'COMPLETE';
      }
    }).toList();
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  Future<void> updateAppointmentStatus(String bookingId, String status) async {
    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/clinic/update/appointment-status';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"bookingId": bookingId, "status": status}),
      );

      if (response.statusCode == 200) {
        String statusKey = status.toLowerCase();
        if (status == 'CONFIRMED') statusKey = 'upcoming';
        if (status == 'COMPLETE') statusKey = 'completed';
        if (status == 'INPROGRESS') statusKey = 'in_progress';

        Get.snackbar(
          'success'.tr,
          '${'appointment_status_updated_to'.tr} ${statusKey.tr}',
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        await getHomeData();
      } else {
        final body = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          body['message'] ?? 'failed_to_update_status'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      Get.snackbar('error'.tr, 'error_updating_status'.tr);
    } finally {
      isLoading.value = false;
    }
  }
}
