import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/working_hours_model.dart';

class DoctorAvailabilityController extends GetxController {
  final List<String> days = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  var selectedDay = 'MONDAY'.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Store all days' schedules
  var allSchedules = <String, DaySchedule>{}.obs;

  // Observable list for the current day's slots in the UI
  var currentSlots = <WorkingSlot>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWorkingHours();
  }

  void selectDay(String day) {
    selectedDay.value = day;
    _updateUIFromSchedule();
  }

  Future<void> fetchWorkingHours() async {
    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/doctor/working-hours';

      debugPrint('Fetching Working Hours: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final model = WorkingHoursModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data?.slots != null) {
          // Reset schedules
          allSchedules.clear();
          for (var daySchedule in model.data!.slots!) {
            if (daySchedule.day != null) {
              allSchedules[daySchedule.day!] = daySchedule;
            }
          }
          _updateUIFromSchedule();
        }
      } else {
        Get.snackbar('error'.tr, 'failed_to_fetch_working_hours'.tr);
      }
    } catch (e) {
      debugPrint('Error fetching working hours: $e');
      Get.snackbar('error'.tr, 'error_fetching_working_hours'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUIFromSchedule() {
    final schedule = allSchedules[selectedDay.value];
    if (schedule != null && schedule.slots != null) {
      currentSlots.assignAll(schedule.slots!);
    } else {
      currentSlots.clear();
    }
  }

  Future<void> saveWorkingHours() async {
    if (isSaving.value) return;

    isSaving.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/doctor/working-hours';

      final body = {
        "day": selectedDay.value,
        "slots": currentSlots
            .map(
              (slot) => {
                "startTime": slot.startTime,
                "endTime": slot.endTime,
                "capacity": slot.capacity,
                "isActive": slot.isActive ?? true,
              },
            )
            .toList(),
      };

      debugPrint('Saving Working Hours Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          'working_hours_saved_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        // Refresh local data for this day
        allSchedules[selectedDay.value] = DaySchedule(
          day: selectedDay.value,
          slots: List.from(currentSlots),
        );
      } else {
        final error = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          error['message'] ?? 'failed_to_save_working_hours'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error saving working hours: $e');
      Get.snackbar('error'.tr, 'error_occurred_while_saving'.tr);
    } finally {
      isSaving.value = false;
    }
  }

  void addTimeSlot() {
    currentSlots.add(
      WorkingSlot(
        startTime: "09:00.000Z",
        endTime: "17:00.000Z",
        capacity: 10,
        isActive: true,
      ),
    );
  }

  void toggleTimeSlot(int index) {
    var slot = currentSlots[index];
    currentSlots[index] = WorkingSlot(
      id: slot.id,
      startTime: slot.startTime,
      endTime: slot.endTime,
      capacity: slot.capacity,
      isActive: !(slot.isActive ?? true),
    );
  }

  void updateSlotCapacity(int index, int newCapacity) {
    if (newCapacity < 1) return;
    var slot = currentSlots[index];
    currentSlots[index] = WorkingSlot(
      id: slot.id,
      startTime: slot.startTime,
      endTime: slot.endTime,
      capacity: newCapacity,
      isActive: slot.isActive,
    );
  }

  TimeOfDay parseTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    try {
      // Handle HH:mm.SSSZ or ISO format
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
        final minute = int.parse(
          parts[1].split('.')[0].replaceAll(RegExp(r'[^0-9]'), ''),
        );
        return TimeOfDay(hour: hour, minute: minute);
      }
      return const TimeOfDay(hour: 0, minute: 0);
    } catch (e) {
      debugPrint("Error parsing time string $timeStr: $e");
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return "$hour:$minute.000Z";
  }

  Future<void> pickStartTime(BuildContext context, int index) async {
    final initial = parseTimeString(currentSlots[index].startTime);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      var slot = currentSlots[index];
      currentSlots[index] = WorkingSlot(
        id: slot.id,
        startTime: formatTimeOfDay(picked),
        endTime: slot.endTime,
        capacity: slot.capacity,
        isActive: slot.isActive,
      );
    }
  }

  Future<void> pickEndTime(BuildContext context, int index) async {
    final initial = parseTimeString(currentSlots[index].endTime);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      var slot = currentSlots[index];
      currentSlots[index] = WorkingSlot(
        id: slot.id,
        startTime: slot.startTime,
        endTime: formatTimeOfDay(picked),
        capacity: slot.capacity,
        isActive: slot.isActive,
      );
    }
  }
}
