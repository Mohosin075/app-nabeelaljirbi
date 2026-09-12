import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/model/clinic_profile_model.dart';
import 'package:nabeelaljirbi_app/feature/clinic/wallet/model/top_up_history_model.dart';

class ClinicWalletController extends GetxController {
  late final ClinicProfileController _profileController;

  final RxDouble balance = 0.0.obs;
  final RxString referralCode = ''.obs;
  final RxInt friendsInvited = 0.obs;
  final RxDouble totalEarned = 0.0.obs;
  final RxDouble currentEarnings = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isHistoryLoading = false.obs;
  final RxList<TopUpItem> topUpHistory = <TopUpItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<ClinicProfileController>()) {
      _profileController = Get.find<ClinicProfileController>();
    } else {
      _profileController = Get.put(ClinicProfileController());
    }

    _updateData(_profileController.clinicProfile.value);
    ever(_profileController.clinicProfile, _updateData);
    fetchTopUpHistory();
  }

  void _updateData(ClinicProfileData? data) {
    if (data != null) {
      balance.value = (data.wallet ?? 0).toDouble();
      referralCode.value = data.referralCode ?? '';
      friendsInvited.value = (data.totalReferrals ?? 0).toInt();
      totalEarned.value = (data.totalEarnings ?? 0).toDouble();
      currentEarnings.value = (data.currentEarnings ?? 0).toDouble();
    }
  }

  Future<void> claimBonus() async {
    if (currentEarnings.value <= 0) {
      Get.snackbar(
        'error'.tr,
        'no_earnings_to_claim'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/referral/claim-bonus';

      final body = {"amount": currentEarnings.value};

      debugPrint('📤 Sending to API: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      log('📥 API Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          data['message'] ?? 'bonus_claimed_success'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        _profileController.fetchClinicProfile();
      } else {
        Get.snackbar(
          'error'.tr,
          data['message'] ?? 'failed_to_claim_bonus'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error claiming bonus: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTopUpHistory() async {
    isHistoryLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/payment/top-up-history';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('📥 API Response: $data');
        final historyModel = TopUpHistoryModel.fromJson(data);
        if (historyModel.data?.data != null) {
          topUpHistory.assignAll(historyModel.data!.data!);
        }
      } else {
        debugPrint('Failed to fetch history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([
      _profileController.fetchClinicProfile(),
      fetchTopUpHistory(),
    ]);
  }

  void copyReferralCode() {
    Clipboard.setData(ClipboardData(text: referralCode.value));
    Get.snackbar(
      'copied'.tr,
      'referral_code_copied'.tr,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }

  void shareReferralCode() {
    if (referralCode.value.isNotEmpty) {
      Share.share(
        'share_referral_msg'.trParams({'code': referralCode.value}),
      );
    } else {
      Get.snackbar(
        'error'.tr,
        'no_referral_code_to_share'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> withdraw() async {
    if (balance.value <= 0) {
      Get.snackbar(
        'error'.tr,
        'insufficient_balance'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _showWithdrawDialog();
  }

  void _showWithdrawDialog() {
    final TextEditingController amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'withdraw_amount'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${'available_balance'.tr}: ${balance.value.toStringAsFixed(2)} ${CurrencyUtil.getUserCurrencySymbol()}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: 'enter_amount_hint'.tr,
                prefixText: '${CurrencyUtil.getUserCurrencySymbol()} ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = amountController.text.trim();
              if (val.isEmpty) return;
              final amount = double.tryParse(val);
              if (amount == null || amount <= 0) {
                Get.snackbar(
                  'error'.tr,
                  'invalid_amount'.tr,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              if (amount > balance.value) {
                Get.snackbar(
                  'error'.tr,
                  'amount_exceeds_balance'.tr,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              Get.back();
              _processWithdraw(amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            child: Text('continue'.tr, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processWithdraw(double amount) async {
    isLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';

      final onboardingUrl = '${Urls.baseUrl}/payment/generate-onboarding-link';

      debugPrint('🔗 Generating Stripe onboarding link...');

      final onboardingResponse = await http.get(
        Uri.parse(onboardingUrl),
        headers: {'Authorization': token},
      );

      log('📥 Onboarding Response: ${onboardingResponse.body}');

      if (onboardingResponse.statusCode == 200 ||
          onboardingResponse.statusCode == 201) {
        final onboardingData = jsonDecode(onboardingResponse.body);

        if (onboardingData['success'] == true &&
            onboardingData['data'] != null) {
          final String stripeData = onboardingData['data'];

          if (stripeData == 'Profile already completed') {
            debugPrint(
              '✅ Stripe profile already completed, proceeding with withdrawal...',
            );
            await _executeWithdrawal(amount);
          } else {
            final String stripeLink = stripeData;

            Get.dialog(
              AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'stripe_account_setup'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                content: Text(
                  'stripe_onboarding_desc'.tr,
                  style: TextStyle(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      isLoading.value = false;
                    },
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await _openStripeOnboarding(stripeLink, amount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                    ),
                    child: Text(
                      'continue_to_stripe'.tr,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              barrierDismissible: false,
            );
          }
        } else {
          await _executeWithdrawal(amount);
        }
      } else {
        final errorData = jsonDecode(onboardingResponse.body);
        Get.snackbar(
          'error'.tr,
          errorData['message'] ?? 'failed_to_generate_onboarding_link'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
      }
    } catch (e) {
      debugPrint('Error in withdraw process: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }

  Future<void> _openStripeOnboarding(String stripeLink, double amount) async {
    try {
      final Uri url = Uri.parse(stripeLink);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        Get.dialog(
          AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'complete_stripe_setup'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: Text(
              'stripe_done_desc'.tr,
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  isLoading.value = false;
                },
                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await _executeWithdrawal(amount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                ),
                child: Text(
                  'ok_got_it'.tr,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        throw Exception('Could not launch Stripe URL');
      }
    } catch (e) {
      debugPrint('Error opening Stripe link: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_open_stripe'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }

  Future<void> _executeWithdrawal(double amount) async {
    isLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String withdrawUrl = '${Urls.baseUrl}/payment/withdraw-payment';

      final body = {"amount": amount};

      debugPrint('💰 Withdrawing amount: $body');

      final response = await http.post(
        Uri.parse(withdrawUrl),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      log('📥 Withdrawal Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          data['message'] ?? 'withdrawal_success'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        _profileController.fetchClinicProfile();
        fetchTopUpHistory();
      } else {
        Get.snackbar(
          'error'.tr,
          data['message'] ?? 'withdrawal_failed'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error executing withdrawal: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
