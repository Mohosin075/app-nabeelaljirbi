import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/localization/language_service.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/view/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/model/patient_profile_model.dart';

class PatientProfileController extends GetxController {
  final LanguageService _languageService = Get.find<LanguageService>();

  // Profile Data
  var isLoading = false.obs;
  var patientProfile = Rxn<PatientProfileData>();
  var name = ''.obs;
  var role = ''.obs;
  var profileImage = ''.obs;

  // Settings
  var isDarkTheme = false.obs;

  // Language Selection
  late RxString selectedLanguage;
  final List<String> languages = ['english', 'arabic'];

  @override
  void onInit() {
    super.onInit();
    selectedLanguage =
        (_languageService.locale.languageCode == 'ar' ? 'arabic' : 'english')
            .obs;
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final String? token = SharedPrefHelper.getAccessToken();
      if (token == null) {
        debugPrint('Access token is null');
        return;
      }

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/patient/profile'),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint(
        '🙎🏻‍♂️🙎🏻‍♂️🙎🏻‍♂️ Profile API Status: ${response.statusCode}',
      );
      debugPrint(
        '🙎🏻‍♂️🙎🏻‍♂️🙎🏻‍♂️ Profile API Response: ${response.body}',
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final profileModel = PatientProfileModel.fromJson(decodedData);
        if (profileModel.data != null && profileModel.data!.user != null) {
          patientProfile.value = profileModel.data;
          name.value = profileModel.data!.user!.fullName ?? '';
          role.value =
              profileModel.data!.user!.role?.toLowerCase() ?? 'patient';
          if (profileModel.data!.user!.profileImage != null) {
            profileImage.value = profileModel.data!.user!.profileImage!;
          }
          if (profileModel.data!.user!.country != null) {
            selectedCountry.value = profileModel.data!.user!.country!;
          }
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          if (body['message'] == "This user is not found !" || response.statusCode == 401) {
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
      } else {
        debugPrint('Error fetching profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception while fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeLanguage(String language) {
    selectedLanguage.value = language;
    _languageService.updateLocale(language);
    Get.back(); // Close bottom sheet
  }

  // Country Selection
  var selectedCountry = 'libya'.obs;
  final List<Map<String, String>> countries = [
    {'name': 'libya', 'flag': '🇱🇾'},
    {'name': 'egypt', 'flag': '🇪🇬'},
    {'name': 'syria', 'flag': '🇸🇾'},
    {'name': 'algeria', 'flag': '🇩🇿'},
  ];

  String getSelectedCountryFlag() {
    final country = countries.firstWhere(
      (c) => c['name']!.toLowerCase() == selectedCountry.value.toLowerCase(),
      orElse: () => {'name': '', 'flag': ''},
    );
    return country['flag'] ?? '';
  }

  String getSelectedCountrySvg() {
    switch (selectedCountry.value.toLowerCase()) {
      case 'libya':
        return IconsPath.libya;
      case 'egypt':
        return IconsPath.egypt;
      case 'algeria':
        return IconsPath.algeria;
      case 'tunisia':
        return IconsPath.tunisia;
      default:
        return IconsPath.libya; // Default flag
    }
  }

  void changeCountry(String country) {
    selectedCountry.value = country;
    Get.back(); // Close bottom sheet
  }

  // Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'log_out'.tr,
          style: globalTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2D2D2D),
          ),
        ),
        content: Text(
          'confirm_logout'.tr,
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xff2D2D2D),
          ),
        ),
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
            child: Text(
              'cancel'.tr,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff2D2D2D),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              SharedPrefHelper.removeAccessToken();
              SharedPrefHelper.removeRefreshToken();
              SharedPrefHelper.removeUserRole();
              Get.offAll(() => LoginScreen()); // Close dialog
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xff64748B)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'log_out'.tr,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
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
        title: Text(
          'delete_account'.tr,
          style: globalTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2D2D2D),
          ),
        ),
        content: Text(
          'confirm_delete_account'.tr,
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xff2D2D2D),
          ),
        ),
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
            child: Text(
              'cancel'.tr,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff2D2D2D),
              ),
            ),
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
            child: Text(
              'delete'.tr,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Check if user has premium subscription
  bool get isPremiumUser {
    return patientProfile.value?.user?.platformSubscriptionActive ?? false;
  }

  // Check premium status and show dialog if not premium
  // Returns true if user is premium, false otherwise
  bool checkPremiumAccess({String? feature}) {
    if (!isPremiumUser) {
      // Import the dialog at the top of the file
      // Show premium required dialog
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'premium_required'.tr,
                style: globalTextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff2D2D2D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'premium_required_desc'.tr,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'maybe_later'.tr,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Navigate to subscription screen
                Get.toNamed('/patientSubscription');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'upgrade_to_premium'.tr,
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
