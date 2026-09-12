import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/patient/filter/controller/patient_filter_controller.dart';

class PatientFilterBottomSheet extends StatelessWidget {
  final VoidCallback? onApply;
  PatientFilterBottomSheet({super.key, this.onApply});

  final PatientFilterController controller = Get.put(PatientFilterController());

  @override
  Widget build(BuildContext context) {
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
              _buildLabel('country'.tr),
              _buildDropdown(
                value: controller.selectedCountry,
                items: controller.countries,
                onChanged: (val) => controller.updateCountry(val!),
              ),
              const SizedBox(height: 16),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('city'.tr),
                    _buildDropdown(
                      value: controller.selectedCity,
                      items: controller.cities,
                      onChanged: (val) => controller.updateCity(val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('specialty'.tr),
              Obx(
                () => _buildDropdown(
                  value: controller.selectedSpecialty,
                  items: controller.specialties,
                  onChanged: (val) => controller.updateSpecialty(val!),
                ),
              ),
              const SizedBox(height: 16),
              /*
              _buildLabel('availability'.tr),
              _buildDatePicker(context),
              const SizedBox(height: 16),
              */
              _buildLabel('consultation_fee'.tr),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFE5E9F2),
                        inactiveTrackColor: const Color(
                          0xFFE5E9F2,
                        ).withValues(alpha: 0.5),
                        thumbColor: Colors.white,
                        overlayColor: AppColors.primaryColor.withValues(
                          alpha: 0.12,
                        ),
                        trackHeight: 12.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10.0,
                        ),
                      ),
                      child: Slider(
                        value: controller.priceRange.value,
                        min: 0,
                        max: 1000,
                        onChanged: (val) => controller.updatePriceRange(val),
                      ),
                    ),
                    Text(
                      '${controller.priceRange.value.toInt()} ${CurrencyUtil.getUserCurrencySymbol()}',
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
              /*
              _buildLabel('insurance_accepted'.tr),
              _buildDropdown(
                value: controller.selectedInsurance,
                items: controller.insurances,
                onChanged: (val) => controller.updateInsurance(val!),
              ),
              const SizedBox(height: 16),
              */
              _buildLabel('minimum_rating'.tr),
              _buildRatingSelector(),

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
                        Get.back();
                        if (onApply != null) {
                          onApply!();
                        }
                        // Filtering logic will be handled by the respective screen's controller
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
    required Function(String?) onChanged,
  }) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E9F2)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value.value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xff636F85),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  _getLocalizedText(item),
                  style: globalTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff636F85),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          int rating = 5 - index;
          bool isSelected = controller.minRating.value == rating;
          return GestureDetector(
            onTap: () => controller.updateMinRating(rating),
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

  /*
  Widget _buildDatePicker(BuildContext context) {
    ...
  }
  */

  String _getLocalizedText(String item) {
    if (item == 'all') {
      return 'all'.tr;
    }
    return item.tr;
  }
}
