import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_edit_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_profile_controller.dart';

class PatientEditProfileScreen extends StatelessWidget {
  const PatientEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientEditProfileController());

    return Scaffold(
      backgroundColor: Color(0xfff8f9fa),
      appBar: AppBar(
        title: Text(
          'edit_profile'.tr,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              GestureDetector(
                onTap: controller.pickImage,
                child: Stack(
                  children: [
                    Obx(
                      () => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xffE2E8F0)),
                          color: const Color(0xffF1F5F9),
                        ),
                        child: ClipOval(
                          child: controller.profileImage.value != null
                              ? Image.file(
                                  controller.profileImage.value!,
                                  fit: BoxFit.cover,
                                )
                              : Get.find<PatientProfileController>()
                                    .profileImage
                                    .value
                                    .isNotEmpty
                              ? Image.network(
                                  Get.find<PatientProfileController>()
                                      .profileImage
                                      .value,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Color(0xff94A3B8),
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Color.fromARGB(255, 132, 153, 182),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xff137CCF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'full_name'.tr,
                controller: controller.fullNameController,
                hint: 'enter_full_name'.tr,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'gender'.tr,
                value: controller.selectedGender,
                items: controller.genders,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'date_of_birth'.tr,
                controller: controller.dobController,
                hint: 'select_date_of_birth'.tr,
                readOnly: true,
                onTap: () => controller.selectDate(context),
                suffix: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: Color(0xff94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'country'.tr,
                value: controller.selectedCountry,
                items: controller.countries,
                onChanged: controller.onCountryChanged,
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildDropdown(
                  label: '${'city'.tr} *',
                  value: controller.selectedCity,
                  items: controller.cities,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'address'.tr,
                controller: controller.addressController,
                hint: 'enter_address'.tr,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff137CCF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'save_change'.tr,
                            style: globalTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType inputType = TextInputType.text,
    Widget? suffix,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xff2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          readOnly: readOnly,
          onTap: onTap,
          style: globalTextStyle(fontSize: 14, color: const Color(0xff2D2D2D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: globalTextStyle(
              fontSize: 14,
              color: const Color(0xff94A3B8),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff94A3B8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff94A3B8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff137CCF)),
            ),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required RxString value,
    required List<String> items,
    Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xff2D2D2D),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff94A3B8)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value.value) ? value.value : null,
                isExpanded: true,
                hint: Text(
                  '${'select_your'.tr} ${label.toLowerCase()}',
                  style: globalTextStyle(
                    fontSize: 14,
                    color: const Color(0xff94A3B8),
                  ),
                ),
                icon: SvgPicture.asset(IconsPath.downArrow),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        color: const Color(0xff2D2D2D),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    value.value = newValue;
                    if (onChanged != null) onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
