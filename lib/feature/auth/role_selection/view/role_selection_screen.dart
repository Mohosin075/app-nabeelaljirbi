import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/clinic/view/clinic_profile_setup_screen.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/doctor/view/doctor_profile_setup_screen.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/patient/view/patient_profile_setup_screen.dart';
import 'package:nabeelaljirbi_app/feature/auth/role_selection/controller/role_selection_controller.dart';

class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});
  final RoleSelectionController roleController = Get.put(
    RoleSelectionController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenHeight = constraints.maxHeight;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.06),
                  Text(
                    "choose_your_role".tr,
                    textAlign: TextAlign.center,
                    style: globalTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2D2D2D),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "role_selection_subtitle".tr,
                    textAlign: TextAlign.center,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff636F85),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Role Options
                  Obx(
                    () => Column(
                      children: [
                        _buildRoleOption(
                          context,
                          screenHeight: screenHeight,
                          selectedIcon: IconsPath.patientSelected,
                          unselectedIcon: IconsPath.patientUnselected,
                          title: "patient".tr,
                          isSelected:
                              roleController.selectedRole?.value == 'patient',
                          onTap: () => roleController.selectRole('patient'),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildRoleOption(
                          context,
                          screenHeight: screenHeight,
                          selectedIcon: IconsPath.doctorSelected,
                          unselectedIcon: IconsPath.doctorUnselected,
                          title: "doctor".tr,
                          isSelected:
                              roleController.selectedRole?.value == 'doctor',
                          onTap: () => roleController.selectRole('doctor'),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildRoleOption(
                          context,
                          screenHeight: screenHeight,
                          selectedIcon: IconsPath.clinicSelected,
                          unselectedIcon: IconsPath.clinicUnselected,
                          title: "clinic".tr,
                          isSelected:
                              roleController.selectedRole?.value == 'clinic',
                          onTap: () => roleController.selectRole('clinic'),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Continue Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            roleController.selectedRole?.value.isNotEmpty ==
                                true
                            ? () {
                                if (roleController.selectedRole!.value ==
                                    'doctor') {
                                  Get.to(() => DoctorProfileSetupScreen());
                                }
                                if (roleController.selectedRole!.value ==
                                    'patient') {
                                  Get.to(() => PatientProfileSetupScreen());
                                }
                                if (roleController.selectedRole!.value ==
                                    'clinic') {
                                  Get.to(() => ClinicProfileSetupScreen());
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "continue".tr,
                          style: globalTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required double screenHeight,
    required String selectedIcon,
    required String unselectedIcon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.04,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFCBD5E1),
          ),
          color: isSelected ? const Color(0xffE3F1FC) : Colors.white,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              isSelected ? selectedIcon : unselectedIcon,
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: globalTextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryColor
                    : const Color(0xff636F85),
              ),
            ),
            const Spacer(),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.primaryColor
                  : const Color(0xff636F85),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
