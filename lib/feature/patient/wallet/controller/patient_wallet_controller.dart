import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/service/stripe_service.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/model/patient_profile_model.dart';

import 'package:nabeelaljirbi_app/feature/patient/wallet/model/top_up_history_model.dart';

class PatientWalletController extends GetxController {
  late final PatientProfileController _profileController;

  final RxDouble balance = 0.0.obs;
  final RxString referralCode = ''.obs;
  final RxList<TopUpItem> topUpHistory = <TopUpItem>[].obs;
  final RxBool isHistoryLoading = false.obs;

  // Restored missing variables
  final RxInt friendsInvited = 0.obs;
  final RxDouble currentEarnings = 0.0.obs;
  // Previously missing variables causing lint errors
  final RxDouble totalEarned = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<PatientProfileController>()) {
      _profileController = Get.find<PatientProfileController>();
    } else {
      _profileController = Get.put(PatientProfileController());
    }

    _updateData(_profileController.patientProfile.value);
    ever(_profileController.patientProfile, _updateData);
    fetchTopUpHistory();
  }

  void _updateData(PatientProfileData? data) {
    if (data != null && data.user != null) {
      final user = data.user!;
      balance.value = (user.wallet ?? 0).toDouble();
      referralCode.value = user.referralCode ?? '';
      friendsInvited.value = (user.totalReferrals ?? 0).toInt();
      totalEarned.value = (user.totalEarnings ?? 0).toDouble();
      currentEarnings.value = (user.currentEarnings ?? 0).toDouble();
    }
  }

  Future<void> claimBonus() async {
    if (currentEarnings.value <= 0) {
      Get.snackbar(
        'Error',
        'No earnings to claim',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/referral/claim-bonus';

      // Send the full unclaimed amount
      final body = {"amount": currentEarnings.value};

      debugPrint('📤 Sending to API: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('📥 API Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          data['message'] ?? 'Bonus claimed successfully',
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        _profileController.fetchProfile(); // Refresh to update earnings/wallet
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to claim bonus',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error claiming bonus: $e');
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
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

  Future<void> processTopUp(double amount) async {
    isLoading.value = true;
    try {
      // 1. Create Payment Method (Tokenize Card via CardField)
      // This requires the CardField to be present and populated in the UI.
      final String? paymentMethodId = await StripeService.instance
          .createPaymentMethod();

      if (paymentMethodId == null) {
        Get.snackbar(
          'Error',
          'Failed to create payment method. Please check card details.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 2. Call Backend API
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/payment/patient-top-up';

      final bodyToSend = {"amount": amount, "paymentMethodId": paymentMethodId};

      debugPrint('📤 Sending to API: $bodyToSend');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(bodyToSend),
      );

      log('📥 API Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close BottomSheet
        Get.snackbar(
          'Success',
          'Wallet topped up successfully',
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        _profileController.fetchProfile();
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          responseData['message'] ?? 'Top up failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      log('Top Up Error: $e');
      if (e is StripeException) {
        Get.snackbar(
          'Payment Error',
          '${e.error.localizedMessage}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Something went wrong: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await Future.wait([_profileController.fetchProfile(), fetchTopUpHistory()]);
  }

  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'Top-up',
      'id': '#45821',
      'date': 'Oct 26, 10:30 AM',
      'amount': '+ ${CurrencyUtil.getUserCurrencySymbol()} 50.00',
      'isCredit': true,
      'icon': IconsPath.topUp,
      'iconBg': const Color(0xFFE8F5E9), // Light Green
      // 'iconColor': const Color(0xFF4CAF50), // Green
    },
    {
      'title': 'Booking: Dr. Smith',
      'id': '#45821',
      'date': 'Oct 26, 10:30 AM',
      'amount': '- ${CurrencyUtil.getUserCurrencySymbol()} 50.00',
      'isCredit': false,
      'icon': IconsPath.booking,
      'iconBg': const Color(0xFFFFEBEE), // Light Red
      // 'iconColor': const Color(0xFFF44336), // Red
    },
    {
      'title': 'Referral Bonus',
      'id': '#45821',
      'date': 'Oct 26, 10:30 AM',
      'amount': '+ ${CurrencyUtil.getUserCurrencySymbol()} 5.00',
      'isCredit': true,
      'icon': IconsPath.refarrelBonus,
      'iconBg': const Color(0xFFFFF8E1), // Light Yellow
      // 'iconColor': const Color(0xFFFFC107), // Amber/Yellow
    },
  ];

  void copyReferralCode() {
    Clipboard.setData(ClipboardData(text: referralCode.value));
    Get.snackbar(
      'Copied',
      'Referral code copied to clipboard',
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }

  void shareReferralCode() {
    if (referralCode.value.isNotEmpty) {
      Share.share(
        'Use my referral code: ${referralCode.value} to sign up!',
      );
    } else {
      Get.snackbar(
        'Error',
        'No referral code available to share',
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
      );
    }
  }
}
