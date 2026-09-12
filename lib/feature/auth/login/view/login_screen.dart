import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/controller/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.put(LoginController());

    return Scaffold(
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
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          _showLanguageBottomSheet(context, loginController);
                        },
                        child: Obx(
                          () => Text(
                            loginController.selectedLanguage.value.tr,
                            style: globalTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        SizedBox(
                          height: 72,
                          width: 72,
                          child: SvgPicture.asset(IconsPath.appIcon),
                        ),
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

                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      "slogan".tr,
                      textAlign: TextAlign.center,
                      style: globalTextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2D2D2D),
                      ),
                    ),
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
                              : () => loginController.sendOTP(),
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

                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          );
        },
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
