import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/view/patient_edit_profile_screen.dart';

class PatientProfileInfoScreen extends StatelessWidget {
  const PatientProfileInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientProfileController>();

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
                                      size: 40,
                                      color: Color.fromARGB(255, 132, 153, 182),
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color.fromARGB(255, 132, 153, 182),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildReadOnlyField(
                        label: 'full_name'.tr,
                        value:
                            controller.patientProfile.value?.user?.fullName ??
                            '',
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'gender'.tr,
                        value:
                            (controller.patientProfile.value?.user?.gender ??
                                    '')
                                .toLowerCase()
                                .tr,
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'date_of_birth'.tr,
                        value:
                            controller
                                    .patientProfile
                                    .value
                                    ?.user
                                    ?.dateOfBirth !=
                                null
                            ? '${controller.patientProfile.value!.user!.dateOfBirth!.year}-${controller.patientProfile.value!.user!.dateOfBirth!.month.toString().padLeft(2, '0')}-${controller.patientProfile.value!.user!.dateOfBirth!.day.toString().padLeft(2, '0')}'
                            : '',
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'city'.tr,
                        value:
                            controller.patientProfile.value?.user?.city ?? '',
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'address_details'.tr,
                        value:
                            controller.patientProfile.value?.user?.address ??
                            '',
                      ),
                      const SizedBox(height: 24),
                      // Subscription Information Section
                      if (controller.patientProfile.value?.activeSubscription !=
                          null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                border: Border.all(
                                  color: const Color(0xff94A3B8),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _buildSubscriptionRow(
                                    'subscription_status'.tr,
                                    (controller
                                                .patientProfile
                                                .value!
                                                .activeSubscription!
                                                .active ??
                                            false)
                                        ? 'active'.tr
                                        : 'inactive'.tr,
                                  ),
                                  const Divider(
                                    color: Color(0xFFF1F5F9),
                                    height: 24,
                                  ),
                                  _buildSubscriptionRow(
                                    'amount'.tr,
                                    '${CurrencyUtil.getUserCurrencySymbol()} ${controller.patientProfile.value!.activeSubscription!.amount ?? 0}',
                                    forceLtr: true,
                                  ),
                                  const Divider(
                                    color: Color(0xFFF1F5F9),
                                    height: 24,
                                  ),
                                  _buildSubscriptionRow(
                                    'card_number'.tr,
                                    controller
                                            .patientProfile
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
                        ),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => const PatientEditProfileScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Color(0xfff8f9fa),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.primaryColor),
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

  Widget _buildSubscriptionRow(
    String label,
    String value, {
    bool forceLtr = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
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

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    String? suffix,
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
