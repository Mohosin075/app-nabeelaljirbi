import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/service/legal_service.dart';

class ClinicNavBarController extends GetxController {
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        LegalService.checkAndPromptReacceptance(Get.context!);
      }
    });
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
