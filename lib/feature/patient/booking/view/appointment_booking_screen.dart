import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/booking/controller/booking_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/booking/widget/confirm_booking_bottom_sheet.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_profile_controller.dart';

class AppointmentBookingScreen extends StatelessWidget {
  AppointmentBookingScreen({super.key});

  final BookingController controller = Get.put(BookingController());
  final PatientProfileController profileController =
      Get.find<PatientProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            IconsPath.backArrow,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'book_appointment'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(color: Color(0xFFF5F5F5), thickness: 1, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'choose_time_slot'.tr,
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'select_date_schedule_desc'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        color: const Color(0xff636F85),
                        lineHeight: 1.5,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'select_date'.tr,
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.dates.length,
                        itemBuilder: (context, index) {
                          return Obx(() {
                            bool isSelected =
                                controller.selectedDateIndex.value == index;
                            return GestureDetector(
                              onTap: () => controller.selectDate(index),
                              child: Container(
                                width: 64,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : const Color(0xFFE5E9F2),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (controller.dates[index]['day'] as String)
                                          .toLowerCase()
                                          .tr,
                                      style: globalTextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xff636F85),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.dates[index]['date']!,
                                      style: globalTextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xff1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'available_time'.tr,
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.availableSlots.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'no_schedule_available'.tr,
                              style: globalTextStyle(
                                fontSize: 14,
                                color: const Color(0xff636F85),
                              ),
                            ),
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(controller.timeSlots.length, (
                          index,
                        ) {
                          // We need to re-wrap selection state in Obx for each item?
                          // Actually since the parent is Obx, we can just check the value.
                          // But tracking individual selection is cleaner with internal Obx if valid.
                          // However, simpler to just rebuild the Wrap.
                          bool isSelected =
                              controller.selectedTimeSlotIndex.value == index;
                          return GestureDetector(
                            onTap: () => controller.selectTimeSlot(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor.withValues(
                                        alpha: 0.1,
                                      )
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : const Color(0xFFE5E9F2),
                                ),
                              ),
                              child: Text(
                                controller.timeSlots[index],
                                style: globalTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : const Color(0xff636F85),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Check if user has premium access before proceeding

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ConfirmBookingBottomSheet(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'continue'.tr,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
