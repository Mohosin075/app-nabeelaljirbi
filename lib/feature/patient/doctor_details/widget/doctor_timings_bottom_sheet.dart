import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/model/doctor_details_model.dart';

class DoctorTimingsBottomSheet extends StatelessWidget {
  final List<ScheduleDay> schedules;

  const DoctorTimingsBottomSheet({super.key, required this.schedules});

  String _formatTime(String time) {
    try {
      DateTime dateTime;
      try {
        dateTime = DateFormat("HH:mm:ss").parse(time);
      } catch (e) {
        dateTime = DateFormat("HH:mm").parse(time);
      }

      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour < 12 ? 'am'.tr : 'pm'.tr;
      final displayHour = hour > 12
          ? hour - 12
          : hour == 0
          ? 12
          : hour;
      final displayMinute = minute.toString().padLeft(2, '0');

      return "$displayHour:$displayMinute $period";
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                'schedule'.tr,
                style: globalTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xff636F85)),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'day'.tr,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
                Text(
                  'time'.tr,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF5F5F5)),
          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'no_schedule_available'.tr,
                  style: globalTextStyle(
                    fontSize: 16,
                    color: const Color(0xff636F85),
                  ),
                ),
              ),
            )
          else
            ...schedules.map((item) {
              String timeString;
              if (item.slots != null && item.slots!.isNotEmpty) {
                // Combining all slots for the day
                timeString = item.slots!
                    .map(
                      (slot) =>
                          '${_formatTime(slot.startTime ?? "")} - ${_formatTime(slot.endTime ?? "")}',
                    )
                    .join('\n'); // New line for multiple slots
              } else {
                timeString = 'closed'.tr;
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Get.locale?.languageCode == 'ar'
                              ? (item.day ?? '').toLowerCase().tr
                              : (item.day ?? '').toLowerCase().capitalizeFirst ?? '',
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff1A1A1A),
                          ),
                        ),
                        Text(
                          timeString,
                          textAlign: TextAlign.right,
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff636F85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF5F5F5), height: 1),
                ],
              );
            }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
