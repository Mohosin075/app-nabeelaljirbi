import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';

class BlueBadgeWidget extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry padding;

  const BlueBadgeWidget({
    super.key,
    this.size = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 2.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showBlueBadgeNoticeDialog(context),
        child: Icon(
          Icons.verified,
          size: size,
          color: const Color(0xff1D9BF0), // Official verified blue
        ),
      ),
    );
  }

  static void showBlueBadgeNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Verified Icon Header
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xffEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xffBFDBFE)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified,
                      size: 32,
                      color: Color(0xff1D9BF0),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Title
                Text(
                  'verified_account'.tr,
                  style: globalTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Verbatim Notice Content (Rendered in RTL Arabic / English fallback)
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: Text(
                      'verification_notice_content'.tr,
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff334155),
                        lineHeight: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ok_got_it'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
