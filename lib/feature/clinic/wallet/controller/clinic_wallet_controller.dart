import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:share_plus/share_plus.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/model/clinic_profile_model.dart';
import 'package:nabeelaljirbi_app/feature/clinic/wallet/model/top_up_history_model.dart';

class ClinicWalletController extends GetxController {
  Future<void> requestSettlement() async {
    if (isLoading.value) return;
    final input = TextEditingController();
    final amount = await Get.dialog<double>(
      AlertDialog(
        title: Text('withdraw'.tr),
        content: TextField(
          controller: input,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'withdraw_amount'.tr),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              final value = double.tryParse(input.text.trim());
              if (value != null &&
                  value.isFinite &&
                  value > 0 &&
                  value <= balance.value) {
                Get.back(result: value);
              } else {
                Get.snackbar('error'.tr, 'insufficient_balance'.tr);
              }
            },
            child: Text('withdraw'.tr),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
    input.dispose();
    if (amount == null) return;
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/clinic/settlements'),
        headers: {
          'Authorization': SharedPrefHelper.getAccessToken() ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'amount': amount}),
      );
      final result = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(result['message'] ?? 'Unable to request withdrawal');
      }
      Get.snackbar('success'.tr, 'withdraw_request_sent'.tr);
      await refreshData();
    } catch (error) {
      Get.snackbar('error'.tr, error.toString());
    } finally {
      isLoading.value = false;
    }
  }

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
      Share.share('share_referral_msg'.trParams({'code': referralCode.value}));
    } else {
      Get.snackbar(
        'error'.tr,
        'no_referral_code_to_share'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
