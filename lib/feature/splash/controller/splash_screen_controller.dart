import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/view/login_screen.dart';
import 'package:nabeelaljirbi_app/feature/auth/on_boarding/view/on_boarding_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/nav_bar/view/clinic_nav_bar_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/nav_bar/view/doctor_nav_bar_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/nav_bar/view/patient_nav_bar_screen.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    checkIsLogin();
    generateFcmToken();
  }

  void checkIsLogin() async {
    Timer(const Duration(seconds: 2), () async {
      final String? token = SharedPrefHelper.getAccessToken();
      debugPrint("🔥 TOKEN: $token");
      final String? role = SharedPrefHelper.getUserRole();
      debugPrint("🔥 ROLE: $role");

      if (token != null && role != null) {
        if (role.toLowerCase() == 'patient') {
          Get.offAll(() => PatientNavBarScreen());
        } else if (role.toLowerCase() == 'doctor') {
          Get.offAll(() => DoctorNavBarScreen());
        } else if (role.toLowerCase() == 'clinic') {
          Get.offAll(() => ClinicNavBarScreen());
        } else {
          Get.offAll(() => LoginScreen());
        }
      } else {
        if (SharedPrefHelper.isOnboardingCompleted()) {
          Get.offAll(() => LoginScreen());
        } else {
          Get.offAll(() => OnBoardingScreen());
        }
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
      String? token = await FirebaseMessaging.instance.getToken();
      debugPrint("🔥 FCM TOKEN: $token");
    } catch (e) {
      debugPrint("❌ Error getting FCM token: $e");
    }
  }
}
