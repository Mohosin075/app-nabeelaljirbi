import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/feature/clinic/appointment/view/clinic_appointment_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/doctors/view/clinic_doctor_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/home/view/clinic_home_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/nav_bar/widget/clinic_custom_nav_bar.dart';
import 'package:nabeelaljirbi_app/feature/clinic/wallet/view/clinic_wallet_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_profile_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/nav_bar/controller/clinic_nav_bar_controller.dart';

class ClinicNavBarScreen extends StatelessWidget {
  ClinicNavBarScreen({super.key});

  final ClinicNavBarController controller = Get.put(ClinicNavBarController());

  List<Widget> get pages => [
    ClinicHomeScreen(),
    ClinicAppointmentScreen(),
    ClinicDoctorScreen(),
    ClinicWalletScreen(),
    ClinicProfileScreen(),
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
          body: controller.currentIndex.value < pages.length
              ? pages[controller.currentIndex.value]
              : const Center(child: Text("Page not found")),
          bottomNavigationBar: ClinicCustomNavBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }
}
