import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/patient/notification/model/patient_notification_model.dart';

class PatientNotificationController extends GetxController {
  final notifications = <PatientNotificationItem>[].obs;
  final isLoading = false.obs;
  final isPaginationLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  int currentPage = 1;
  int totalPages = 1;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  Future<void> getNotifications({int page = 1}) async {
    if (page == 1) {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
    } else {
      isPaginationLoading.value = true;
    }

    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/notification/patient?page=$page&limit=10';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': token ?? '',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final model = PatientNotificationResponse.fromJson(body);

        if (model.success == true && model.data != null) {
          final items = model.data!.data ?? [];
          if (page == 1) {
            notifications.assignAll(items);
          } else {
            notifications.addAll(items);
          }

          if (model.data!.meta != null) {
            currentPage = model.data!.meta!.page ?? 1;
            final total = model.data!.meta!.total ?? 0;
            final limit = model.data!.meta!.limit ?? 10;
            totalPages = (total / (limit > 0 ? limit : 10)).ceil();
          }
        } else {
          if (page == 1) {
            hasError.value = true;
            errorMessage.value = model.message ?? 'failed_to_load_notifications'.tr;
          }
        }
      } else {
        if (page == 1) {
          hasError.value = true;
          errorMessage.value = 'failed_to_load_notifications'.tr;
        }
      }
    } catch (e) {
      debugPrint('Exception while fetching patient notifications: $e');
      if (page == 1) {
        hasError.value = true;
        errorMessage.value = 'network_error_retry'.tr;
      }
    } finally {
      isLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  void loadMore() {
    if (currentPage < totalPages && !isPaginationLoading.value && !isLoading.value) {
      getNotifications(page: currentPage + 1);
    }
  }

  void refreshNotifications() {
    getNotifications(page: 1);
  }
}
