import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/localization/language_service.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/view/login_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/model/clinic_profile_model.dart';

class ClinicProfileController extends GetxController {
  final LanguageService _languageService = Get.find<LanguageService>();

  // Profile Data
  var isLoading = false.obs;
  var clinicProfile = Rxn<ClinicProfileData>();
  var name = 'Salama Medical Center'.obs;
  var address = 'Tripoli, Libya'.obs;
  var logo =
      'https://img.freepik.com/free-vector/health-medical-logo-design_23-2148111246.jpg'
          .obs;
  var rating = 4.8.obs;
  var reviewsCount = 120.obs;

  // Language Selection
  late RxString selectedLanguage;
  final List<String> languages = ['english', 'arabic'];
  @override
  void onInit() {
    super.onInit();
    selectedLanguage =
        (_languageService.locale.languageCode == 'ar' ? 'arabic' : 'english')
            .obs;
    fetchClinicProfile();
  }

  Future<void> fetchClinicProfile() async {
    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/clinic/info'),
        headers: {'Authorization': token},
      );

      debugPrint('🏥️🏥️🏥️ Clinic Profile Status: ${response.statusCode}');
      log('🏥️🏥️🏥️ Clinic Profile Body: ${response.body}');

      if (response.statusCode == 200) {
        final model = ClinicProfileModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data != null) {
          clinicProfile.value = model.data;
          name.value = model.data!.clinic?.clinicName ?? '';
          address.value = model.data!.address ?? '';
          logo.value = model.data!.clinic?.logo ?? '';
          if (model.data!.country != null) {
            selectedCountry.value = model.data!.country!;
          }
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          if (body['message'] == "This user is not found !" ||
              response.statusCode == 401) {
            SharedPrefHelper.removeAccessToken();
            SharedPrefHelper.removeRefreshToken();
            SharedPrefHelper.removeUserRole();
            Get.offAll(() => LoginScreen());
          }
        } catch (_) {
          // Fallback if response body is not JSON
          if (response.statusCode == 401) {
            SharedPrefHelper.removeAccessToken();
            SharedPrefHelper.removeRefreshToken();
            SharedPrefHelper.removeUserRole();
            Get.offAll(() => LoginScreen());
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching clinic profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeCountry(String country) {
    selectedCountry.value = country;
    Get.back(); // Close bottom sheet
  }

  void changeLanguage(String language) {
    selectedLanguage.value = language;
    _languageService.updateLocale(language);
    Get.back(); // Close bottom sheet
  }

  // Country Selection
  var selectedCountry = 'Libya'.obs;
  final List<Map<String, String>> countries = [
    {'name': 'Libya', 'flag': IconsPath.libya},
    {'name': 'Tunisia', 'flag': IconsPath.tunisia},
    {'name': 'Egypt', 'flag': IconsPath.egypt},
    {'name': 'Algeria', 'flag': IconsPath.algeria},
  ];

  String getSelectedCountryFlag() {
    final country = countries.firstWhere(
      (c) => c['name']!.toLowerCase() == selectedCountry.value.toLowerCase(),
      orElse: () => {'name': '', 'flag': IconsPath.libya},
    );
    return country['flag'] ?? IconsPath.libya;
  }

  // Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text('log_out'.tr),
        content: Text('confirm_logout'.tr),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xff64748B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              SharedPrefHelper.removeAccessToken();
              SharedPrefHelper.removeRefreshToken();
              SharedPrefHelper.removeUserRole();
              Get.offAll(LoginScreen());
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('log_out'.tr),
          ),
        ],
      ),
    );
  }

  // Delete Account
  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text('delete_account'.tr),
        content: Text('confirm_delete_account'.tr),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xff64748B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              isLoading.value = true;
              try {
                final token = SharedPrefHelper.getAccessToken() ?? '';
                final response = await http.delete(
                  Uri.parse('${Urls.baseUrl}/auth/delete-account'),
                  headers: {'Authorization': token},
                );

                if (response.statusCode == 200 || response.statusCode == 204) {
                  SharedPrefHelper.removeAccessToken();
                  SharedPrefHelper.removeRefreshToken();
                  SharedPrefHelper.removeUserRole();
                  Get.offAll(() => LoginScreen());
                } else {
                  Get.snackbar('error'.tr, 'failed_to_delete_account'.tr);
                }
              } catch (e) {
                debugPrint('Error deleting account: $e');
                Get.snackbar('error'.tr, 'failed_to_delete_account'.tr);
              } finally {
                isLoading.value = false;
              }
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xffFF4D4F),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xffFF4D4F)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  // Check if clinic has premium subscription (currently not active/required)
  bool get isPremiumUser {
    return true; // Bypass subscription logic for clinic for now
    // return clinicProfile.value?.platformSubscriptionActive ?? false;
  }

  // Check premium status and show dialog if not premium
  bool checkPremiumAccess({String? feature}) {
    if (!isPremiumUser) {
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium,
                color: AppColors.primaryColor,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'premium_required'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'premium_required_desc'.tr,
                style: const TextStyle(fontSize: 14, color: Color(0xff64748B)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('maybe_later'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Navigate to clinic subscription screen
                Get.toNamed('/clinicSubscription');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: Text(
                'upgrade_to_premium'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }
}
