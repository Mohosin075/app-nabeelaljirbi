import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_clinic_info_controller.dart';

import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';
import 'dart:ui' as ui;

class DoctorClinicInfoScreen extends StatelessWidget {
  const DoctorClinicInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorClinicInfoController());
    final profileController = Get.find<DoctorProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'clinic_information'.tr,
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
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final doctor = profileController.doctorProfile.value;
        final clinic = doctor?.doctor?.clinic;

        if (doctor == null) {
          return Center(child: Text('no_data_found'.tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffE5E9F2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic?.clinicName ?? 'na'.tr,
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                clinic?.logo ??
                                    'https://placehold.co/150.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            spacing: 6,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.fullName ?? 'na'.tr,
                                style: globalTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xff2d2d2d),
                                ),
                              ),
                              Row(
                                spacing: 8,
                                children: [
                                  const Icon(Icons.access_time, size: 20),
                                  Text(
                                    '${'joined_on'.tr}:',
                                    style: globalTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xff636F85),
                                    ),
                                  ),
                                  Text(
                                    _formatDate(doctor.doctor?.joinClinicDate),
                                    textDirection: ui.TextDirection.ltr,
                                    style: globalTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xff636F85),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(
                      icon: SvgPicture.asset(
                        IconsPath.location,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xff2d2d2d),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: 'location'.tr,
                      value: clinic?.location ?? 'na'.tr,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: const Icon(
                        Icons.phone,
                        color: Color(0xff2d2d2d),
                        size: 20,
                      ),
                      label: 'contact_number'.tr,
                      value: clinic?.contactPhone ?? 'na'.tr,
                      forceLtr: true,
                    ),
                    // const SizedBox(height: 16),
                    // _buildInfoRow(
                    //   icon: SvgPicture.asset(
                    //     IconsPath.calender,
                    //     width: 20,
                    //     height: 20,
                    //     colorFilter: const ColorFilter.mode(
                    //       Color(0xff2d2d2d),
                    //       BlendMode.srcIn,
                    //     ),
                    //   ),
                    //   label: 'joined_since'.tr,
                    //   value: _formatDate(doctor.doctor?.joinClinicDate),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showChangeClinicBottomSheet(context, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: SvgPicture.asset(IconsPath.switchIcon),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'change_clinic'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        IconsPath.downArrow,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showChangeClinicBottomSheet(
    BuildContext context,
    DoctorClinicInfoController controller,
  ) {
    Get.bottomSheet(
      Obx(
        () => Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller.searchController,
                    onSubmitted: (value) => controller.fetchClinics(),
                    decoration: InputDecoration(
                      hintText: 'search'.tr,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'choose_a_clinic'.tr,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }
                      if (controller.clinics.isEmpty) {
                        return Center(child: Text('no_clinics_found'.tr));
                      }
                      return ListView.separated(
                        controller: controller.scrollController,
                        itemCount:
                            controller.clinics.length +
                            (controller.isMoreLoading.value ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index < controller.clinics.length) {
                            final clinic = controller.clinics[index];
                            return GestureDetector(
                              onTap: () {
                                if (clinic.id != null) {
                                  controller.selectClinic(clinic.id!);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            clinic.logo ??
                                                'https://placehold.co/150.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            clinic.clinicName ?? 'na'.tr,
                                            style: globalTextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xff2D2D2D),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.group,
                                                size: 14,
                                                color: Color(0xFF64748B),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                ' ${clinic.numberOfClinicSpecialist ?? 0} ',
                                                textDirection:
                                                    ui.TextDirection.ltr,
                                                style: globalTextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'specialists'.tr,
                                                style: globalTextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.phone,
                                                size: 14,
                                                color: AppColors.primaryColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                clinic.contact ?? 'na'.tr,
                                                textDirection:
                                                    ui.TextDirection.ltr,
                                                style: globalTextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            if (controller.isUpdating.value)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return 'na'.tr;
    try {
      final cleanDate = dateStr.trim();
      final dt = DateTime.tryParse(cleanDate) ?? DateTime.parse(cleanDate);

      // Manual localization logic as preferred by the user
      // Specifying 'en' locale ensures DateFormat always returns 'mon', 'tue', 'jan', etc.
      // which match the keys in language_strings.dart.
      final dayName = DateFormat('E', 'en').format(dt).toLowerCase();
      final monthName = DateFormat('MMM', 'en').format(dt).toLowerCase();
      final day = dt.day;
      final year = dt.year;

      return "${dayName.tr}, ${monthName.tr} $day, $year";
    } catch (e) {
      debugPrint("FORMAT_DATE_ERROR: $dateStr -> $e");
      return dateStr;
    }
  }

  Widget _buildInfoRow({
    required Widget icon,
    required String label,
    required String value,
    bool forceLtr = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xff8D8D8D).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: globalTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff636F85),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                textDirection: forceLtr ? ui.TextDirection.ltr : null,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff2D2D2D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
