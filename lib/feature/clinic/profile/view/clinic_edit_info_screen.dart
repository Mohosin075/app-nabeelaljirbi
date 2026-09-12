import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:latlong2/latlong.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_edit_info_controller.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/view/map_picker_dialog.dart';

class ClinicEditInfoScreen extends StatelessWidget {
  const ClinicEditInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller if not already in memory
    final controller = Get.put(ClinicEditInfoController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'edit_clinic_info'.tr,
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clinic Logo Picker
                    Center(
                      child: GestureDetector(
                        onTap: controller.pickLogo,
                        child: Stack(
                          children: [
                            Obx(
                              () => Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xffF1F5F9),
                                  border: Border.all(
                                    color: const Color(0xffE2E8F0),
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: controller.logoFile.value != null
                                      ? Image.file(
                                          File(controller.logoFile.value!.path),
                                          fit: BoxFit.cover,
                                        )
                                      : (Get.find<ClinicProfileController>()
                                                .logo
                                                .value
                                                .isNotEmpty
                                            ? Image.network(
                                                Get.find<
                                                      ClinicProfileController
                                                    >()
                                                    .logo
                                                    .value,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.local_hospital,
                                                        size: 50,
                                                        color: Color(
                                                          0xff94A3B8,
                                                        ),
                                                      );
                                                    },
                                              )
                                            : const Icon(
                                                Icons.local_hospital,
                                                size: 50,
                                                color: Color(0xff94A3B8),
                                              )),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Clinic Manager Info Section
                    Text(
                      'clinic_manager_info'.tr,
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'manager_full_name'.tr,
                      controller: controller.managerNameController,
                    ),
                    const SizedBox(height: 16),
                    _buildPhoneField(
                      label: 'manager_phone_number'.tr,
                      controller: controller.managerPhoneController,
                      countryCode: controller.managerPhoneCountryCode,
                      countryFlag: controller.managerPhoneCountryFlag,
                      maxLength: controller.managerPhoneRequiredLength,
                      validator: controller.validateManagerPhone,
                      onCountryTap: () {
                        _showCountrySelector(context, isManager: true);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Clinic Information Section
                    Text(
                      'clinic_information'.tr,
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'clinic_name'.tr,
                      controller: controller.clinicNameController,
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
                      label: 'about_clinic'.tr,
                      controller: controller.aboutClinicController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildPhoneField(
                      label: 'contact_phone_number'.tr,
                      controller: controller.contactPhoneController,
                      countryCode: controller.contactPhoneCountryCode,
                      countryFlag: controller.contactPhoneCountryFlag,
                      maxLength: controller.contactPhoneRequiredLength,
                      validator: controller.validateContactPhone,
                      onCountryTap: () {
                        _showCountrySelector(context, isManager: false);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'location_optional'.tr,
                      controller: controller.locationController,
                      isLocation: true,
                      onTap: () async {
                        final result = await Get.to<Map<String, dynamic>?>(
                          () => MapPickerDialog(
                            initialLocation: LatLng(
                              controller.latitude,
                              controller.longitude,
                            ),
                            initialAddress: controller.locationController.text,
                          ),
                        );
                        if (result != null) {
                          controller.locationController.text = result['address'] ?? '';
                          controller.latitude = result['lat'] ?? controller.latitude;
                          controller.longitude = result['lng'] ?? controller.longitude;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Footer Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF137CCF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            'save_changes'.tr,
                            style: globalTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isLocation = false,
    int maxLines = 1,
    Function(String)? onChanged,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          readOnly: isLocation,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
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
            suffixIcon: isLocation
                ? const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF64748B),
                    size: 20,
                  )
                : null,
          ),
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
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
                value: value.value.isEmpty && items.isNotEmpty
                    ? null
                    : (items.contains(value.value) ? value.value : null),
                isExpanded: true,
                icon: SvgPicture.asset(IconsPath.downArrow),
                hint: Text(
                  'select'.tr,
                  style: globalTextStyle(
                    fontSize: 14,
                    color: const Color(0xff94A3B8),
                  ),
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item.toLowerCase().tr,
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
                    if (onChanged != null) {
                      onChanged(newValue);
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField({
    required String label,
    required TextEditingController controller,
    required RxString countryCode,
    required RxString countryFlag,
    required int maxLength,
    required String? Function(String?) validator,
    required VoidCallback onCountryTap,
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
        Obx(() {
          final bool isRtl = Get.locale?.languageCode == 'ar';
          final countrySelector = GestureDetector(
            onTap: onCountryTap,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(countryFlag.value, height: 20, width: 30),
                  const SizedBox(width: 8),
                  Text(
                    countryCode.value,
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
            controller: controller,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: maxLength,
            decoration: InputDecoration(
              errorMaxLines: 2,
              counterText: "",
              hintText: "enter_phone_number".tr,
              hintTextDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF94A3B8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF94A3B8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryColor),
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
            validator: validator,
            style: globalTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          );
        }),
      ],
    );
  }

  void _showCountrySelector(BuildContext context, {required bool isManager}) {
    final controller = Get.find<ClinicEditInfoController>();

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
                    () => Column(
                      children: controller.countryPhoneList.map((country) {
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
                            Navigator.pop(context);
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
                          trailing: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? AppColors.primaryColor
                                : const Color(0xff9CA3AF),
                            size: 20,
                          ),
                        );
                      }).toList(),
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
