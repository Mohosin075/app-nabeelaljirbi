import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/feature/patient/filter/widget/patient_filter_bottom_sheet.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/controller/nearby_clinics_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/nearby_clinic_model.dart';

class PatientNearbyClinicScreen extends StatelessWidget {
  PatientNearbyClinicScreen({super.key});

  final NearbyClinicsController controller = Get.put(NearbyClinicsController());

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
            'nearby_clinics'.tr,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Divider(color: Color(0xFFF5F5F5), thickness: 1, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: _buildSearchField(context),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (controller.nearbyClinics.isEmpty) {
                    return Center(
                      child: Text(
                        'no_clinics_found'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        controller.nearbyClinics.length +
                        (controller.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == controller.nearbyClinics.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }
                      return _buildClinicResultCard(
                        controller.nearbyClinics[index],
                      );
                    },
                  );
                }),
              ),
            ],
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
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PatientFilterBottomSheet(
                  onApply: () => controller.fetchNearbyClinics(),
                ),
              );
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

  Widget _buildClinicResultCard(Clinic clinic) {
    return InkWell(
      onTap: () {
        debugPrint('Clinic ID: ${clinic.clinicUserId.toString()}');
        Get.toNamed(AppRoutes.clinicDetails, arguments: clinic.clinicUserId);
      },
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: clinic.logo != null && clinic.logo!.isNotEmpty
                    ? Image.network(
                        clinic.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            SvgPicture.asset(IconsPath.clinicIcon), // Fallback
                      )
                    : SvgPicture.asset(IconsPath.clinicIcon), // Placeholder
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          clinic.clinicName ?? 'unknown'.tr,
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff2d2d2d),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (clinic.platformSubscriptionActive == true) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ],
                    ],
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
                        '${clinic.specialistCount ?? 0} ${'specialties_count'.tr}',
                        style: globalTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff636F85),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xff636F85),
                        size: 16,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        IconsPath
                            .location, // Assuming hospital icon was used for location in previous code, checking imports... using location icon seems better if available, or stick to provided icon
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(clinic.distance ?? 0).toStringAsFixed(1)} ${'km'.tr}', // Display distance
                        style: globalTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff636F85),
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
