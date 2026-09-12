import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/localization/language_service.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/view/login_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/doctor_profile_model.dart';

class DoctorProfileController extends GetxController {
  final LanguageService _languageService = Get.find<LanguageService>();

  // Profile Data
  var isLoading = false.obs;
  var doctorProfile = Rxn<DoctorProfileData>();
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
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/doctor/profile';

      debugPrint('Fetching Doctor Profile from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint('Doctor Profile Status Code 🧑‍⚕️: ${response.statusCode}');
      log('Doctor Profile Response body 🧑‍⚕️: ${response.body}');

      if (response.statusCode == 200) {
        final model = DoctorProfileModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data != null) {
          doctorProfile.value = model.data;
          name.value = model.data!.fullName ?? '';
          role.value = model.data!.doctor?.speciality ?? '';
          profileImage.value = model.data!.profileImage ?? '';
          if (model.data!.country != null) {
            selectedCountry.value = model.data!.country!;
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
        debugPrint('Failed to fetch doctor profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching doctor profile: $e');
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
  var selectedCountry = 'Libya'.obs;
  final List<Map<String, String>> countries = [
    {'name': 'Libya', 'flag': '🇱🇾'},
    {'name': 'Egypt', 'flag': '🇪🇬'},
    {'name': 'Syria', 'flag': '🇸🇾'},
    {'name': 'Algeria', 'flag': '🇩🇿'},
  ];

  String getSelectedCountryFlag() {
    final country = countries.firstWhere(
      (c) => c['name']!.toLowerCase() == selectedCountry.value.toLowerCase(),
      orElse: () => {'name': '', 'flag': ''},
    );
    return country['flag'] ?? '';
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
              Get.offAll(() => LoginScreen());
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
}
