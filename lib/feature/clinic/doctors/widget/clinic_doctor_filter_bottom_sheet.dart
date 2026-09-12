import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import '../controller/clinic_doctor_controller.dart';

class ClinicDoctorFilterBottomSheet extends StatelessWidget {
  const ClinicDoctorFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClinicDoctorController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
                    color: const Color(0xFFE5E9F2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'filter'.tr,
                    style: globalTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => controller.resetFilters(),
                        child: Text(
                          'reset_filters'.tr,
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff636F85),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xff636F85)),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 20),
              _buildLabel('specialty'.tr),
              // _buildDropdown(
              //   value: controller.selectedSpecialty,
              //   items: controller.specialties,
              //   onChanged: (val) => controller.selectedSpecialty.value = val!,
              // ),
              // _buildDropdown(
              //   value: controller.selectedSpecialty,
              //   items: controller.specialties,
              //   onChanged: (val) => controller.updateSpecialty(val!),
              // ),
              Obx(
                () => _buildDropdown(
                  value: controller.selectedSpecialty,
                  items: controller.specialtyNames,
                  icons: controller.specialtyImages,
                  onChanged: (val) {
                    controller.selectedSpecialty.value = val ?? '';
                  },
                  hintTitle: 'Select Specialty', // Optional hint text
                ),
              ),
              const SizedBox(height: 16),
              // _buildLabel('experience'.tr),
              // _buildDropdown(
              //   value: controller.selectedExperience,
              //   items: controller.experiences,
              //   onChanged: (val) => controller.selectedExperience.value = val!,
              // ),
              // const SizedBox(height: 16),
              _buildLabel('price_range'.tr),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryColor,
                        inactiveTrackColor: const Color(0xFFE5E9F2),
                        thumbColor: Colors.white,
                        trackHeight: 8.0,
                      ),
                      child: Slider(
                        value: controller.maxFee.value,
                        min: 0,
                        max: 1000,
                        onChanged: (val) => controller.maxFee.value = val,
                      ),
                    ),
                    Text(
                      '${controller.maxFee.value.toInt()} ${CurrencyUtil.getUserCurrencySymbol()}',
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff636F85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('minimum_rating'.tr),
              _buildRatingSelector(controller),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.resetFilters(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE5E9F2)),
                      ),
                      child: Text(
                        'clear_all'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.applyFilters();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'apply_filters'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: globalTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xff1A1A1A),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required RxString value,
    required List<String> items,
    Function(String?)? onChanged,
    List<String>? icons, // Optional icons support
    String? hintTitle, // For hint text
  }) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff94A3B8)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value.value.isEmpty || !items.contains(value.value)
                ? null
                : value.value,
            isExpanded: true,
            icon: SvgPicture.asset(IconsPath.downArrow),
            hint: Text(
              hintTitle?.tr ?? 'select'.tr,
              style: globalTextStyle(
                fontSize: 14,
                color: const Color(0xff94A3B8),
              ),
            ),
            items: items.toSet().map((String item) {
              int index = items.indexOf(item);
              bool hasIcon =
                  icons != null && icons.isNotEmpty && index < icons.length;

              return DropdownMenuItem<String>(
                value: item,
                child: Row(
                  children: [
                    if (hasIcon)
                      _buildIconWidget(icons[index])
                    else
                      const SizedBox.shrink(),
                    if (hasIcon) const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.tr,
                        style: globalTextStyle(
                          fontSize: 14,
                          color: const Color(0xff2D2D2D),
                        ),
                      ),
                    ),
                  ],
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
    );
  }

  Widget _buildIconWidget(String iconPath) {
    if (iconPath.startsWith('http') || iconPath.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          iconPath,
          width: 20,
          height: 20,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              SvgPicture.asset(IconsPath.stethoscope, width: 20, height: 20),
        ),
      );
    } else {
      return SvgPicture.asset(iconPath, width: 20, height: 20);
    }
  } // Widget _buildDropdown({
  //   required RxString value,
  //   required List<String> items,
  //   List<String>? icons,
  //   required Function(String?) onChanged,
  // }) {
  //   return Obx(
  //     () => Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFFF8F9FA),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: const Color(0xFFE5E9F2)),
  //       ),
  //       child: DropdownButtonHideUnderline(
  //         child: DropdownButton<String>(
  //           value: value.value,
  //           isExpanded: true,
  //           icon: const Icon(
  //             Icons.keyboard_arrow_down,
  //             color: Color(0xff636F85),
  //           ),
  //           items: items.map((String item) {
  //             return DropdownMenuItem<String>(
  //               value: item,
  //               child: Text(
  //                 item.tr,
  //                 style: globalTextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w400,
  //                   color: const Color(0xff636F85),
  //                 ),
  //               ),
  //             );
  //           }).toList(),
  //           onChanged: onChanged,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildRatingSelector(ClinicDoctorController controller) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          int rating = index + 1;
          bool isSelected = controller.selectedRating.value == rating;
          return GestureDetector(
            onTap: () => controller.selectedRating.value = rating,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFB331) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFB331)
                      : const Color(0xFFE5E9F2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: isSelected ? Colors.white : const Color(0xff636F85),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xff636F85),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
