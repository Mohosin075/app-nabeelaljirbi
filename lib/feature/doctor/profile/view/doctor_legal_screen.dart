import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';

class DoctorLegalScreen extends StatelessWidget {
  const DoctorLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'legal_and_policies'.tr,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'doctor_terms_title'.tr,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'doctor_terms_content'.tr,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xff636F85),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'doctor_privacy_policy'.tr,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'doctor_privacy_policy_desc'.tr,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xff636F85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
