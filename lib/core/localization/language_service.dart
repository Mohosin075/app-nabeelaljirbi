import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';

class LanguageService extends GetxService {
  final _locale = const Locale('ar', 'SA').obs;

  Locale get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();
    final savedLang = SharedPrefHelper.getLanguage();
    if (savedLang != null) {
      if (savedLang == 'arabic') {
        _locale.value = const Locale('ar', 'SA');
      } else {
        _locale.value = const Locale('en', 'US');
      }
    }
  }

  void updateLocale(String languageCode) {
    if (languageCode == 'arabic') {
      _locale.value = const Locale('ar', 'SA');
    } else {
      _locale.value = const Locale('en', 'US');
    }
    SharedPrefHelper.saveLanguage(languageCode);
    Get.updateLocale(_locale.value);
  }

  bool get isRTL => _locale.value.languageCode == 'ar';
}
