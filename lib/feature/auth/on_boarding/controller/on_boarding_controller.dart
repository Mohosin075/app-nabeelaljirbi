import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/const/video_path.dart';
import 'package:nabeelaljirbi_app/core/localization/language_service.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/view/login_screen.dart';

class OnBoardingController extends GetxController {
  final LanguageService _languageService = Get.find<LanguageService>();
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  late RxString selectedLanguage;
  final List<String> languages = ['english', 'arabic'];

  final List<Map<String, dynamic>> onboardingData = [
    {"video": VideoPath.onboardingVideo1},
    {"video": VideoPath.onboardingVideo2},
    {"video": VideoPath.onboardingVideo3},
  ];

  @override
  void onInit() {
    super.onInit();
    selectedLanguage =
        (_languageService.locale.languageCode == 'ar' ? 'arabic' : 'english')
            .obs;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void changeLanguage(String language) {
    selectedLanguage.value = language;
    _languageService.updateLocale(language);
    Get.back(); // Close bottom sheet
  }

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      navigateToLogin();
    }
  }

  void skip() {
    navigateToLogin();
  }

  void navigateToLogin() {
    SharedPrefHelper.saveOnboardingCompleted(true);
    Get.offAll(() => LoginScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
