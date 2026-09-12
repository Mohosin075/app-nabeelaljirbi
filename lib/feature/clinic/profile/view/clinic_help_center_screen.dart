import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class ClinicHelpCenterScreen extends StatefulWidget {
  const ClinicHelpCenterScreen({super.key});

  @override
  State<ClinicHelpCenterScreen> createState() => _ClinicHelpCenterScreenState();
}

class _ClinicHelpCenterScreenState extends State<ClinicHelpCenterScreen> {
  int? expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'help_center'.tr,
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
            // Need More Help Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF137CCF).withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'need_more_help'.tr,
                    style: globalTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'support_team_desc'.tr,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        launchUrl(
                          Uri(scheme: 'mailto', path: 'info@spidertech.ly'),
                        );
                      },
                      icon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        'email'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // FAQ Section
            Text(
              'faq'.tr,
              style: globalTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            // FAQ List
            _buildFaqItem(
              question: 'managing_doctors_title'.tr,
              answer: 'managing_doctors_desc'.tr,
              isExpanded: expandedIndex == 0,
              onTap: () =>
                  setState(() => expandedIndex = expandedIndex == 0 ? null : 0),
            ),
            _buildFaqItem(
              question: 'clinic_appointments_help_title'.tr,
              answer: 'clinic_appointments_help_desc'.tr,
              isExpanded: expandedIndex == 1,
              onTap: () =>
                  setState(() => expandedIndex = expandedIndex == 1 ? null : 1),
            ),
            _buildFaqItem(
              question: 'clinic_profile_update_title'.tr,
              answer: 'clinic_profile_update_desc'.tr,
              isExpanded: expandedIndex == 2,
              onTap: () =>
                  setState(() => expandedIndex = expandedIndex == 2 ? null : 2),
            ),
            _buildFaqItem(
              question: 'clinic_payments_help_title'.tr,
              answer: 'clinic_payments_help_desc'.tr,
              isExpanded: expandedIndex == 3,
              onTap: () =>
                  setState(() => expandedIndex = expandedIndex == 3 ? null : 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question,
                        style: globalTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isExpanded
                              ? AppColors.primaryColor
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        isExpanded ? Icons.remove : Icons.add,
                        size: 18,
                        color: isExpanded
                            ? AppColors.primaryColor
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded && answer.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    answer,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      lineHeight: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
