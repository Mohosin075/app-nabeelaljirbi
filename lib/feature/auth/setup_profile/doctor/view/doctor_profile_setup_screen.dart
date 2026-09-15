import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/doctor/controller/doctor_profile_setup_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/qualification_item_model.dart';

class DoctorProfileSetupScreen extends StatelessWidget {
  DoctorProfileSetupScreen({super.key});

  final DoctorProfileSetupController controller = Get.put(
    DoctorProfileSetupController(),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
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
                          spacing: 16,
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: SvgPicture.asset(
                                IconsPath.backArrow,
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Text(
                              "professional_info".tr,
                              style: globalTextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff2D2D2D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                                      ? FileImage(
                                          controller.profileImage.value!,
                                        )
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
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            if (!context.mounted) return;
                            _showSelectionBottomSheet(
                              context,
                              "select_gender".tr,
                              [IconsPath.male, IconsPath.female],
                              controller.genderOptions,
                              (value) => controller.selectGender(value),
                              controller.selectedGender,
                              false,
                            );
                          },
                          child: Obx(
                            () => _buildDropdownField(
                              hint: "select_your_gender".tr,
                              value: controller.selectedGender.value?.tr,
                              validator: (value) => controller.validateRequired(
                                controller.selectedGender.value,
                                "gender".tr,
                              ),
                            ),
                          ),
                        ),

                        _buildLabel("date_of_birth".tr),
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            controller.selectDate(context);
                          },
                          child: Obx(
                            () => _buildDropdownField(
                              hint: "select_date_of_birth".tr,
                              value: controller.formattedDob,
                              icon: Icons.calendar_today_outlined,
                              validator: (value) => controller.validateRequired(
                                controller.formattedDob,
                                "date_of_birth".tr,
                              ),
                            ),
                          ),
                        ),

                        _buildLabel("country".tr),
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            if (!context.mounted) return;
                            _showSelectionBottomSheet(
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
                            );
                          },
                          child: Obx(
                            () => _buildDropdownField(
                              hint: "select_your_country".tr,
                              value: controller.selectedCountry.value?.tr,
                              validator: (value) => controller.validateRequired(
                                controller.selectedCountry.value,
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
                                ? () async {
                                    FocusScope.of(context).unfocus();
                                    await Future.delayed(
                                      const Duration(milliseconds: 200),
                                    );
                                    if (!context.mounted) return;
                                    _showSelectionBottomSheet(
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
                                    );
                                  }
                                : null,
                            child: _buildDropdownField(
                              hint: "select_your_city".tr,
                              value: controller.selectedCity.value?.tr,
                              isEnabled: isCountrySelected,
                              validator: (value) => controller.validateRequired(
                                controller.selectedCity.value,
                                "city".tr,
                              ),
                            ),
                          );
                        }),

                        _buildLabel("address_optional".tr),
                        _buildTextField(
                          controller: controller.addressController,
                          hint: "enter_address".tr,
                        ),

                        _buildLabel("medical_specialty".tr),
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            if (!context.mounted) return;
                            _showSelectionBottomSheet(
                              context,
                              "select_medical_specialty".tr,
                              controller.specialtyImages,
                              controller.specialtyOptions,
                              (value) => controller.selectSpecialty(value),
                              controller.selectedSpecialty,
                              true, // Enable search
                            );
                          },
                          child: Obx(
                            () => _buildDropdownField(
                              hint: "select_your_speciality".tr,
                              value: controller.selectedSpecialty.value,
                              validator: (value) => controller.validateRequired(
                                controller.selectedSpecialty.value,
                                "medical_specialty".tr,
                              ),
                            ),
                          ),
                        ),

                        _buildLabel("years_of_experience".tr),
                        _buildTextField(
                          controller: controller.experienceController,
                          hint: "enter_years_experience".tr,
                          keyboardType: TextInputType.number,
                          validator: (value) => controller.validateRequired(
                            value,
                            "years_of_experience".tr,
                          ),
                        ),

                        _buildLabel("license_number_optional".tr),
                        _buildTextField(
                          controller: controller.licenseController,
                          hint: "enter_license_number".tr,
                          keyboardType: TextInputType.number,
                        ),

                        _buildLabel("base_consultation_fee".tr),
                        _buildTextField(
                          controller: controller.consultationFeeController,
                          hint: "enter_consultation_fee".tr,
                          keyboardType: TextInputType.number,
                          validator: (value) => controller.validateRequired(
                            value,
                            "base_consultation_fee".tr,
                          ),
                        ),

                        _buildQualificationsBuilder(
                          qualifications: controller.qualifications,
                          onAdd: controller.addQualification,
                          onRemove: controller.removeQualification,
                        ),

                        _buildLabel("clinic_info_optional".tr),
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(
                              const Duration(milliseconds: 200),
                            );
                            if (!context.mounted) return;
                            _showClinicSelectionBottomSheet(context);
                          },
                          child: Obx(
                            () => _buildDropdownField(
                              hint: "select_clinic_info".tr,
                              value: controller.selectedClinicInfo.value,
                            ),
                          ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      textDirection: keyboardType == TextInputType.number
          ? TextDirection.ltr
          : null,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
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
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
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
      key: ValueKey(value),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
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
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
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
        key: ValueKey(title),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
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
                          color: const Color(0xff2D2D2D),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xff9CA3AF)),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xffE2E8F0)),
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
                          fillColor: const Color(0xFFF9FAFB),
                          hintText: '${'search'.tr}...',
                          hintStyle: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff636F85),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xff636F85),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // If no search bar and few items, use Column to wrap content
                  if (!search)
                    Column(
                      mainAxisSize: MainAxisSize.min,
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
                                if (icon.startsWith('http') ||
                                    icon.startsWith('https'))
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      icon,
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              SvgPicture.asset(
                                                IconsPath.stethoscope,
                                                width: 20,
                                                height: 20,
                                              ),
                                    ),
                                  )
                                else
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
                  // If search bar exists, use scrollable ListView
                  if (search)
                    Flexible(
                      child: ListView.builder(
                        itemCount: displayedItems.length,
                        itemBuilder: (context, index) {
                          final entry = displayedItems[index];
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
                                  if (icon.startsWith('http') ||
                                      icon.startsWith('https'))
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        icon,
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                SvgPicture.asset(
                                                  IconsPath.stethoscope,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                      ),
                                    )
                                  else
                                    SvgPicture.asset(
                                      icon,
                                      width: 20,
                                      height: 20,
                                    ),
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
                        },
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

  void _showClinicSelectionBottomSheet(BuildContext context) {
    controller.fetchClinics(); // Initial fetch when opening
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "select_clinic".tr,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff2D2D2D),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xff9CA3AF)),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(color: Color(0xffE2E8F0)),
              const SizedBox(height: 16),
              // Search Field
              TextField(
                onChanged: (value) {
                  controller.fetchClinics(searchTerm: value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  hintText: '${'search'.tr}...',
                  hintStyle: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff636F85),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xff636F85),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF94A3B8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isClinicsLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (controller.clinics.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("No clinics found".tr),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.clinics.length,
                    itemBuilder: (context, index) {
                      final clinic = controller.clinics[index];
                      return InkWell(
                        onTap: () {
                          controller.selectClinic(clinic);
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child:
                                    clinic.logo != null &&
                                        clinic.logo!.isNotEmpty
                                    ? Image.network(
                                        clinic.logo!,
                                        width: 24,
                                        height: 24,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                SvgPicture.asset(
                                                  IconsPath.clinicConfirmation,
                                                  width: 20,
                                                  height: 20,
                                                ),
                                      )
                                    : SvgPicture.asset(
                                        IconsPath.clinicConfirmation,
                                        width: 20,
                                        height: 20,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  clinic.clinicName ?? '',
                                  style: globalTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff2D2D2D),
                                  ),
                                ),
                              ),
                              Obx(
                                () => Icon(
                                  controller.selectedClinicId.value == clinic.id
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color:
                                      controller.selectedClinicId.value ==
                                          clinic.id
                                      ? AppColors.primaryColor
                                      : const Color(0xff9CA3AF),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildQualificationsBuilder({
    required RxList<QualificationItem> qualifications,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel("biography".tr),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+ Add Qualification',
                        style: globalTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (qualifications.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Text(
                  'No qualifications added yet. Tap + Add Qualification.',
                  style: globalTextStyle(
                    fontSize: 13,
                    color: const Color(0xff636F85),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: qualifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = qualifications[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.school_outlined,
                                  size: 16,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Qualification #${index + 1}',
                                style: globalTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff1E293B),
                                ),
                              ),
                            ],
                          ),
                          if (qualifications.length > 1)
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => onRemove(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: item.degreeController,
                        style: globalTextStyle(
                            fontSize: 14, color: const Color(0xff2D2D2D)),
                        decoration: InputDecoration(
                          labelText: 'Degree / Title (e.g. MBBS, FCPS)',
                          labelStyle: globalTextStyle(
                              fontSize: 12, color: const Color(0xff64748B)),
                          hintText: 'Enter degree title',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: item.instituteController,
                              style: globalTextStyle(
                                  fontSize: 14, color: const Color(0xff2D2D2D)),
                              decoration: InputDecoration(
                                labelText: 'Institute / University',
                                labelStyle: globalTextStyle(
                                    fontSize: 12, color: const Color(0xff64748B)),
                                hintText: 'e.g. Dhaka Medical College',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: item.yearController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              style: globalTextStyle(
                                  fontSize: 14, color: const Color(0xff2D2D2D)),
                              decoration: InputDecoration(
                                labelText: 'Year',
                                labelStyle: globalTextStyle(
                                    fontSize: 12, color: const Color(0xff64748B)),
                                hintText: 'e.g. 2018',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    });
  }
}
