import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorHelpCenterScreen extends StatelessWidget {
  const DoctorHelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Color(0xff137CCF).withValues(alpha: 0.1),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'need_more_help'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'support_team_desc'.tr,
                        style: globalTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(
                              Uri(scheme: 'mailto', path: 'info@spidertech.ly'),
                            );
                          },
                          icon: Icon(Icons.email_outlined, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          label: Text(
                            'email'.tr,
                            style: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'faq'.tr,
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff2D2D2D),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionItem(
                title: 'managing_appointments_title'.tr,
                subtitle: 'managing_appointments_desc'.tr,
                isExpanded: true,
              ),
              _buildActionItem(
                title: 'update_profile_title'.tr,
                subtitle: 'update_profile_desc'.tr,
              ),
              _buildActionItem(
                title: 'payments_title'.tr,
                subtitle: 'payments_desc'.tr,
              ),
              _buildActionItem(
                title: 'technical_support_title'.tr,
                subtitle: 'technical_support_desc'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required String title,
    String? subtitle,
    bool isExpanded = false,
  }) {
    return Material(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffE5E9F2)),
        ),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Text(
              title,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xff2D2D2D),
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xff94A3B8),
            ),
            initiallyExpanded: isExpanded,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              if (subtitle != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: globalTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff636F85),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
