import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/auth/role_selection/view/role_selection_screen.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/patient/nav_bar/view/patient_nav_bar_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/nav_bar/view/doctor_nav_bar_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/nav_bar/view/clinic_nav_bar_screen.dart';

class OtpVerificationController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final RxString otpError = ''.obs;

  final RxInt secondsRemaining = 30.obs;
  final RxBool isResendEnabled = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;
  final RxString fcmToken = ''.obs;

  late String phoneNumber;
  late String otpSender;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    phoneNumber = Get.arguments['phoneNumber'] ?? '';
    otpSender = Get.arguments['otpSender'] ?? 'whatsapp';
    startTimer();
    generateFcmToken();
  }

  void startTimer() {
    isResendEnabled.value = false;
    secondsRemaining.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        isResendEnabled.value = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> generateFcmToken() async {
    try {
      if (GetPlatform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          debugPrint("⚠️ APNS Token not available yet.");
          return;
        }
      }
      fcmToken.value = (await FirebaseMessaging.instance.getToken())!;
      debugPrint("🔥 FCM TOKEN: $fcmToken");
    } catch (e) {
      debugPrint("❌ Error getting FCM token: $e");
    }
  }

  Future<void> resendCode() async {
    if (!isResendEnabled.value || isResending.value) return;

    isResending.value = true;
    try {
      final String url = '${Urls.baseUrl}/auth/send-otp';
      final Map<String, String> body = {
        'phoneNumber': phoneNumber,
        'otpSender': otpSender,
      };

      debugPrint('Resending OTP Request to: $url');
      debugPrint('Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Resend Response Status Code: ${response.statusCode}');
      debugPrint('Resend Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          responseData['message'] ?? 'otp_sent_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        startTimer();
      } else {
        Get.snackbar(
          'error'.tr,
          responseData['message'] ?? 'failed_to_send_otp'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error resending OTP: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isResending.value = false;
    }
  }

  Future<void> verifyOTP() async {
    final String otp = otpController.text;
    if (otp.length != 6) {
      otpError.value = 'enter_6_digits'.tr;
      return;
    }

    isLoading.value = true;
    try {
      final String url = '${Urls.baseUrl}/auth/verify-otp';
      final Map<String, String> body = {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'fcmToken': fcmToken.value,
      };

      debugPrint('Verifying OTP Request to: $url');
      debugPrint('Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Verify Response Status Code: ${response.statusCode}');
      debugPrint('Verify Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = responseData['data'];

        if (data != null) {
          // Save tokens
          if (data['accessToken'] != null) {
            await SharedPrefHelper.saveToken(
              data['accessToken'],
              data['refreshToken'],
            );
            debugPrint('Token saved successfully');
          }

          Get.snackbar(
            'success'.tr,
            responseData['message'] ?? 'otp_verified_successfully'.tr,
            backgroundColor: AppColors.primaryColor,
            colorText: Colors.white,
          );

          // Check profile completion status
          final bool profileCompleted = data['profileCompleted'] == true;
          final String? role = data['role'];

          debugPrint('Profile Completed: $profileCompleted, Role: $role');

          if (profileCompleted && role != null) {
            // User has completed profile, save role and go to home
            await SharedPrefHelper.saveRole(role.toUpperCase());

            switch (role.toUpperCase()) {
              case 'PATIENT':
                Get.offAll(() => PatientNavBarScreen());
                break;
              case 'DOCTOR':
                Get.offAll(() => DoctorNavBarScreen());
                break;
              case 'CLINIC':
              case 'MANAGER':
                Get.offAll(() => ClinicNavBarScreen());
                break;
              default:
                // Fallback to role selection if role is unknown
                Get.offAll(() => RoleSelectionScreen());
            }
          } else {
            // Profile not completed, go to role selection/registration
            Get.offAll(() => RoleSelectionScreen());
          }
        } else {
          Get.snackbar('error'.tr, 'something_went_wrong'.tr);
        }
      } else {
        otpError.value = responseData['message'] ?? 'invalid_otp'.tr;
        Get.snackbar('error'.tr, responseData['message'] ?? 'invalid_otp'.tr);
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  String get timerText {
    int minutes = secondsRemaining.value ~/ 60;
    int seconds = secondsRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getOTP() {
    return otpController.text;
  }

  @override
  void onClose() {
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }
}
