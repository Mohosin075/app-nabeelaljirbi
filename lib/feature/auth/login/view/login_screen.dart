import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final String? targetRole; // null = Patient (default), 'doctor' = Doctor, 'clinic' = Clinic
  const LoginScreen({super.key, this.targetRole});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.put(LoginController());

    if (targetRole != null && loginController.targetRole.value != targetRole) {
      loginController.targetRole.value = targetRole;
    }

    return Obx(() {
      final currentRole = loginController.targetRole.value;
      return PopScope(
        canPop: targetRole != null || currentRole == null,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (currentRole != null) {
            loginController.setTargetRole(null);
          }
        },
        child: Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenHeight = constraints.maxHeight;

          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final currentRole = loginController.targetRole.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (currentRole != null)
                                GestureDetector(
                                  onTap: () {
                                    if (targetRole != null) {
                                      Get.back();
                                    } else {
                                      loginController.setTargetRole(null);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SvgPicture.asset(
                                      IconsPath.backArrow,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),
                              GestureDetector(
                                onTap: () {
                                  _showLanguageBottomSheet(
                                    context,
                                    loginController,
                                  );
                                },
                                child: Text(
                                  loginController.selectedLanguage.value.tr,
                                  style: globalTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (currentRole == 'doctor') ...[
                            SizedBox(height: screenHeight * 0.03),
                            Center(
                              child: Container(
                                width: 72,
                                height: 72,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  IconsPath.doctorSelected,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                "doctor_portal".tr,
                                style: globalTextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2D2D2D),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                "doctor_login_subtitle".tr,
                                textAlign: TextAlign.center,
                                style: globalTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xff636F85),
                                ),
                              ),
                            ),
                          ] else if (currentRole == 'clinic') ...[
                            SizedBox(height: screenHeight * 0.03),
                            Center(
                              child: Container(
                                width: 72,
                                height: 72,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  IconsPath.clinicSelected,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                "clinic_portal".tr,
                                style: globalTextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2D2D2D),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                "clinic_login_subtitle".tr,
                                textAlign: TextAlign.center,
                                style: globalTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xff636F85),
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(height: screenHeight * 0.05),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 72,
                                  width: 72,
                                  child: SvgPicture.asset(IconsPath.appIcon),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Salama",
                                  style: globalTextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.04),
                            Center(
                              child: Text(
                                "slogan".tr,
                                textAlign: TextAlign.center,
                                style: globalTextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff2D2D2D),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                "patient_login_subtitle".tr,
                                textAlign: TextAlign.center,
                                style: globalTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xff636F85),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                    SizedBox(height: screenHeight * 0.04),
                    Text(
                      "phone_number".tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Phone Input Field with Country Selector
                    Form(
                      key: loginController.formKey,
                      child: Obx(() {
                        final bool isRtl = Get.locale?.languageCode == 'ar';
                        final countrySelector = GestureDetector(
                          onTap: () {
                            _showCountrySelector(context, loginController);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  loginController.selectedCountryFlag.value,
                                  height: 20,
                                  width: 30,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  loginController.selectedCountryCode.value,
                                  style: globalTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff2D2D2D),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        );

                        return TextFormField(
                          controller: loginController.phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          maxLength: loginController.requiredLength,
                          decoration: InputDecoration(
                            errorMaxLines: 2,
                            counterText: "",
                            hintText: "enter_phone_number".tr,
                            hintTextDirection: isRtl
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            prefixIcon: isRtl ? null : countrySelector,
                            suffixIcon: isRtl ? countrySelector : null,
                          ),
                          validator: (value) =>
                              loginController.validatePhone(value),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Choose how to receive code
                    Obx(
                      () => loginController.showMethodSelection
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "choose_code_method".tr,
                                  style: globalTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff2D2D2D),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(
                                        () => ElevatedButton(
                                          onPressed:
                                              loginController.toggleWhatsApp,
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor:
                                                loginController
                                                    .isWhatsAppSelected
                                                    .value
                                                ? const Color(0xffE3F1FC)
                                                : Colors.white,
                                            foregroundColor:
                                                loginController
                                                    .isWhatsAppSelected
                                                    .value
                                                ? AppColors.primaryColor
                                                : const Color(0xff636F85),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: BorderSide(
                                                color:
                                                    loginController
                                                        .isWhatsAppSelected
                                                        .value
                                                    ? AppColors.primaryColor
                                                    : const Color(0xffCBD5E1),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                IconsPath.whatsapp,
                                                height: 22,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "whatsapp".tr,
                                                style: globalTextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      loginController
                                                          .isWhatsAppSelected
                                                          .value
                                                      ? AppColors.primaryColor
                                                      : const Color(0xff636F85),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Obx(
                                        () => ElevatedButton(
                                          onPressed: loginController.toggleSMS,
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor:
                                                loginController
                                                    .isSMSSelected
                                                    .value
                                                ? const Color(0xffE3F1FC)
                                                : Colors.white,
                                            foregroundColor:
                                                loginController
                                                    .isSMSSelected
                                                    .value
                                                ? AppColors.primaryColor
                                                : const Color(0xff636F85),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: BorderSide(
                                                color:
                                                    loginController
                                                        .isSMSSelected
                                                        .value
                                                    ? AppColors.primaryColor
                                                    : const Color(0xffCBD5E1),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                IconsPath.sms,
                                                height: 20,
                                                colorFilter: ColorFilter.mode(
                                                  loginController
                                                          .isSMSSelected
                                                          .value
                                                      ? AppColors.primaryColor
                                                      : const Color(0xff636F85),
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "sms_code".tr,
                                                style: globalTextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      loginController
                                                          .isSMSSelected
                                                          .value
                                                      ? AppColors.primaryColor
                                                      : const Color(0xff636F85),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: loginController.isLoading.value
                              ? null
                              : () => loginController.sendOTP(
                                  targetRole:
                                      loginController.targetRole.value ??
                                      targetRole ??
                                      'patient',
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: AppColors.primaryColor
                                .withValues(alpha: 0.6),
                          ),
                          child: loginController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
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

                    // Legal Terms Note
                    const SizedBox(height: 14),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "terms_and_privacy_consent".tr,
                          textAlign: TextAlign.center,
                          style: globalTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff94A3B8),
                          ),
                        ),
                      ),
                    ),

                    Obx(() {
                      final currentRole = loginController.targetRole.value;
                      if (currentRole == null) {
                        return Column(
                          children: [
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: Color(0xFFE2E8F0)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    "healthcare_providers".tr,
                                    style: globalTextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: Color(0xFFE2E8F0)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildRoleCard(
                                    icon: IconsPath.doctorSelected,
                                    title: "doctor_login".tr,
                                    subtitle: "for_doctors".tr,
                                    onTap: () {
                                      loginController.setTargetRole('doctor');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildRoleCard(
                                    icon: IconsPath.clinicSelected,
                                    title: "clinic_login".tr,
                                    subtitle: "for_clinics".tr,
                                    onTap: () {
                                      loginController.setTargetRole('clinic');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  if (targetRole != null) {
                                    Get.back();
                                  } else {
                                    loginController.setTargetRole(null);
                                  }
                                },
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                  color: AppColors.primaryColor,
                                ),
                                label: Text(
                                  "back_to_patient_login".tr,
                                  style: globalTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    }),

                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
});
  }

  Widget _buildRoleCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(icon),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: globalTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(
    BuildContext context,
    LoginController controller,
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

  void _showCountrySelector(
    BuildContext context,
    LoginController loginController,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Material(
          color: AppColors.backgroundColor,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "select_country".tr,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: const Color(0xffE2E8F0), thickness: 1),
                  const SizedBox(height: 8),
                  Obx(
                    () => RadioGroup<String>(
                      groupValue: loginController.selectedCountryCode.value,
                      onChanged: (value) {
                        if (value != null) {
                          loginController.selectCountry(
                            value,
                            loginController.countries.firstWhere(
                              (c) => c['code'] == value,
                            )['name']!,
                            loginController.countries.firstWhere(
                              (c) => c['code'] == value,
                            )['flag']!,
                          );
                          Navigator.pop(context); // Close bottom sheet
                        }
                      },
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: loginController.countries.length,
                        itemBuilder: (context, index) {
                          final country = loginController.countries[index];
                          final isSelected =
                              loginController.selectedCountryCode.value ==
                              country['code'];
                          return ListTile(
                            onTap: () {
                              loginController.selectCountry(
                                country['code']!,
                                country['name']!,
                                country['flag']!,
                              );
                              Navigator.pop(context); // Close bottom sheet
                            },
                            leading: SvgPicture.asset(
                              country['flag']!,
                              height: 20,
                              width: 30,
                            ),
                            title: Text(
                              "${country['code']} (${country['name']!.tr})",
                              style: globalTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xff2D2D2D)
                                    : const Color(0xff636F85),
                              ),
                            ),
                            trailing: Radio<String>(
                              value: country['code']!,
                              activeColor: AppColors.primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
