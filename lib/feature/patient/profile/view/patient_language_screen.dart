import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';

class PatientLanguageScreen extends StatelessWidget {
  const PatientLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = 'English'.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Language',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff2D2D2D),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => RadioGroup<String>(
                groupValue: selectedLanguage.value,
                onChanged: (val) => selectedLanguage.value = val!,
                child: Column(
                  children: [
                    _buildLanguageItem(
                      flag: IconsPath.tunisia,
                      name: 'English',
                      value: 'English',
                    ),
                    _buildLanguageItem(
                      flag: IconsPath.algeria,
                      name: 'Arabic',
                      value: 'Arabic',
                    ),
                    _buildLanguageItem(
                      flag: IconsPath.libya,
                      name: 'French',
                      value: 'French',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem({
    required String flag,
    required String name,
    required String value,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffE5E9F2)),
        ),
        child: RadioListTile<String>(
          value: value,
          title: Row(
            children: [
              // Flag or Icon
              SvgPicture.asset(
                flag,
                width: 24,
                height: 24,
              ), // Assuming these exist, otherwise remove
              const SizedBox(width: 12),
              Text(
                name,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff2D2D2D),
                ),
              ),
            ],
          ),
          activeColor: const Color(0xff137CCF),
          controlAffinity: ListTileControlAffinity.trailing,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
