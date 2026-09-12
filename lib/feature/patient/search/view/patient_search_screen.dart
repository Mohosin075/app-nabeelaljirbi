import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/patient/filter/widget/patient_filter_bottom_sheet.dart';
import 'package:nabeelaljirbi_app/feature/patient/search/controller/patient_search_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/popular_doctor_model.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/nearby_clinic_model.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/specialist_model.dart';

class PatientSearchScreen extends StatelessWidget {
  PatientSearchScreen({super.key});

  final PatientSearchController controller = Get.put(PatientSearchController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          controller.resetAndFetch();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              IconsPath.backArrow,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              controller.resetAndFetch();
              Get.back();
            },
          ),
          title: Text(
            'search'.tr,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  color: Color(0xFFF5F5F5),
                  thickness: 1,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(context),
                      if (controller.selectedSpecialty.value != null) ...[
                        const SizedBox(height: 12),
                        _buildSelectedSpecialtyChip(),
                      ],
                    ],
                  ),
                ),
                if (controller.searchQuery.isEmpty &&
                    !controller.isFilterActive) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'most_popular_specialties'.tr,
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SafeArea(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.filteredSpecialties.length,
                        separatorBuilder: (context, index) => const Divider(
                          color: Color(0xFFF5F5F5),
                          thickness: 1,
                          height: 32,
                        ),
                        itemBuilder: (context, index) {
                          final specialty =
                              controller.filteredSpecialties[index];
                          return _buildSpecialtyItem(specialty);
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  _buildCustomTabBar(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '${'results'.tr} (${controller.selectedTab.value == 0 ? controller.filteredDoctors.length : controller.filteredClinics.length})',
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.selectedTab.value == 0
                          ? controller.filteredDoctors.length
                          : controller.filteredClinics.length,
                      itemBuilder: (context, index) {
                        if (controller.selectedTab.value == 0) {
                          return _buildDoctorResultCard(
                            controller.filteredDoctors[index],
                          );
                        } else {
                          return _buildClinicResultCard(
                            controller.filteredClinics[index],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSpecialtyChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            controller.selectedSpecialty.value!.name?.tr ?? '',
            style: globalTextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => controller.deselectSpecialty(),
            child: const Icon(Icons.close, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              '${'doctors'.tr} (${controller.filteredDoctors.length})',
              0,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              '${'clinics'.tr} (${controller.filteredClinics.length})',
              1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: globalTextStyle(
              color: isSelected ? Colors.white : const Color(0xff636F85),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            IconsPath.searchIcon,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xff636F85),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) => controller.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'search'.tr,
                hintStyle: globalTextStyle(
                  color: const Color(0xff636F85),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PatientFilterBottomSheet(),
              );
              controller.performSearch();
            },
            child: SvgPicture.asset(
              IconsPath.filter,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xff636F85),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyItem(SpecialistModel specialty) {
    return InkWell(
      onTap: () => controller.selectSpecialty(specialty),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                specialty.image ?? '',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                  IconsPath.stethoscope,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              specialty.name?.tr ?? '',
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: const Color(0xff636F85),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorResultCard(Doctor doctor) {
    // Map Doctor model to UI
    final image = doctor.profileImage ?? '';
    final name = doctor.name ?? 'unknown'.tr;
    final fee = doctor.fee?.toString() ?? '0';
    final specialty = doctor.specialty ?? 'General';
    final exp = doctor.experience ?? '-';
    // 'hospital' and 'availability' fields are missing in Doctor model based on earlier view.
    // We will use placeholders or derived info.
    final hospital = doctor.city ?? ''; // Using city as location placeholder
    final rating = doctor.rating?.toString() ?? '0.0';
    final reviews = doctor.reviewCount?.toString() ?? '0';

    return InkWell(
      onTap: () {
        // Pass only the ID as a string, as expected by DoctorDetailsController
        Get.toNamed(
          AppRoutes.doctorDetails,
          arguments: doctor.doctorId ?? doctor.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: globalTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: fee,
                                  style: globalTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' ${CurrencyUtil.getUserCurrencySymbol()}',
                                  style: globalTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        specialty.tr,
                        style: globalTextStyle(
                          fontSize: 13,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        '$exp ${'year_exp'.tr}',
                        style: globalTextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                SvgPicture.asset(
                  IconsPath.location,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xff636F85),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    hospital,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(IconsPath.star, width: 14, height: 14),
                    const SizedBox(width: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: rating,
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: ' ($reviews)',
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'available'.tr, // Placeholder
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Get.toNamed(AppRoutes.bookingScreen or something?);
                    Get.toNamed(
                      AppRoutes.doctorDetails,
                      arguments: doctor.doctorId ?? doctor.id,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'book'.tr,
                    style: globalTextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicResultCard(Clinic clinic) {
    final name = clinic.clinicName ?? 'unknown'.tr;
    final logo = clinic.logo ?? ''; // Assuming URL
    final specialties =
        '${clinic.specialistCount ?? 0} ${'specialties_count'.tr}';
    final location = clinic.distance != null
        ? '${clinic.distance!.toStringAsFixed(1)} ${'distance_away'.tr}'
        : 'location_info_unavailable'.tr;

    return InkWell(
      onTap: () =>
          Get.toNamed(AppRoutes.clinicDetails, arguments: clinic.clinicUserId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  logo,
                  errorBuilder: (context, error, stackTrace) =>
                      SvgPicture.asset('assets/icons/app_icon.svg'), // Fallback
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        IconsPath.specialties,
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        specialties,
                        style: globalTextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        IconsPath.hospital,
                        width: 14,
                        height: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: globalTextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
  }
}
