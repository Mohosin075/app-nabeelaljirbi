import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_availability_controller.dart';

class DoctorAvailabilityScreen extends StatelessWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorAvailabilityController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'set_your_availability'.tr,
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
        child: Obx(
          () => controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'select_working_day'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        children: controller.days.map((day) {
                          final isSelected =
                              controller.selectedDay.value == day;
                          return GestureDetector(
                            onTap: () => controller.selectDay(day),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xff137CCF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xff137CCF)
                                      : const Color(0xffE5E9F2),
                                ),
                              ),
                              child: Text(
                                day.toLowerCase().tr,
                                style: globalTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xff636F85),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'set_time_slots'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: List.generate(
                          controller.currentSlots.length,
                          (index) {
                            final slot = controller.currentSlots[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xffF9F9FB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xffE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => controller.pickStartTime(
                                            context,
                                            index,
                                          ),
                                          child: _buildTimeBox(
                                            context,
                                            controller.parseTimeString(
                                              slot.startTime,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text('-'),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => controller.pickEndTime(
                                            context,
                                            index,
                                          ),
                                          child: _buildTimeBox(
                                            context,
                                            controller.parseTimeString(
                                              slot.endTime,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Switch(
                                          value: slot.isActive ?? true,
                                          onChanged: (val) =>
                                              controller.toggleTimeSlot(index),
                                          activeThumbColor: const Color(
                                            0xff137CCF,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        'capacity'.tr,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xff636F85),
                                        ),
                                      ),
                                      const Spacer(),
                                      _buildCapacityCounter(
                                        controller,
                                        index,
                                        slot.capacity ?? 0,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: controller.addTimeSlot,
                          icon: const Icon(
                            Icons.add,
                            color: Color(0xff137CCF),
                            size: 18,
                          ),
                          label: Text(
                            'add_more'.tr,
                            style: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff137CCF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.saveWorkingHours,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff137CCF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: controller.isSaving.value
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
    );
  }

  Widget _buildTimeBox(BuildContext context, TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final formattedTime = "$hour:$minute $period";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE5E9F2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          formattedTime,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xff2D2D2D),
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityCounter(
    DoctorAvailabilityController controller,
    int index,
    int current,
  ) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => controller.updateSlotCapacity(index, current - 1),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffE5E9F2)),
            ),
            child: const Icon(Icons.remove, size: 16, color: Color(0xff636F85)),
          ),
        ),
        Container(
          width: 48,
          alignment: Alignment.center,
          child: Text(
            '$current',
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xff2D2D2D),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => controller.updateSlotCapacity(index, current + 1),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xff137CCF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
