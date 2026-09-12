import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_info_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_specialties_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_photos_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_insurance_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_referral_program_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_help_center_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_legal_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ClinicProfileScreen extends StatelessWidget {
  const ClinicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClinicProfileController());

    return Scaffold(
      backgroundColor: Color(0xffE5E9F2).withValues(alpha: 0.4),
      appBar: AppBar(
        title: Text(
          'profile'.tr,
          style: globalTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2D2D2D),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.clinicProfile.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xff137CCF)),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchClinicProfile(),
          color: AppColors.primaryColor,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Profile Header
                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xffF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: controller.logo.value.isNotEmpty
                                ? Image.network(
                                    controller.logo.value,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.local_hospital,
                                        size: 40,
                                        color: Color(0xff94A3B8),
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.local_hospital,
                                    size: 40,
                                    color: Color(0xff94A3B8),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller
                                              .clinicProfile
                                              .value
                                              ?.clinic
                                              ?.clinicName ??
                                          '',
                                      style: globalTextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xff101010),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (controller
                                          .clinicProfile
                                          .value
                                          ?.platformSubscriptionActive ==
                                      true) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${controller.clinicProfile.value?.clinic?.averageRating ?? ''}',
                                    style: globalTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff2D2D2D),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${controller.clinicProfile.value?.clinic?.reviewCount ?? ''})',
                                    style: globalTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${'service_fee'.tr}: ${controller.clinicProfile.value?.serviceFree ?? ''} ${CurrencyUtil.getUserCurrencySymbol()}',
                                style: globalTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff101010),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Material(
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: IconsPath.profile,
                          title: 'clinic_info'.tr,
                          onTap: () {
                            Get.to(() => ClinicInfoScreen());
                          },
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        _buildMenuItem(
                          icon: IconsPath.stethoscope,
                          title: 'specialties'.tr,
                          onTap: () {
                            Get.to(() => ClinicSpecialtiesScreen());
                          },
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        _buildMenuItem(
                          icon: IconsPath.photos,
                          title: 'clinic_photos'.tr,
                          onTap: () {
                            Get.to(() => ClinicPhotosScreen());
                          },
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        _buildMenuItem(
                          icon: IconsPath.insurance,
                          title: 'insurance'.tr,
                          onTap: () {
                            Get.to(() => ClinicInsuranceScreen());
                          },
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        _buildMenuItem(
                          icon: IconsPath.referral,
                          title: 'refer'.tr,
                          onTap: () {
                            Get.to(() => ClinicReferralProgramScreen());
                          },
                          hasSubtitle: true,
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        Obx(
                          () => _buildMenuItemWithFlag(
                            icon: IconsPath.country,
                            title: 'country'.tr,
                            flagIcon: controller.getSelectedCountryFlag(),
                            onTap: () {},
                          ),
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        Obx(
                          () => _buildMenuItem(
                            icon: IconsPath.language,
                            title: 'language'.tr,
                            trailingText: controller.selectedLanguage.value.tr,
                            onTap: () =>
                                _showLanguageBottomSheet(context, controller),
                          ),
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        _buildMenuItem(
                          icon: IconsPath.help,
                          title: 'help_center'.tr,
                          onTap: () {
                            Get.to(() => ClinicHelpCenterScreen());
                          },
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        _buildMenuItem(
                          icon: IconsPath.legalAndPolicies,
                          title: 'legal_and_policies'.tr,
                          onTap: () {
                            Get.to(() => ClinicLegalScreen());
                          },
                        ),
                        const Divider(color: Color(0xffF3F4F6)),
                        _buildMenuItem(
                          icon: IconsPath.feedback,
                          title: 'send_feedback'.tr,
                          onTap: () {
                            String url = '';
                            if (Platform.isAndroid) {
                              url =
                                  'https://play.google.com/store/apps/details?id=com.nabeelaljirbi.salama';
                            } else if (Platform.isIOS) {
                              url = 'https://apps.apple.com';
                            }

                            if (url.isNotEmpty) {
                              launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                InkWell(
                  onTap: controller.logout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: const Color(0xffFF4D4F),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'log_out'.tr,
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xffFF4D4F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: controller.deleteAccount,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_forever_outlined,
                          color: const Color(0xffFF4D4F),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'delete_account'.tr,
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xffFF4D4F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    bool hasSubtitle = false,
    bool hasTrailingIcon = true,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: SvgPicture.asset(icon, width: 24, height: 24),
      title: Text(
        title,
        style: globalTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xff2D2D2D),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                trailingText,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff636F85),
                ),
              ),
            ),
          if (hasTrailingIcon)
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xff94A3B8),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItemWithFlag({
    required String icon,
    required String title,
    required String flagIcon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: SvgPicture.asset(icon, width: 24, height: 24),
      title: Text(
        title,
        style: globalTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xff2D2D2D),
        ),
      ),
      trailing: SvgPicture.asset(flagIcon, width: 30, height: 20),
    );
  }

  void _showLanguageBottomSheet(
    BuildContext context,
    ClinicProfileController controller,
  ) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffE5E9F2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'language'.tr,
                style: globalTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff2D2D2D),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: Obx(
                  () => RadioGroup<String>(
                    groupValue: controller.selectedLanguage.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeLanguage(value);
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: controller.languages
                            .map(
                              (language) => InkWell(
                                onTap: () =>
                                    controller.changeLanguage(language),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          language.tr,
                                          style: globalTextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xff2D2D2D),
                                          ),
                                        ),
                                      ),
                                      Radio<String>(
                                        value: language,
                                        activeColor: const Color(0xff137CCF),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
