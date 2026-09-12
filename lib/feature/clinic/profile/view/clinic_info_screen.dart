import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/clinic_edit_info_screen.dart';

class ClinicInfoScreen extends StatelessWidget {
  const ClinicInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'clinic_info'.tr,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clinic Logo with Camera Icon
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Image picking logic
                  },
                  child: Stack(
                    children: [
                      Obx(
                        () => Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xffF1F5F9),
                            border: Border.all(
                              color: const Color(0xffE2E8F0),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: controller.logo.value.isNotEmpty
                                ? Image.network(
                                    controller.logo.value,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.local_hospital,
                                        size: 50,
                                        color: Color(0xff94A3B8),
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.local_hospital,
                                    size: 50,
                                    color: Color(0xff94A3B8),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clinic Manager Info Section
                    Text(
                      'clinic_manager_info'.tr,
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'manager_name'.tr,
                            controller
                                    .clinicProfile
                                    .value
                                    ?.clinic
                                    ?.managerName ??
                                '',
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildInfoRow(
                            'manager_number'.tr,
                            controller
                                    .clinicProfile
                                    .value
                                    ?.clinic
                                    ?.managerPhone ??
                                '',
                            forceLtr: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Clinic Information Section
                    Text(
                      'clinic_information'.tr,
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'clinic_name'.tr,
                            controller
                                    .clinicProfile
                                    .value
                                    ?.clinic
                                    ?.clinicName ??
                                '',
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildInfoRow(
                            'clinic_number'.tr,
                            controller
                                    .clinicProfile
                                    .value
                                    ?.clinic
                                    ?.contactPhone ??
                                '',
                            forceLtr: true,
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildInfoRow(
                            'location'.tr,
                            controller.clinicProfile.value!.clinic!.location ??
                                '',
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildInfoRow(
                            'country'.tr,
                            controller.clinicProfile.value?.country ?? '',
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildInfoRow(
                            'city'.tr,
                            controller.clinicProfile.value?.city ?? '',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Subscription Information Section
                    if (controller.clinicProfile.value?.activeSubscription !=
                        null) ...[
                      Text(
                        'subscription_information'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'subscription_status'.tr,
                              (controller
                                          .clinicProfile
                                          .value!
                                          .activeSubscription!
                                          .active ??
                                      false)
                                  ? 'active'.tr
                                  : 'inactive'.tr,
                            ),
                            const Divider(color: Color(0xFFF1F5F9), height: 24),
                            _buildInfoRow(
                              'amount'.tr,
                              '${CurrencyUtil.getUserCurrencySymbol()} ${controller.clinicProfile.value!.activeSubscription!.amount ?? 0}',
                              forceLtr: true,
                            ),
                            const Divider(color: Color(0xFFF1F5F9), height: 24),
                            _buildInfoRow(
                              'card_number'.tr,
                              controller
                                      .clinicProfile
                                      .value!
                                      .activeSubscription!
                                      .card ??
                                  '',
                              forceLtr: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // About Clinic Section
                    Text(
                      'about_clinic'.tr,
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.clinicProfile.value?.clinic?.about ?? '',
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        lineHeight: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                //  height: 52,
                child: OutlinedButton(
                  onPressed: () => Get.to(() => const ClinicEditInfoScreen()),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildInfoRow(String label, String value, {bool forceLtr = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: globalTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Directionality(
            textDirection: forceLtr
                ? TextDirection.ltr
                : Directionality.of(Get.context!),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: forceLtr ? TextAlign.right : TextAlign.start,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
