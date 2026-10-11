import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () => Get.offAllNamed(AppRoutes.patientNavBar),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Image.asset(IconsPath.success, width: 140, height: 140),
                      const SizedBox(height: 24),
                      Text(
                        'booking_request_sent'.tr,
                        style: globalTextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'booking_request_sent_desc'.tr,
                        style: globalTextStyle(
                          fontSize: 14,
                          color: const Color(0xff636F85),
                          lineHeight: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Post-send Booking Policy Box (Displayed twice: pre-send & post-send)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'booking_policy_title'.tr,
                                  style: globalTextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xff1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'booking_policy_notice'.tr,
                              style: globalTextStyle(
                                fontSize: 13,
                                color: const Color(0xff495057),
                                lineHeight: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.patientNavBar),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'back_to_home'.tr,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
