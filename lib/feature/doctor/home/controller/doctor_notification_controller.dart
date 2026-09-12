import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/home/model/notification_model.dart';

class DoctorNotificationController extends GetxController {
  var notifications = <NotificationData>[].obs;
  var isLoading = false.obs;
  var isPaginationLoading = false.obs;
  var currentPage = 1;
  var totalPages = 1;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  Future<void> getNotifications({int page = 1}) async {
    if (page == 1) {
      isLoading.value = true;
    } else {
      isPaginationLoading.value = true;
    }

    try {
      final token = SharedPrefHelper.getAccessToken();
      String url = '${Urls.baseUrl}/notification/doctor?page=$page&limit=10';

      debugPrint('Fetching Notifications: $url');
      debugPrint('Authorization Token: $token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Notification Response Status: ${response.statusCode}');
      debugPrint('Notification Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final model = NotificationResponse.fromJson(body);

        if (model.success == true && model.data != null) {
          debugPrint(
            'Notifications fetched successfully. Count: ${model.data!.data?.length}',
          );
          if (page == 1) {
            notifications.assignAll(model.data!.data ?? []);
          } else {
            notifications.addAll(model.data!.data ?? []);
          }

          if (model.data!.meta != null) {
            currentPage = model.data!.meta!.page ?? 1;
            final total = model.data!.meta!.total ?? 0;
            final limit = model.data!.meta!.limit ?? 10;
            totalPages = (total / limit).ceil();
            debugPrint(
              'Pagination Info - Current Page: $currentPage, Total Pages: $totalPages, Total Recs: $total',
            );
          }
        } else {
          debugPrint(
            'Notification API Success False or Data Null: ${model.message}',
          );
        }
      } else {
        debugPrint(
          'Notification API Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Exception while fetching notifications: $e');
    } finally {
      isLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  void loadMore() {
    if (currentPage < totalPages && !isPaginationLoading.value) {
      getNotifications(page: currentPage + 1);
    }
  }
}
