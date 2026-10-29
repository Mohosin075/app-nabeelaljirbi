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
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/wallet/view/patient_wallet_screen.dart';

class BookingController extends GetxController {
  late final Worker _doctorWorker;
  final DoctorDetailsController doctorController =
      Get.find<DoctorDetailsController>();

  var selectedDateIndex = 0.obs;
  var selectedSlotIndex = (-1).obs;
  var isLoading = false.obs;
  var serviceFee = 0.0.obs;
  var isServiceFeeLoading = true.obs;
  var advanceBookingDays = 14.obs;

  // Family / Dependent booking fields
  var bookedFor = 'SELF'.obs; // 'SELF' or 'FAMILY'
  final TextEditingController familyMemberNameController =
      TextEditingController();
  var selectedFamilyRelation = 'SPOUSE'.obs;
  final List<String> familyRelations = [
    'SPOUSE',
    'CHILD',
    'PARENT',
    'SIBLING',
    'OTHER',
  ];

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
    fetchBookingSettings();
    _updateServiceFeeFromClinic();
    _doctorWorker = ever(doctorController.doctorDetails, (_) {
      selectedDateIndex.value = 0;
      selectedSlotIndex.value = -1;
      availableSlots.clear();
      if (dates.isNotEmpty) _updateAvailableSlots(0);
      _updateServiceFeeFromClinic();
    });
  }

  @override
  void onClose() {
    _doctorWorker.dispose();
    familyMemberNameController.dispose();
    super.onClose();
  }

  Future<void> fetchBookingSettings() async {
    try {
      final token = SharedPrefHelper.getAccessToken();
      if (token == null) return;

      final url = '${Urls.baseUrl}/patient/booking-settings';
      debugPrint('🌍 Fetching patient booking settings: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('📥 Booking Settings Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final configuredDays =
              int.tryParse('${body['data']['advanceBookingDays']}') ?? 14;
          if (configuredDays > 0 && configuredDays <= 365) {
            selectedDateIndex.value = 0;
            selectedSlotIndex.value = -1;
            advanceBookingDays.value = configuredDays;
            _generateDates();
            if (dates.isNotEmpty) _updateAvailableSlots(0);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching booking settings: $e');
    } finally {
      _updateServiceFeeFromClinic();
    }
  }

  void _updateServiceFeeFromClinic() {
    final doctor = doctorController.doctorDetails.value;
    if (doctor == null) {
      isServiceFeeLoading.value = false;
      return;
    }

    final consultationFee = (doctor.consultFee ?? 0).toDouble();
    final percentage = (doctor.clinicServiceFeePercentage ?? 0).toDouble();
    serviceFee.value =
        doctor.patientServiceFeeAmount?.toDouble() ??
        (doctor.clinicCollectionMode == 'MODE_B'
            ? double.parse(
                ((consultationFee * percentage) / 100).toStringAsFixed(2),
              )
            : (doctor.fixedPatientServiceFee ?? 0).toDouble());
    isServiceFeeLoading.value = false;
  }

  String get collectionMode =>
      doctorController.doctorDetails.value?.clinicCollectionMode ?? 'MODE_A';

  double get requiredPatientHoldAmount {
    final consultationFee =
        (doctorController.doctorDetails.value?.consultFee ?? 0).toDouble();
    return collectionMode == 'MODE_B'
        ? double.parse((consultationFee + serviceFee.value).toStringAsFixed(2))
        : serviceFee.value;
  }

  void _generateDates() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> generatedDates = [];
    // Advance-booking window (Phase 1 default is 14 days)
    for (int i = 0; i <= advanceBookingDays.value; i++) {
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
      Get.snackbar('error'.tr, 'please_select_time_slot'.tr);
      return;
    }

    final doctor = doctorController.doctorDetails.value!;
    if (collectionMode == 'MODE_A' && doctor.fixedPatientServiceFee == null) {
      Get.snackbar('error'.tr, 'clinic_fee_not_configured'.tr);
      return;
    }
    final slot = availableSlots[selectedSlotIndex.value];
    final selectedDateMap = dates[selectedDateIndex.value];
    final DateTime selectedDate = selectedDateMap['fullDate'];

    debugPrint("DEBUGGING: Selected Slot StartTime: ${slot.startTime}");
    debugPrint("DEBUGGING: Selected Date: ${selectedDate.toIso8601String()}");

    if (bookedFor.value == 'FAMILY' &&
        familyMemberNameController.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_enter_family_member_name'.tr);
      return;
    }

    // Send the selected clinic calendar date only. The server combines it
    // with the clinic-local working period and converts that moment to UTC.
    final consultDateString =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/patient/appointment-booking';
      final Map<String, dynamic> payloadMap = {
        "clinicId": doctor.clinicId,
        "doctorId": doctor.doctorId,
        "workingSlotId": slot.id,
        "consultDate": consultDateString,
        "bookedFor": bookedFor.value,
      };

      if (bookedFor.value == 'FAMILY') {
        payloadMap["familyMemberName"] = familyMemberNameController.text.trim();
        payloadMap["familyMemberRelation"] = selectedFamilyRelation.value;
      }

      final body = jsonEncode(payloadMap);

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
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        Get.offNamed(AppRoutes.bookingConfirmation);
      } else {
        String rawMsg = 'booking_failed_generic'.tr;
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            rawMsg = errorData['message'].toString();
          }
        } catch (_) {}
        _handleBookingError(rawMsg);
      }
    } catch (e) {
      _handleBookingError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _handleBookingError(String rawMsg) {
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    final lower = rawMsg.toLowerCase();
    if (lower.contains('insufficient wallet balance') ||
        (lower.contains('wallet') && lower.contains('balance'))) {
      String? requiredHold;
      String? availableBal;
      final holdMatch = RegExp(
        r'Required hold:\s*([0-9.]+)',
        caseSensitive: false,
      ).firstMatch(rawMsg);
      if (holdMatch != null) {
        requiredHold = holdMatch.group(1);
      }
      final availMatch = RegExp(
        r'Available balance:\s*([0-9.]+)',
        caseSensitive: false,
      ).firstMatch(rawMsg);
      if (availMatch != null) {
        availableBal = availMatch.group(1);
      }

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFFF57C00),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'insufficient_wallet_title'.tr,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'insufficient_wallet_desc'.tr,
                  style: globalTextStyle(
                    fontSize: 13,
                    color: const Color(0xFF636F85),
                    lineHeight: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (requiredHold != null || availableBal != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Column(
                      children: [
                        if (requiredHold != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'required_hold_amount'.tr,
                                style: globalTextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF636F85),
                                ),
                              ),
                              Text(
                                '$requiredHold ${'lyd'.tr}',
                                style: globalTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFD9480F),
                                ),
                              ),
                            ],
                          ),
                        if (requiredHold != null && availableBal != null)
                          const Divider(height: 16),
                        if (availableBal != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'available_balance'.tr,
                                style: globalTextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF636F85),
                                ),
                              ),
                              Text(
                                '$availableBal ${'lyd'.tr}',
                                style: globalTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF495057),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.to(() => PatientWalletScreen());
                    },
                    icon: const Icon(
                      Icons.add_card,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'top_up_wallet'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'cancel'.tr,
                    style: globalTextStyle(
                      fontSize: 13,
                      color: const Color(0xFF636F85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (lower.contains('capacity') && lower.contains('full')) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_busy,
                    color: Color(0xFFD32F2F),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'booking_failed_title'.tr,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'slot_fully_booked'.tr,
                  style: globalTextStyle(
                    fontSize: 13,
                    color: const Color(0xFF636F85),
                    lineHeight: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'close'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFD32F2F),
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'booking_failed_title'.tr,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  rawMsg,
                  style: globalTextStyle(
                    fontSize: 13,
                    color: const Color(0xFF636F85),
                    lineHeight: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'close'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
