import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/feature/patient/booking/controller/booking_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/controller/doctor_details_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/model/doctor_details_model.dart';

class OfflineDoctorController extends DoctorDetailsController {
  // The production initializer fetches the network; this fixture is offline.
  @override
  // ignore: must_call_super
  void onInit() {}
}

class OfflineBookingController extends BookingController {
  OfflineBookingController({super.client});
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
  result.clinicCountry = modelB ? 'EGYPT' : 'LIBYA';
  result.clinicServiceFeePercentage = 10;
  result.fixedPatientServiceFee = 75;
  result.patientServiceFeeAmount = modelB ? 10.08 : 75;
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefHelper.init();
    await SharedPrefHelper.saveToken('synthetic-token');
    Get.testMode = true;
  });
  tearDown(() {
    Get.reset();
  });
  test(
    'booking calendar follows the selected clinic date across midnight and clinic switches',
    () {
      final details = Get.put<DoctorDetailsController>(
        OfflineDoctorController(),
      );
      final first = doctor('a', 'slot-a')..clinicLocalDate = '2026-10-31';
      details.doctorDetails.value = first;
      final booking = Get.put<BookingController>(OfflineBookingController());
      expect(booking.dates.first['fullDate'], DateTime(2026, 10, 31));
      details.doctorDetails.value = doctor('b', 'slot-b')
        ..clinicLocalDate = '2026-11-01';
      expect(booking.dates.first['fullDate'], DateTime(2026, 11, 1));
      expect(booking.selectedSlotIndex.value, -1);
    },
  );
  test(
    'inactive working periods cannot remain selectable after a clinic refresh',
    () async {
      final details = Get.put<DoctorDetailsController>(
        OfflineDoctorController(),
      );
      final data = doctor('a', 'active');
      data.schedule!.first.slots!.add(Slot(id: 'inactive', isActive: false));
      details.doctorDetails.value = data;
      final booking = Get.put<BookingController>(OfflineBookingController());
      expect(booking.availableSlots.map((s) => s.id), ['active']);
    },
  );
  testWidgets(
    'family booking submits the captured clinic/date once and navigates only after success',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const Scaffold(body: Text('booking form')),
            ),
            GetPage(
              name: AppRoutes.bookingConfirmation,
              page: () => const Scaffold(body: Text('request sent')),
            ),
          ],
        ),
      );
      final details = Get.put<DoctorDetailsController>(
        OfflineDoctorController(),
      );
      details.doctorDetails.value = doctor('a', 'slot-a');
      final reply = Completer<http.Response>(), started = Completer<void>();
      int requests = 0;
      final client = MockClient((request) async {
        requests++;
        expect(request.headers['Authorization'], 'synthetic-token');
        final body = jsonDecode(request.body);
        expect(body['clinicId'], 'a');
        expect(body['workingSlotId'], 'slot-a');
        expect(body['bookedFor'], 'FAMILY');
        expect(body['familyMemberName'], 'Dependent');
        expect(body['consultDate'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
        expect(body.containsKey('holdAmount'), false);
        started.complete();
        return reply.future;
      });
      final booking = Get.put<BookingController>(
        OfflineBookingController(client: client),
      );
      booking.selectedSlotIndex.value = 0;
      booking.bookedFor.value = 'FAMILY';
      booking.familyMemberNameController.text = ' Dependent ';
      final submission = booking.bookAppointment();
      await started.future;
      await booking.bookAppointment();
      expect(requests, 1);
      details.doctorDetails.value = doctor('b', 'slot-b', modelB: true);
      reply.complete(
        http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'id': 'synthetic-booking',
              'status': 'PENDING',
              'clinicId': 'a',
            },
          }),
          201,
        ),
      );
      await submission;
      await tester.pumpAndSettle();
      expect(find.text('request sent'), findsOneWidget);
      expect(Get.arguments['clinicId'], 'a');
      expect(booking.isLoading.value, false);
      client.close();
    },
  );
  testWidgets(
    'clinic funding errors do not ask the patient to recharge their own wallet',
    (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: Text('booking form'))),
      );
      final details = Get.put<DoctorDetailsController>(
        OfflineDoctorController(),
      );
      details.doctorDetails.value = doctor('a', 'slot-a');
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'success': false,
            'message':
                'Clinic wallet balance is insufficient for this booking.',
          }),
          409,
        ),
      );
      final booking = Get.put<BookingController>(
        OfflineBookingController(client: client),
      );
      booking.selectedSlotIndex.value = 0;
      await booking.bookAppointment();
      await tester.pumpAndSettle();
      expect(find.text('insufficient_wallet_title'), findsNothing);
      expect(
        find.text('Clinic wallet balance is insufficient for this booking.'),
        findsOneWidget,
      );
      expect(booking.isLoading.value, false);
      client.close();
    },
  );

  testWidgets(
    'a rejected 200 response stays on booking and never displays request success',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const Scaffold(body: Text('booking form')),
            ),
            GetPage(
              name: AppRoutes.bookingConfirmation,
              page: () => const Scaffold(body: Text('request sent')),
            ),
          ],
        ),
      );
      final details = Get.put<DoctorDetailsController>(
        OfflineDoctorController(),
      );
      details.doctorDetails.value = doctor('a', 'slot-a');
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'success': false, 'message': 'Request rejected'}),
          200,
        ),
      );
      final booking = Get.put<BookingController>(
        OfflineBookingController(client: client),
      );
      booking.selectedSlotIndex.value = 0;
      await booking.bookAppointment();
      await tester.pumpAndSettle();
      expect(find.text('request sent'), findsNothing);
      expect(find.text('Request rejected'), findsOneWidget);
      expect(booking.isLoading.value, false);
      client.close();
    },
  );

  testWidgets('insufficient patient balance uses the selected clinic currency', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final details = Get.put<DoctorDetailsController>(OfflineDoctorController());
    details.doctorDetails.value = doctor('egypt', 'slot-egypt', modelB: true);
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'success': false,
          'message':
              'Insufficient wallet balance. Required hold: 83.05 EGP, Available balance: 10.00 EGP',
        }),
        400,
      ),
    );
    final booking = Get.put<BookingController>(
      OfflineBookingController(client: client),
    );
    booking.selectedSlotIndex.value = 0;
    await booking.bookAppointment();
    await tester.pumpAndSettle();
    expect(find.text('83.05 currency_egypt'), findsOneWidget);
    expect(find.text('10.00 currency_egypt'), findsOneWidget);
    client.close();
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
      expect(booking.bookingCurrencySymbol, 'currency_libya');
      booking.selectedSlotIndex.value = 0;
      details.doctorDetails.value = doctor('b', 'slot-b', modelB: true);
      await Future<void>.delayed(Duration.zero);
      expect(booking.selectedSlotIndex.value, -1);
      expect(booking.selectedDateIndex.value, 0);
      expect(booking.availableSlots.single.id, 'slot-b');
      expect(booking.collectionMode, 'MODE_B');
      expect(booking.serviceFee.value, 10.08);
      expect(booking.requiredPatientHoldAmount, 110.83);
      expect(booking.bookingCurrencySymbol, 'currency_egypt');
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
