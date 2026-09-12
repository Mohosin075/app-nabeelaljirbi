import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/clinic/controller/clinic_profile_setup_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/map_picker_dialog.dart';

class ClinicProfileSetupScreen extends StatelessWidget {
  ClinicProfileSetupScreen({super.key});

  final ClinicProfileSetupController controller = Get.put(
    ClinicProfileSetupController(),
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
                            "Clinic Info",
                            style: globalTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff2D2D2D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "clinic_manager_info".tr,
                        style: globalTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff000000),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel("manager_full_name".tr),
                      _buildTextField(
                        controller: controller.managerNameController,
                        hint: "Enter your full name",
                        onChanged: (value) =>
                            controller.managerName.value = value,
                        validator: (value) => controller.validateRequired(
                          value,
                          "manager_full_name".tr,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("email".tr),
                      _buildTextField(
                        controller: controller.emailController,
                        hint: "enter_email".tr,
                        keyboardType: TextInputType.emailAddress,
                        //validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("manager_phone_number".tr),
                      Obx(() {
                        final bool isRtl = Get.locale?.languageCode == 'ar';
                        final countrySelector = GestureDetector(
                          onTap: () {
                            _showCountrySelector(context, isManager: true);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  controller.managerPhoneCountryFlag.value,
                                  height: 20,
                                  width: 30,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  controller.managerPhoneCountryCode.value,
                                  style: globalTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff2D2D2D),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        );
                        return TextFormField(
                          controller: controller.managerPhoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          maxLength: controller.managerPhoneRequiredLength,
                          onChanged: (value) =>
                              controller.managerPhone.value = value,
                          decoration: InputDecoration(
                            errorMaxLines: 2,
                            counterText: "",
                            hintText: "enter_phone_number".tr,
                            hintTextDirection: isRtl
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF94A3B8),
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
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            prefixIcon: isRtl ? null : countrySelector,
                            suffixIcon: isRtl ? countrySelector : null,
                          ),
                          validator: (value) =>
                              controller.validateManagerPhone(value),
                        );
                      }),
                      const SizedBox(height: 40),
                      Text(
                        "clinic_information".tr,
                        style: globalTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff000000),
                        ),
                      ),
                      const SizedBox(height: 0),

                      // logo upload section
                      _buildLabel("clinic_logo".tr),
                      GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Obx(
                          () => Container(
                            width: double.infinity,
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFF94A3B8)),
                              color: Color(0xFFF9FAFB),
                            ),
                            child: controller.clinicLogo.value != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      controller.clinicLogo.value!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_outlined,
                                        color: Color(0xff636F85),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "upload_logo".tr,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff636F85),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildLabel("clinic_name".tr),
                      _buildTextField(
                        controller: controller.clinicNameController,
                        hint: "enter_clinic_name".tr,
                        onChanged: (value) =>
                            controller.clinicName.value = value,
                        validator: (value) => controller.validateRequired(
                          value,
                          "clinic_name".tr,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                            validator: (value) => controller.validateRequired(
                              controller.selectedCity.value,
                              "city".tr,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildLabel("about_clinic".tr),
                      _buildTextField(
                        controller: controller.aboutClinicController,
                        hint: "enter_about_clinic".tr,
                        maxLines: 3,
                        onChanged: (value) =>
                            controller.aboutClinic.value = value,
                        validator: (value) => controller.validateRequired(
                          value,
                          "about_clinic".tr,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("contact_phone_number".tr),
                      Obx(() {
                        final bool isRtl = Get.locale?.languageCode == 'ar';
                        final contactCountrySelector = GestureDetector(
                          onTap: () {
                            _showCountrySelector(context, isManager: false);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  controller.contactPhoneCountryFlag.value,
                                  height: 20,
                                  width: 30,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  controller.contactPhoneCountryCode.value,
                                  style: globalTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff2D2D2D),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        );
                        return TextFormField(
                          controller: controller.contactPhoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          maxLength: controller.contactPhoneRequiredLength,
                          onChanged: (value) =>
                              controller.contactPhone.value = value,
                          decoration: InputDecoration(
                            errorMaxLines: 2,
                            counterText: "",
                            hintText: "enter_phone_number".tr,
                            hintTextDirection: isRtl
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF94A3B8),
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
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            prefixIcon: isRtl ? null : contactCountrySelector,
                            suffixIcon: isRtl ? contactCountrySelector : null,
                          ),
                          validator: (value) =>
                              controller.validateContactPhone(value),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildLabel("location".tr),
                      _buildTextField(
                        controller: controller.locationController,
                        hint: "enter_location".tr,
                        readOnly: true,
                        suffixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        onTap: () async {
                          final double lat =
                              double.tryParse(controller.latitude.value) ??
                              32.8872;
                          final double lng =
                              double.tryParse(controller.longitude.value) ??
                              13.1913;
                          final result = await Get.to<Map<String, dynamic>?>(
                            () => MapPickerDialog(
                              initialLocation: LatLng(lat, lng),
                              initialAddress:
                                  controller.locationController.text,
                            ),
                          );
                          if (result != null) {
                            controller.locationController.text =
                                result['address'] ?? '';
                            controller.location.value = result['address'] ?? '';
                            controller.latitude.value = (result['lat'] ?? lat)
                                .toString();
                            controller.longitude.value = (result['lng'] ?? lng)
                                .toString();
                          }
                        },
                        validator: (value) =>
                            controller.validateRequired(value, "location".tr),
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
                                : () {
                                    debugPrint(
                                      "Location: ${controller.location.value}\nLatitude: ${controller.latitude.value}\nLongitude: ${controller.longitude.value}",
                                    );
                                    controller.submitProfile();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "submit_create_clinic".tr,
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
    int maxLines = 1,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
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
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    String? value,
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
                    value ?? hint.tr,
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
    FocusManager.instance.primaryFocus?.unfocus();
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

              return SingleChildScrollView(
                child: Column(
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
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
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCountrySelector(BuildContext context, {required bool isManager}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Material(
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "select_country".tr,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: const Color(0xffE2E8F0), thickness: 1),
                  const SizedBox(height: 8),
                  Obx(
                    () => RadioGroup<String>(
                      groupValue: isManager
                          ? controller.managerPhoneCountryCode.value
                          : controller.contactPhoneCountryCode.value,
                      onChanged: (value) {
                        if (value != null) {
                          final country = controller.countries.firstWhere(
                            (c) => c['code'] == value,
                          );
                          if (isManager) {
                            controller.selectManagerPhoneCountry(
                              value,
                              country['name']!,
                              country['flag']!,
                            );
                          } else {
                            controller.selectContactPhoneCountry(
                              value,
                              country['name']!,
                              country['flag']!,
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Column(
                        children: controller.countries.map((country) {
                          final isSelected = isManager
                              ? controller.managerPhoneCountryCode.value ==
                                    country['code']
                              : controller.contactPhoneCountryCode.value ==
                                    country['code'];
                          return ListTile(
                            onTap: () {
                              if (isManager) {
                                controller.selectManagerPhoneCountry(
                                  country['code']!,
                                  country['name']!,
                                  country['flag']!,
                                );
                              } else {
                                controller.selectContactPhoneCountry(
                                  country['code']!,
                                  country['name']!,
                                  country['flag']!,
                                );
                              }
                              Navigator.pop(context); // Close bottom sheet
                            },
                            leading: SvgPicture.asset(
                              country['flag']!,
                              height: 20,
                              width: 30,
                            ),
                            title: Text(
                              "${country['code']} (${country['name']!.tr})",
                              style: globalTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xff2D2D2D)
                                    : const Color(0xff636F85),
                              ),
                            ),
                            trailing: Radio<String>(
                              value: country['code']!,
                              activeColor: AppColors.primaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
