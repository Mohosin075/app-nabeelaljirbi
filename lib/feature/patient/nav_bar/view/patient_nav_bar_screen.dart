import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/feature/patient/ai_chat/view/ai_chat_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/view/my_appointment_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/view/patient_home_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/nav_bar/controller/patient_nav_bar_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/nav_bar/widget/patient_custom_nav_bar.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/view/patient_profile_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/wallet/view/patient_wallet_screen.dart';

class PatientNavBarScreen extends StatelessWidget {
  PatientNavBarScreen({super.key});

  final PatientNavBarController controller = Get.put(PatientNavBarController());

  final List<Widget> pages = [
    PatientHomeScreen(),
    MyAppointmentScreen(),
    AiChatScreen(),
    PatientWalletScreen(),
    PatientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: controller.currentIndex.value == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.changeTab(0);
        },
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBgColor,
          body: pages[controller.currentIndex.value],
          bottomNavigationBar: PatientCustomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }
}
