import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/feature/patient/booking/controller/booking_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/controller/doctor_details_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/model/doctor_details_model.dart';

class OfflineDoctorController extends DoctorDetailsController {
  @override
  void onInit() {}
}

class OfflineBookingController extends BookingController {
  @override
  Future<void> fetchBookingSettings() async {}
}

DoctorDetailData doctor(String clinic, String slot, {bool modelB = false}) {
  final result = DoctorDetailData(
    doctorId: 'doctor',
    clinicId: clinic,
    consultFee: modelB ? 100.75 : 75,
    schedule: [
      ScheduleDay(
        day: DateFormat('EEEE').format(DateTime.now()).toUpperCase(),
        slots: [
          Slot(id: slot, startTime: '09:00', endTime: '12:00', isActive: true),
        ],
      ),
    ],
  );
  result.clinicCollectionMode = modelB ? 'MODE_B' : 'MODE_A';
  result.clinicServiceFeePercentage = 10;
  result.fixedPatientServiceFee = 75;
  result.patientServiceFeeAmount = modelB ? 10.08 : 75;
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
  });
  tearDown(() {
    Get.reset();
  });

  test(
    'switching clinic clears the old selection, replaces slots and refreshes the quoted fee',
    () async {
      final details = Get.put<DoctorDetailsController>(
        OfflineDoctorController(),
      );
      details.doctorDetails.value = doctor('a', 'slot-a');
      final booking = Get.put<BookingController>(OfflineBookingController());
      expect(booking.serviceFee.value, 75);
      booking.selectedSlotIndex.value = 0;
      details.doctorDetails.value = doctor('b', 'slot-b', modelB: true);
      await Future<void>.delayed(Duration.zero);
      expect(booking.selectedSlotIndex.value, -1);
      expect(booking.selectedDateIndex.value, 0);
      expect(booking.availableSlots.single.id, 'slot-b');
      expect(booking.collectionMode, 'MODE_B');
      expect(booking.serviceFee.value, 10.08);
      expect(booking.requiredPatientHoldAmount, 110.83);
    },
  );

  test(
    'switching to a clinic without a schedule removes stale bookable slots',
    () async {
      final details = Get.put<DoctorDetailsController>(
        OfflineDoctorController(),
      );
      details.doctorDetails.value = doctor('a', 'slot-a');
      final booking = Get.put<BookingController>(OfflineBookingController());
      expect(booking.availableSlots, isNotEmpty);
      final other = doctor('b', 'slot-b')..schedule = [];
      details.doctorDetails.value = other;
      await Future<void>.delayed(Duration.zero);
      expect(booking.availableSlots, isEmpty);
      expect(booking.selectedSlotIndex.value, -1);
    },
  );

  test(
    'a late response from the previous clinic cannot overwrite the newly selected clinic',
    () async {
      final firstReply = Completer<http.Response>();
      final firstStarted = Completer<void>();
      http.Response response(String clinic) => http.Response(
        jsonEncode({
          'success': true,
          'data': {'doctorId': 'doctor', 'clinicId': clinic, 'consultFee': 75},
        }),
        200,
      );
      final details = DoctorDetailsController(
        client: MockClient((request) async {
          if (request.url.queryParameters['clinicId'] == 'a') {
            firstStarted.complete();
            return firstReply.future;
          }
          return response('b');
        }),
      );
      final previous = details.getDoctorDetails('doctor', clinicId: 'a');
      await firstStarted.future;
      await details.getDoctorDetails('doctor', clinicId: 'b');
      firstReply.complete(response('a'));
      await previous;
      expect(details.doctorDetails.value?.clinicId, 'b');
      expect(details.requestedClinicId, 'b');
      expect(details.isLoading.value, false);
      details.onClose();
    },
  );
}
