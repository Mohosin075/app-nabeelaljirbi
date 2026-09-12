import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/feature/doctor/home/view/doctor_home_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/appointment/view/doctor_appointment_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/wallet/view/doctor_wallet_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/view/doctor_profile_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/nav_bar/controller/doctor_nav_bar_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/nav_bar/widget/doctor_custom_nav_bar.dart';

class DoctorNavBarScreen extends StatelessWidget {
  DoctorNavBarScreen({super.key});

  final DoctorNavBarController controller = Get.put(DoctorNavBarController());

  final List<Widget> pages = [
    const DoctorHomeScreen(),
    const DoctorAppointmentScreen(),
    const DoctorWalletScreen(),
    const DoctorProfileScreen(),
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
          bottomNavigationBar: DoctorCustomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }
}
