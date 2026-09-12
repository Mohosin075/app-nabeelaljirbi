import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/clinic/subscription/model/platform_subscription_model.dart';
import 'dart:convert';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
// import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
// import 'package:nabeelaljirbi_app/core/service/stripe_service.dart';

class ClinicSubscriptionController extends GetxController {
  var selectedPlanId = ''.obs;
  var selectedPlanAmount = Rx<num>(0);
  var usdAmount = Rx<num>(0);
  var isLoading = false.obs;
  var subscriptionPlan = Rx<ClinicSubscription?>(null);

  Future<void> fetchSubscriptionPlans() async {
    isLoading.value = true;
    try {
      final String? token = SharedPrefHelper.getAccessToken();
      if (token == null) {
        debugPrint('Access token is null');
        return;
      }

      debugPrint(
        '📦 Fetching Plans from: ${Urls.baseUrl}/payment/patient-platform-subscription',
      );

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/payment/patient-platform-subscription'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('📦 Subscription Plans Status: ${response.statusCode}');
      debugPrint('📦 Subscription Plans Response: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final subscriptionResponse = ClinicSubscriptionResponse.fromJson(
          decodedData,
        );

        if (subscriptionResponse.data != null) {
          subscriptionPlan.value = subscriptionResponse.data;

          // Set default plan info
          selectedPlanId.value = subscriptionPlan.value!.id ?? '';
          selectedPlanAmount.value = subscriptionPlan.value!.amount ?? 0;
          usdAmount.value = subscriptionPlan.value!.usdAmount ?? 0;
        }
      } else {
        debugPrint('Error fetching subscription plans: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception while fetching subscription plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPlan(String planId, num amount, num usdAmt) {
    selectedPlanId.value = planId;
    selectedPlanAmount.value = amount;
    usdAmount.value = usdAmt;
  }

  final TextEditingController cardNumberController = TextEditingController();

  Future<void> topUpPrepaidCard() async {
    if (cardNumberController.text.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_enter_card_number'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      final String? token = SharedPrefHelper.getAccessToken();
      if (token == null) {
        throw Exception('Access token is null');
      }

      debugPrint('💰 Posting Top-up to: ${Urls.baseUrl}/prepaid-card/top-up');

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/prepaid-card/top-up'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode({'cardNumber': cardNumberController.text.trim()}),
      );

      debugPrint('💰 Top-up API Status: ${response.statusCode}');
      debugPrint('💰 Top-up API Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final walletController = Get.put(ClinicProfileController());
        await walletController.fetchClinicProfile();

        isLoading.value = false;
        cardNumberController.clear();
        Get.back();

        // Show success snackbar
        Get.snackbar(
          'success'.tr,
          'card_topped_up_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'failed_to_top_up'.tr);
      }
    } catch (e) {
      debugPrint('❌ Top-up Error: $e');
      isLoading.value = false;

      Get.snackbar(
        'error'.tr,
        e.toString().replaceAll('Exception: ', '').tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    }
  }

  /*
  Future<void> subscribe() async {
    if (selectedPlanId.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select a subscription plan',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      return;
    }

    isLoading.value = true;

    try {
      // 1. Create Payment Method (Tokenize Card via CardField)
      // This requires the CardField to be present and populated in the UI.
      final String? paymentMethodId = await StripeService.instance
          .createPaymentMethod();

      if (paymentMethodId == null) {
        Get.snackbar(
          'error'.tr,
          'Failed to create payment method. Please check card details.',
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
        );
        isLoading.value = false;
        return;
      }

      debugPrint('💳 Payment Method ID: $paymentMethodId');

      // 2. Call Backend API to process payment
      final String? token = SharedPrefHelper.getAccessToken();
      if (token == null) {
        throw Exception('Access token is null');
      }

      debugPrint(
        '💰 Posting Payment to: ${Urls.baseUrl}/payment/patient-platform-subscription',
      );

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/payment/patient-platform-subscription'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'paymentMethodId': paymentMethodId,
          'subscriptionId': selectedPlanId.value,
          'amount': usdAmount.value,
        }),
      );

      debugPrint('💰 Payment API Status: ${response.statusCode}');
      debugPrint('💰 Payment API Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Payment successful - refresh profile to update subscription status
        final profileController = Get.find<PatientProfileController>();
        await profileController.fetchProfile();

        isLoading.value = false;

        // Show success dialog
        showSuccessDialog();
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Payment failed');
      }
    } on StripeException catch (e) {
      debugPrint('❌ Stripe Error: ${e.error.localizedMessage}');
      isLoading.value = false;

      Get.snackbar(
        'error'.tr,
        e.error.localizedMessage ?? 'Payment failed',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      debugPrint('❌ Payment Error: $e');
      isLoading.value = false;

      Get.snackbar(
        'error'.tr,
        'Payment failed. Please try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    }
  }

  void showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xff10B981).withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xff10B981),
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'subscription_success'.tr,
                style: globalTextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'subscription_success_desc'.tr,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Close subscription screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ok_got_it'.tr,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  */

  @override
  void onClose() {
    cardNumberController.dispose();
    super.onClose();
  }
}
