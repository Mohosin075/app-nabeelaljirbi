import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/controller/doctor_details_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/model/doctor_details_model.dart';
import 'package:flutter/material.dart';
import 'package:nabeelaljirbi_app/feature/patient/booking/model/patient_service_fee_model.dart';

class BookingController extends GetxController {
  final DoctorDetailsController doctorController =
      Get.find<DoctorDetailsController>();

  var selectedDateIndex = 0.obs;
  var selectedSlotIndex = (-1).obs;
  var isLoading = false.obs;
  var serviceFee = 0.0.obs;
  var isServiceFeeLoading = true.obs;

  RxList<Map<String, dynamic>> dates = <Map<String, dynamic>>[].obs;
  RxList<Slot> availableSlots = <Slot>[].obs;

  // Getters to fix reference errors in UI
  List<String> get timeSlots => availableSlots.map((slot) {
    return formatSlotTime(slot);
  }).toList();

  RxInt get selectedTimeSlotIndex => selectedSlotIndex;

  @override
  void onInit() {
    super.onInit();
    _generateDates();
    _updateAvailableSlots(0);
    fetchServiceFee();
  }

  Future<void> fetchServiceFee() async {
    isServiceFeeLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      if (token == null) return;

      final url = '${Urls.baseUrl}/patient-service-fee';
      debugPrint('🌍 Fetching Service Fee: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('📥 Service Fee Response Status: ${response.statusCode}');
      debugPrint('📥 Service Fee Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List data = body['data'];
          if (data.isNotEmpty) {
            final String clinicCountry =
                (doctorController.doctorDetails.value?.clinicCountry ?? '')
                    .toLowerCase();

            var matchedFeeData = data.firstWhere((fee) {
              final feeCountry =
                  (fee['country'] as String?)?.toLowerCase() ?? '';
              return feeCountry == clinicCountry;
            }, orElse: () => data.first);

            final feeData = PatientServiceFeeModel.fromJson(matchedFeeData);
            serviceFee.value = feeData.amount ?? 0.0;
            debugPrint(
              '✅ Service Fee Loaded: ${serviceFee.value} for clinic country: $clinicCountry',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching service fee: $e');
    } finally {
      isServiceFeeLoading.value = false;
    }
  }

  void _generateDates() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> generatedDates = [];
    for (int i = 0; i < 7; i++) {
      // Find next 7 days
      final date = now.add(Duration(days: i));
      generatedDates.add({
        'day': DateFormat('EEE').format(date),
        'date': DateFormat('dd').format(date),
        'fullDate': date,
      });
    }
    dates.value = generatedDates;
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    selectedSlotIndex.value = -1;
    _updateAvailableSlots(index);
  }

  void _updateAvailableSlots(int dateIndex) {
    if (doctorController.doctorDetails.value == null ||
        doctorController.doctorDetails.value!.schedule == null) {
      availableSlots.clear();
      return;
    }

    final selectedDateMap = dates[dateIndex];
    final DateTime selectedDate = selectedDateMap['fullDate'];
    final String dayName = DateFormat(
      'EEEE',
    ).format(selectedDate).toLowerCase();

    // The API might return capitalized days or lowercase, ensuring robust check
    // Logic: find schedule matching this day
    try {
      final schedule = doctorController.doctorDetails.value!.schedule!
          .firstWhere((element) => element.day?.toLowerCase() == dayName);

      if (schedule.slots != null) {
        availableSlots.value = List.from(schedule.slots!);
      } else {
        availableSlots.value = [];
      }
    } catch (e) {
      // No schedule found for this day
      availableSlots.value = [];
    }
  }

  void selectTimeSlot(int index) {
    selectedSlotIndex.value = index;
  }

  // Helper to format time for display
  String formatSlotTime(Slot slot) {
    return "${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}";
  }

  String formatTime(String? time) {
    if (time == null) return "";
    try {
      final dateTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("h:mm a").format(dateTime);
    } catch (e) {
      try {
        final dateTime = DateFormat("HH:mm").parse(time);
        return DateFormat("h:mm a").format(dateTime);
      } catch (e) {
        return time;
      }
    }
  }

  Future<void> bookAppointment() async {
    if (selectedSlotIndex.value == -1) {
      Get.snackbar('Error', 'Please select a time slot');
      return;
    }

    final doctor = doctorController.doctorDetails.value!;
    final slot = availableSlots[selectedSlotIndex.value];
    final selectedDateMap = dates[selectedDateIndex.value];
    final DateTime selectedDate = selectedDateMap['fullDate'];

    debugPrint("DEBUGGING: Selected Slot StartTime: ${slot.startTime}");
    debugPrint("DEBUGGING: Selected Date: ${selectedDate.toIso8601String()}");

    int hours = 0;
    int minutes = 0;

    if (slot.startTime != null && slot.startTime!.isNotEmpty) {
      try {
        final timeParts = slot.startTime!.split(':');
        if (timeParts.length >= 2) {
          // Clean up string: remove anything after digits (like .000Z)
          String hStr = timeParts[0].replaceAll(RegExp(r'[^0-9]'), '');
          String mStr = timeParts[1].replaceAll(RegExp(r'[^0-9]'), '');

          if (hStr.isNotEmpty) hours = int.parse(hStr);
          if (mStr.isNotEmpty) minutes = int.parse(mStr);
        } else {
          // Try parsing as ISO if it's not HH:mm
          final dt = DateTime.tryParse(slot.startTime!);
          if (dt != null) {
            hours = dt.hour;
            minutes = dt.minute;
          }
        }
      } catch (e) {
        debugPrint("Error parsing time '${slot.startTime}': $e");
      }
    }

    DateTime consultDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      hours,
      minutes,
    );

    // If time was parsed successfully, we send ISO.
    // If not, we still send ISO but with midnight (as fallback).
    // The backend seems to prefer ISO or at least a format it can set science on.
    final consultDateString = consultDateTime.toUtc().toIso8601String();

    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/patient/appointment-booking';
      final body = jsonEncode({
        "clinicId": doctor.clinicId,
        "doctorId": doctor.doctorId,
        "workingSlotId": slot.id,
        "consultDate": consultDateString,
      });

      debugPrint('Booking Appointment: $url');
      debugPrint('Clinic ID: ${doctor.clinicId}');
      debugPrint('Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.offNamed(AppRoutes.bookingConfirmation);
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          'Booking failed: ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
