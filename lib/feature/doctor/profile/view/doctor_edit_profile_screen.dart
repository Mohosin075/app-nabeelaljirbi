import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_edit_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/qualification_item_model.dart';

class DoctorEditProfileScreen extends StatelessWidget {
  const DoctorEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorEditProfileController());

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
              Obx(
                () => Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xffF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: controller.profileImage.value != null
                            ? Image.file(
                                controller.profileImage.value!,
                                fit: BoxFit.cover,
                              )
                            : Get.find<DoctorProfileController>()
                                  .profileImage
                                  .value
                                  .isNotEmpty
                            ? Image.network(
                                Get.find<DoctorProfileController>()
                                    .profileImage
                                    .value,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(0xff94A3B8),
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xff94A3B8),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: controller.pickImage,
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
                forceLtr: true,
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
                hint: 'enter_address_details'.tr,
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildDropdown(
                  label: 'medical_specialty'.tr,
                  value: controller.selectedSpecialty,
                  items: controller.specialtyNames,
                  icons: controller.specialtyImages,
                  hintTitle: 'select_medical_specialty'.tr,
                  onChanged: (val) {
                    controller.selectedSpecialty.value = val ?? '';
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'years_of_experience'.tr,
                controller: controller.experienceController,
                hint: 'enter_years_of_experience'.tr,
                forceLtr: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'license_number'.tr,
                controller: controller.licenseController,
                hint: 'enter_license_number'.tr,
                forceLtr: true,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'base_consultation_fee'.tr,
                controller: controller.consultationFeeController,
                hint: 'enter_fee'.tr,
                inputType: TextInputType.number,
                forceLtr: true,
              ),
              const SizedBox(height: 16),
              // Biography / Academic & Professional Qualifications Section
              _buildQualificationsBuilder(
                qualifications: controller.qualifications,
                onAdd: controller.addQualification,
                onRemove: controller.removeQualification,
              ),
              const SizedBox(height: 32),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                            width: 20,
                            height: 20,
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
    bool forceLtr = false,
    int maxLines = 1,
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
          maxLines: maxLines,
          textDirection: forceLtr ? TextDirection.ltr : null,
          inputFormatters: inputType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
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
    List<String>? icons, // Optional icons support
    String? hintTitle, // For bottom sheet title
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
        GestureDetector(
          onTap: () {
            if (items.isNotEmpty) {
              if (icons != null && icons.isNotEmpty) {
                // Use custom bottom sheet if icons are provided
                _showSelectionBottomSheet(
                  Get.context!,
                  hintTitle ?? label,
                  icons,
                  items,
                  (selected) {
                    if (onChanged != null) {
                      onChanged(selected);
                    } else {
                      value.value = selected;
                    }
                  },
                  Rx<String?>(value.value),
                  true, // Search enabled by default for icons view
                );
              } else {
                // Determine if we should show a bottom sheet or just a dropdown
                // For this implementation, we'll simple make generic dropdown open a bottom sheet too for consistency if needed,
                // but observing existing behavior, we can keep the standard dropdown if no icons.
                // However, the request is for specialty dropdown modification.
              }
            }
          },
          child: Obx(() {
            // Custom rendering for read-only look that triggers sheet
            if (icons != null) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xff94A3B8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value.value.isEmpty ? 'select'.tr : value.value.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        color: value.value.isEmpty
                            ? const Color(0xff94A3B8)
                            : const Color(0xff2D2D2D),
                      ),
                    ),
                    SvgPicture.asset(IconsPath.downArrow),
                  ],
                ),
              );
            } else {
              // Fallback to standard dropdown style for others
              return Container(
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
              );
            }
          }),
        ),
      ],
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
    // Zip options and icons
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
                              color: Color(0xff137CCF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
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
                                        ? const Color(0xff137CCF)
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
              Text(
                'biography'.tr,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff2D2D2D),
                ),
              ),
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff137CCF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: Color(0xff137CCF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+ Add Qualification',
                        style: globalTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff137CCF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (qualifications.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                    borderRadius: BorderRadius.circular(12),
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
                                  color: const Color(0xff137CCF).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.school_outlined,
                                  size: 16,
                                  color: Color(0xff137CCF),
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
                      TextField(
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
                            child: TextField(
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
                            child: TextField(
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
