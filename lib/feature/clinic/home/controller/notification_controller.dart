import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import '../model/notification_model.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get hasUnread => notifications.any((n) => n.isUnread);

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true);
      errorMessage.value = '';
      final token = SharedPrefHelper.getAccessToken(); // Or how you get token
      final url = '${Urls.baseUrl}/notification/clinic';
      debugPrint('Notification URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Notification Status Code: ${response.statusCode}');
      debugPrint('Notification Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['data'] != null) {
          final List<dynamic> list = data['data']['data'];
          final parsed = list
              .map((e) => NotificationModel.fromJson(e))
              .toList();
          notifications.assignAll(parsed);
        } else {
          // If success is false or data is missing, maybe empty list
          notifications.clear();
        }
      } else {
        errorMessage.value =
            'Failed to load notifications: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
      debugPrint('Notification Error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }
}
