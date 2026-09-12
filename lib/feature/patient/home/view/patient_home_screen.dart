import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';

import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/patient/ai_chat/controller/ai_chat_controller.dart';

import 'package:nabeelaljirbi_app/feature/patient/clinic_details/view/clinic_details_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/view/doctor_details_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/view/patient_nearby_clinic_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/view/patient_popular_doctor_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/widget/banner_slider.dart';

import 'package:nabeelaljirbi_app/feature/patient/home/model/popular_doctor_model.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/controller/popular_doctors_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/nearby_clinic_model.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/controller/nearby_clinics_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/controller/banner_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/nav_bar/controller/patient_nav_bar_controller.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final PopularDoctorsController popularDoctorsController = Get.put(
    PopularDoctorsController(),
  );
  final NearbyClinicsController nearbyClinicsController = Get.put(
    NearbyClinicsController(),
  );
  final BannerController bannerController = Get.put(BannerController());
  final PatientProfileController profileController = Get.put(
    PatientProfileController(),
  );
  final AiChatController aiChatController = Get.put(AiChatController());

  // @override
  // void initState() {
  //   super.initState();
  //   Check premium status after profile is loaded
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _checkPremiumStatus();
  //   });
  // }

  // void _checkPremiumStatus() async {
  //   // Wait for profile to be loaded first
  //   // Check if profile is already loaded
  //   if (profileController.patientProfile.value != null) {
  //     // Profile already loaded, check immediately
  //     if (!profileController.isPremiumUser) {
  //       profileController.checkPremiumAccess();
  //     }
  //   } else {
  //     // Profile not loaded yet, wait for it
  //     // Use ever to listen for profile changes
  //     final worker = ever(profileController.patientProfile, (profile) {
  //       if (profile != null && !profileController.isPremiumUser) {
  //         profileController.checkPremiumAccess();
  //       }
  //     });

  //     // Dispose the worker after first check
  //     Future.delayed(const Duration(seconds: 3), () {
  //       worker.dispose();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 1.0),
          child: SvgPicture.asset(IconsPath.appIcon, width: 40, height: 40),
        ),
        title: Text(
          'Salama',
          style: globalTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
        actions: [
          Obx(
            () => SvgPicture.asset(
              profileController.getSelectedCountrySvg(),
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor,

          onRefresh: () async {
            await Future.wait([
              popularDoctorsController.fetchPopularDoctors(),
              nearbyClinicsController.fetchNearbyClinics(),
              bannerController.fetchBanners(),
              profileController.fetchProfile(),
              aiChatController.getConfig(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //_buildHeader(),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildPromoBanner(),
                  const SizedBox(height: 20),
                  _buildAIAssistantCard(),
                  const SizedBox(height: 24),
                  _buildCategories(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('popular_doctors'.tr, () {
                    Get.to(() => PatientPopularDoctorScreen());
                  }),
                  const SizedBox(height: 16),
                  _buildPopularDoctors(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('nearby_clinics'.tr, () {
                    Get.to(() => PatientNearbyClinicScreen());
                  }),
                  const SizedBox(height: 16),
                  _buildNearbyClinics(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildHeader() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Row(
  //         children: [
  //           SvgPicture.asset(IconsPath.appIcon, width: 40, height: 40),
  //           const SizedBox(width: 8),
  //           // Text(
  //           //   'app_name'.tr,
  //           //   style: globalTextStyle(
  //           //     fontSize: 26,
  //           //     fontWeight: FontWeight.w700,
  //           //     color: AppColors.primaryColor,
  //           //   ),
  //           // ),
  //           Text(
  //             'Salama',
  //             style: globalTextStyle(
  //               fontSize: 26,
  //               fontWeight: FontWeight.w700,
  //               color: AppColors.primaryColor,
  //             ),
  //           ),
  //         ],
  //       ),
  //       Obx(
  //         () => SvgPicture.asset(
  //           profileController.getSelectedCountrySvg(),
  //           width: 24,
  //           height: 24,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.patientSearch),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E9F2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'find_doctors_hint'.tr,
                    hintStyle: globalTextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SvgPicture.asset(
              IconsPath.searchIcon,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Obx(() {
      if (bannerController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }
      if (bannerController.banners.isEmpty) {
        return const SizedBox.shrink();
      }
      final mediaUrls = bannerController.banners
          .where((b) => b.image != null)
          .map((b) => b.image!)
          .toList();

      if (mediaUrls.isEmpty) return const SizedBox.shrink();

      return BannerSlider(mediaUrls: mediaUrls);
    });
  }

  Widget _buildAIAssistantCard() {
    return GestureDetector(
      onTap: () {
        Get.find<PatientNavBarController>().changeTab(2);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'health_ai_assistant'.tr,
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ai_assistant_desc'.tr,
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff636F85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(IconsPath.healthAiAssistant, width: 100, height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': 'doctor', 'icon': IconsPath.doctorIcon},
      {'name': 'clinic', 'icon': IconsPath.clinicIcon},
      {'name': 'tunisia', 'icon': IconsPath.tunisia},
      {'name': 'egypt', 'icon': IconsPath.egypt},
      {'name': 'ambulance', 'icon': IconsPath.ambulanceIcon},
      {'name': 'pharmacy', 'icon': IconsPath.pharmacy},
      {'name': 'consultation', 'icon': IconsPath.consultation},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: GestureDetector(
              onTap: () {
                final name = cat['name'];
                if (name == 'doctor') {
                  Get.toNamed(AppRoutes.patientSearch, arguments: {'tab': 0});
                } else if (name == 'clinic') {
                  Get.toNamed(AppRoutes.patientSearch, arguments: {'tab': 1});
                } else if (name == 'tunisia') {
                  Get.toNamed(
                    AppRoutes.patientSearch,
                    arguments: {'country': 'Tunisia'},
                  );
                } else if (name == 'egypt') {
                  Get.toNamed(
                    AppRoutes.patientSearch,
                    arguments: {'country': 'Egypt'},
                  );
                } else {
                  Get.snackbar(
                    'coming_soon'.tr,
                    'Feature coming soon'.tr,
                    backgroundColor: AppColors.primaryColor,
                    colorText: Colors.white,
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F1FC),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      cat['icon']!,
                      width: 26,
                      height: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name']!.tr,
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'view_all'.tr,
            style: globalTextStyle(color: AppColors.primaryColor, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyClinics() {
    return Obx(() {
      if (nearbyClinicsController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }
      if (nearbyClinicsController.nearbyClinics.isEmpty) {
        return const SizedBox.shrink();
      }
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: nearbyClinicsController.nearbyClinics.take(10).map((
            clinic,
          ) {
            return GestureDetector(
              onTap: () {
                Get.to(
                  () => ClinicDetailsScreen(),
                  arguments: clinic.clinicUserId,
                );
              },
              child: _buildNearbyClinicCard(clinic),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildNearbyClinicCard(Clinic clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: clinic.logo != null && clinic.logo!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: clinic.logo!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          SvgPicture.asset(IconsPath.clinicIcon),
                    )
                  : SvgPicture.asset(IconsPath.clinicIcon),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            // Added Expanded
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        clinic.clinicName ?? 'unknown'.tr,
                        style: globalTextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (clinic.platformSubscriptionActive == true) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: Colors.blue),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(
                      IconsPath.specialties,
                      height:
                          14, // Adjusted size to match PatientNearbyClinicScreen (14 vs 18)
                      width: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${clinic.specialistCount ?? 0} ${'specialties_count'.tr}',
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff636F85),
                      ),
                    ),
                    const Spacer(), // Added Spacer
                    const Icon(
                      // Added Arrow Icon
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xff636F85),
                      size: 16,
                    ),
                  ],
                ),
                // Removed SizedBox(height: 4.5) to match PatientNearbyClinicScreen
                Row(
                  children: [
                    SvgPicture.asset(
                      IconsPath.location,
                      height:
                          14, // Adjusted size to match PatientNearbyClinicScreen (14 vs 18)
                      width: 14,
                      colorFilter: const ColorFilter.mode(
                        Colors
                            .grey, // Changed color to match PatientNearbyClinicScreen
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(clinic.distance ?? 0).toStringAsFixed(1)} ${'km'.tr}',
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
    );
  }

  Widget _buildPopularDoctors() {
    return Obx(() {
      if (popularDoctorsController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }
      if (popularDoctorsController.popularDoctors.isEmpty) {
        return const SizedBox.shrink();
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: popularDoctorsController.popularDoctors.take(10).map((
            doctor,
          ) {
            return GestureDetector(
              onTap: () {
                Get.to(() => DoctorDetailsScreen(), arguments: doctor.doctorId);
              },
              child: _buildDoctorCard(doctor),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  //sdfdf
                  if (doctor.profileImage != null &&
                      doctor.profileImage!.isNotEmpty)
                    Image.network(
                      doctor.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF5F8FF),
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFF5F8FF),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: const Color(0xFFF5F8FF),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_outline_rounded,
                            size: 12,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${doctor.experience ?? 0} ${'year_exp'.tr}',
                            style: globalTextStyle(
                              fontSize: 10,
                              color: const Color(0xff2D2D2D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.specialty ?? '',
                  style: globalTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.name ?? 'unknown'.tr,
                  style: globalTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${'from'.tr} ${doctor.city?.tr ?? ''}',
                  style: globalTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff636F85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(IconsPath.star, width: 14, height: 14),
                        Text(
                          ' ${doctor.rating ?? 0}',
                          style: globalTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff2d2d2d),
                          ),
                        ),
                        Text(
                          ' (${doctor.reviewCount ?? 0})',
                          style: globalTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff2d2d2d),
                          ),
                        ),
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${doctor.fee ?? 0}",
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff2D2D2D),
                            ),
                          ),
                          TextSpan(
                            text: ' ${CurrencyUtil.getUserCurrencySymbol()}',
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff636F85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
