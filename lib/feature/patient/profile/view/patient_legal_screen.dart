import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/service/legal_service.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';

class PatientLegalScreen extends StatelessWidget {
  const PatientLegalScreen({super.key});

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
      body: FutureBuilder<LegalDocumentModel?>(
        future: LegalService.fetchActiveDocument('PATIENT'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final doc = snapshot.data;
          final title = doc?.localizedTitle ?? 'patient_terms_title'.tr;
          final content = doc?.localizedContent ?? 'patient_terms_content'.tr;
          final version = doc?.version ?? '1.0';
          final isArabic = Get.locale?.languageCode == 'ar';

          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff2D2D2D),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'v$version',
                        style: globalTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  content,
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff636F85),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'patient_privacy_policy'.tr,
                  style: globalTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'patient_privacy_policy_desc'.tr,
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
      },
      ),
    );
  }
}
