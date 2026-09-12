import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/clinic/controller/clinic_profile_setup_controller.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/clinic/view/clinic_review_screen.dart';

class ClinicReferController extends GetxController {
  final TextEditingController referralController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool hasReferralCode = false.obs;

  @override
  void onInit() {
    super.onInit();
    referralController.addListener(() {
      hasReferralCode.value = referralController.text.trim().isNotEmpty;
    });
  }

  @override
  void onClose() {
    referralController.dispose();
    super.onClose();
  }

  Future<void> submitProfile() async {
    // If no referral code is entered, skip hitting the API
    if (!hasReferralCode.value) {
      final setupController = Get.find<ClinicProfileSetupController>();
      final args = {
        'clinicName': setupController.clinicName.value,
        'city': setupController.selectedCity.value ?? "",
        'managerPhone':
            "${setupController.managerPhoneCountryCode.value}${setupController.managerPhone.value}",
      };

      Get.offAll(() => ClinicReviewScreen(), arguments: args);
      return;
    }

    isLoading.value = true;

    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/referral/apply';

      debugPrint('Applying Referral Code: ${referralController.text.trim()}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode({"referralCode": referralController.text.trim()}),
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "success".tr,
          responseData['message'] ?? "referral_applied_successfully".tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );

        // Retrieve data from the previous controller before it gets disposed by offAll
        final setupController = Get.find<ClinicProfileSetupController>();
        final args = {
          'clinicName': setupController.clinicName.value,
          'city': setupController.selectedCity.value ?? "",
          'managerPhone':
              "${setupController.managerPhoneCountryCode.value}${setupController.managerPhone.value}",
        };

        Get.offAll(() => ClinicReviewScreen(), arguments: args);
      } else {
        Get.snackbar(
          "error".tr,
          responseData['message'] ?? "failed_to_apply_referral".tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar(
        "error".tr,
        "something_went_wrong".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
