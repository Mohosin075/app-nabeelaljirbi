import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/patient/controller/patient_profile_setup_controller.dart';

class PatientProfileSetupScreen extends StatelessWidget {
  PatientProfileSetupScreen({super.key});

  final PatientProfileSetupController controller = Get.put(
    PatientProfileSetupController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: SvgPicture.asset(
                              IconsPath.backArrow,
                              width: 24,
                              height: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "complete_profile".tr,
                            style: globalTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff2D2D2D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Stack(
                          children: [
                            Obx(
                              () => CircleAvatar(
                                radius: 50,
                                backgroundColor: Color(0xffE2E8F0),
                                backgroundImage:
                                    controller.profileImage.value != null
                                    ? FileImage(controller.profileImage.value!)
                                    : null,
                                child: controller.profileImage.value == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Color(0xff64748B),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildLabel("full_name".tr),
                      _buildTextField(
                        controller: controller.fullNameController,
                        hint: "enter_full_name".tr,
                        validator: controller.validateFullName,
                      ),
                      _buildLabel("email".tr),
                      _buildTextField(
                        controller: controller.emailController,
                        hint: "enter_email".tr,
                        keyboardType: TextInputType.emailAddress,
                        //validator: controller.validateEmail,
                      ),
                      _buildLabel("gender".tr),
                      GestureDetector(
                        onTap: () => _showSelectionBottomSheet(
                          context,
                          "select_gender".tr,
                          [IconsPath.male, IconsPath.female],
                          controller.genderOptions,
                          (value) => controller.selectGender(value),
                          controller.selectedGender,
                          false,
                        ),
                        child: Obx(
                          () => _buildDropdownField(
                            hint: "select_your_gender".tr,
                            value: controller.selectedGender.value?.tr,
                            validator: (value) =>
                                controller.validateRequired(value, "gender".tr),
                          ),
                        ),
                      ),
                      _buildLabel("date_of_birth".tr),
                      GestureDetector(
                        onTap: () => controller.selectDate(context),
                        child: Obx(
                          () => _buildDropdownField(
                            hint: "select_date_of_birth".tr,
                            value: controller.formattedDob,
                            icon: Icons.calendar_today_outlined,
                            validator: (value) => controller.validateRequired(
                              value,
                              "date_of_birth".tr,
                            ),
                          ),
                        ),
                      ),
                      _buildLabel("country".tr),
                      GestureDetector(
                        onTap: () => _showSelectionBottomSheet(
                          context,
                          "select_country".tr,
                          [
                            IconsPath.libya,
                            IconsPath.tunisia,
                            IconsPath.egypt,
                            IconsPath.algeria,
                          ],
                          controller.countryOptions,
                          (value) => controller.selectCountry(value),
                          controller.selectedCountry,
                          false,
                        ),
                        child: Obx(
                          () => _buildDropdownField(
                            hint: "select_your_country".tr,
                            value: controller.selectedCountry.value?.tr,
                            validator: (value) => controller.validateRequired(
                              value,
                              "country".tr,
                            ),
                          ),
                        ),
                      ),
                      _buildLabel("city".tr),
                      Obx(() {
                        final bool isCountrySelected =
                            controller.selectedCountry.value != null;
                        return GestureDetector(
                          onTap: isCountrySelected
                              ? () => _showSelectionBottomSheet(
                                  context,
                                  "select_city".tr,
                                  List.generate(
                                    controller.cityOptions.length,
                                    (index) => IconsPath.location,
                                  ),
                                  controller.cityOptions,
                                  (value) => controller.selectCity(value),
                                  controller.selectedCity,
                                  true,
                                )
                              : null,
                          child: _buildDropdownField(
                            hint: "select_your_city".tr,
                            value: controller.selectedCity.value?.tr,
                            isEnabled: isCountrySelected,
                            validator: (value) =>
                                controller.validateRequired(value, "city".tr),
                          ),
                        );
                      }),
                      _buildLabel("address_optional".tr),
                      _buildTextField(
                        controller: controller.addressController,
                        hint: "enter_address".tr,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              value: controller.isCertified.value,
                              onChanged: (value) {
                                controller.isCertified.value = value ?? false;
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "certification_message".tr,
                              style: globalTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff636F85),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.submitProfile(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              disabledBackgroundColor: AppColors.primaryColor
                                  .withValues(alpha: 0.6),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "confirm".tr,
                                    style: globalTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 16.0),
      child: Text(
        text,
        style: globalTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xff2D2D2D),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: globalTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xff636F85),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF94A3B8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    String? value,
    IconData icon = Icons.keyboard_arrow_down,
    bool isEnabled = true,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: value,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isEnabled ? Colors.white : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.hasError ? Colors.red : const Color(0xFF94A3B8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? hint,
                    style: globalTextStyle(
                      fontSize: 14,
                      color: value != null
                          ? const Color(0xff2D2D2D)
                          : const Color(0xff636F85),
                    ),
                  ),
                  SvgPicture.asset(IconsPath.downArrow, width: 20, height: 20),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 16),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
      // Trigger rebuild when value changes externally
      key: ValueKey(value),
    );
  }

  void _showSelectionBottomSheet(
    BuildContext context,
    String title,
    List<String> icons,
    List<String> options,
    Function(String) onSelect,
    Rx<String?> selectedValue,
    bool search,
  ) {
    // Zip options and icons to keep them together during filtering
    final List<MapEntry<String, String>> allItems = List.generate(
      options.length,
      (index) => MapEntry(options[index], icons[index]),
    );

    String searchText = '';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              List<MapEntry<String, String>> displayedItems = allItems;
              if (search && searchText.isNotEmpty) {
                displayedItems = allItems
                    .where(
                      (item) => item.key.toLowerCase().contains(
                        searchText.toLowerCase(),
                      ),
                    )
                    .toList();
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff2D2D2D),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Color(0xff9CA3AF)),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  Divider(color: Color(0xffE2E8F0)),
                  const SizedBox(height: 16),
                  if (search)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF9FAFB),
                          hintText: '${'search'.tr}...',
                          hintStyle: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff636F85),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xff636F85),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF94A3B8)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: displayedItems.map((entry) {
                          String option = entry.key;
                          String icon = entry.value;
                          return InkWell(
                            onTap: () {
                              onSelect(option);
                              Get.back();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  SvgPicture.asset(icon, width: 20, height: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    option.tr,
                                    style: globalTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff2D2D2D),
                                    ),
                                  ),
                                  const Spacer(),
                                  Obx(
                                    () => Icon(
                                      selectedValue.value == option
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: selectedValue.value == option
                                          ? AppColors.primaryColor
                                          : const Color(0xff9CA3AF),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
