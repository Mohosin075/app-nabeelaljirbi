import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/view/doctor_edit_profile_screen.dart';

class DoctorProfileInfoScreen extends StatelessWidget {
  const DoctorProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorProfileController>();

    return Scaffold(
      backgroundColor: Color(0xfff8f9fa),
      appBar: AppBar(
        title: Text(
          'profile_info'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2D2D2D),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(IconsPath.backArrow),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // Profile Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xffF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: controller.profileImage.value.isNotEmpty
                              ? Image.network(
                                  controller.profileImage.value,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xff94A3B8),
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xff94A3B8),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildReadOnlyField(
                        label: 'full_name'.tr,
                        value: controller.name.value,
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'gender'.tr,
                        value:
                            controller.doctorProfile.value?.gender
                                ?.toLowerCase()
                                .tr ??
                            '',
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'date_of_birth'.tr,
                        value: (() {
                          final dob =
                              controller.doctorProfile.value?.dateOfBirth;
                          if (dob == null) return '';

                          // Manual localization logic
                          final dayName = DateFormat(
                            'E',
                          ).format(dob).toLowerCase();
                          final monthName = DateFormat(
                            'MMM',
                          ).format(dob).toLowerCase();
                          final day = dob.day;
                          final year = dob.year;

                          return "${dayName.tr}, ${monthName.tr} $day, $year";
                        })(),
                        forceLtr: true,
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'city'.tr,
                        value: controller.doctorProfile.value?.city ?? '',
                      ),
                      const SizedBox(height: 16),

                      _buildReadOnlyField(
                        label: 'address_details'.tr,
                        value: controller.doctorProfile.value?.address ?? '',
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'medical_specialty'.tr,
                        value: controller.role.value.tr,
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'years_of_experience'.tr,
                        value:
                            '${controller.doctorProfile.value?.doctor?.experience ?? '0'} ${'years'.tr}',
                        forceLtr: true,
                      ),
                      const SizedBox(height: 16),

                      _buildReadOnlyField(
                        label: 'license_number'.tr,
                        value:
                            controller
                                .doctorProfile
                                .value
                                ?.doctor
                                ?.licenseNumber ??
                            '',
                        forceLtr: true,
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'base_consultation_fee'.tr,
                        value:
                            controller.doctorProfile.value?.doctor?.consultFee
                                ?.toString() ??
                            '0',
                        suffix: CurrencyUtil.getUserCurrencySymbol(),
                        forceLtr: true,
                      ),
                      const SizedBox(height: 16),
                      // Biography Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'biography'.tr,
                            style: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (controller
                                      .doctorProfile
                                      .value
                                      ?.doctor
                                      ?.biography !=
                                  null &&
                              controller
                                  .doctorProfile
                                  .value!
                                  .doctor!
                                  .biography!
                                  .isNotEmpty)
                            Container(
                              width: double.infinity,
                              height: 220,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xff94A3B8),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  controller
                                      .doctorProfile
                                      .value!
                                      .doctor!
                                      .biography!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.description,
                                            size: 44,
                                            color: Color(0xff94A3B8),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'unable_to_preview_file'.tr,
                                            style: globalTextStyle(
                                              fontSize: 14,
                                              color: const Color(0xff94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xff94A3B8),
                                ),
                              ),
                              child: Text(
                                'not_uploaded'.tr,
                                style: globalTextStyle(
                                  fontSize: 14,
                                  color: const Color(0xff94A3B8),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => const DoctorEditProfileScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xfff8f9fa),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          child: Text(
                            'edit_profile'.tr,
                            style: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    String? suffix,
    bool forceLtr = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xff2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xff94A3B8)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  textDirection: forceLtr ? ui.TextDirection.ltr : null,
                  style: globalTextStyle(
                    fontSize: 14,
                    color: const Color(0xff2D2D2D),
                  ),
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    suffix,
                    style: globalTextStyle(
                      fontSize: 14,
                      color: const Color(0xff636F85),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
