import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/controller/otp_verification_controller.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/controller/login_controller.dart';
import 'package:pinput/pinput.dart';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key});
  final LoginController loginController = Get.find<LoginController>();
  final OtpVerificationController otpController = Get.put(
    OtpVerificationController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text(
                  'enter_verification_code'.tr,
                  textAlign: TextAlign.center,
                  style: globalTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2D2D2D),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${'verification_code_message'.tr} ${loginController.selectedCountryCode.value} ${loginController.phoneController.text.length > 3 ? '*' * (loginController.phoneController.text.length - 3) + loginController.phoneController.text.substring(loginController.phoneController.text.length - 3) : loginController.phoneController.text}.",
                  textAlign: TextAlign.center,
                  style: globalTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff636F85),
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Input Field
                Obx(
                  () => Column(
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          length: 6,
                          controller: otpController.otpController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (otpController.otpError.value.isNotEmpty) {
                              otpController.otpError.value = '';
                            }
                          },
                          defaultPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            textStyle: globalTextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: otpController.otpError.value.isNotEmpty
                                    ? Colors.red
                                    : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            textStyle: globalTextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          errorPinTheme: PinTheme(
                            width: 60,
                            height: 60,
                            textStyle: globalTextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                          ),
                        ),
                      ),
                      if (otpController.otpError.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            otpController.otpError.value,
                            style: globalTextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Resend Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "didnt_receive_code".tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff636F85),
                      ),
                    ),
                    Obx(
                      () => GestureDetector(
                        onTap:
                            (otpController.isResendEnabled.value &&
                                !otpController.isResending.value)
                            ? otpController.resendCode
                            : null,
                        child: otpController.isResending.value
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xff2D2D2D),
                                  ),
                                ),
                              )
                            : Text(
                                "resend".tr,
                                style: globalTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: otpController.isResendEnabled.value
                                      ? Color(0xff2D2D2D)
                                      : Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${'resend_code_in'.tr} ${otpController.timerText}",
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff636F85),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: otpController.isLoading.value
                          ? null
                          : () => otpController.verifyOTP(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        disabledBackgroundColor: AppColors.primaryColor
                            .withValues(alpha: 0.6),
                      ),
                      child: otpController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "submit".tr,
                              style: globalTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
