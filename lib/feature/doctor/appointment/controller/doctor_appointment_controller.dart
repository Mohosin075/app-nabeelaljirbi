import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/appointment/model/doctor_appointment_model.dart';

class DoctorAppointmentController extends GetxController {
  var selectedTab = 0.obs; // 0: Pending, 1: Upcoming, 2: Arrived, 3: Completed
  var selectedDate = Rxn<DateTime>();
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var allAppointments = <Appointment>[].obs;
  final ScrollController scrollController = ScrollController();

  // Pagination Variables
  var currentPage = 1;
  var hasNextPage = true.obs;
  final int limit = 10;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    getDoctorAppointments();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
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
      getDoctorAppointments();
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

      if (selectedTab.value == 0) {
        matchesStatus = status == 'PENDING';
      } else if (selectedTab.value == 1) {
        matchesStatus = status == 'CONFIRMED' || status == 'INPROGRESS';
      } else if (selectedTab.value == 2) {
        matchesStatus = status == 'ARRIVED';
      } else {
        matchesStatus = status == 'COMPLETE';
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

  Future<void> getDoctorAppointments({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isMoreLoading.value || !hasNextPage.value) return;
      isMoreLoading.value = true;
    } else {
      isLoading.value = true;
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

          // Update pagination status
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
        debugPrint('Failed to fetch appointments: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
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
        await getDoctorAppointments();
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
