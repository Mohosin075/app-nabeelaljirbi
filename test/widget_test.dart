import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/common/operations/operations_menu.dart';
import 'package:nabeelaljirbi_app/feature/common/operations/phase_one_api.dart';
import 'package:nabeelaljirbi_app/feature/common/operations/profile_changes_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/model/appointment_history_model.dart';
import 'package:nabeelaljirbi_app/feature/doctor/reports/controller/doctor_reconciliation_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefHelper.init();
    Get.testMode = true;
  });
  tearDown(() => Get.reset());
  test(
    'approved public-profile edit submits only public fields to the existing upload endpoint',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'PATCH');
        expect(request.url.path.endsWith('/doctor/profile-update'), true);
        expect(
          request.body.contains('"about":"Reviewed public description"'),
          true,
        );
        expect(request.body.contains('fullName'), false);
        expect(request.body.contains('consultFee'), false);
        expect(request.body.contains('profileApproved'), false);
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'accessToken': 'synthetic-new-token'},
          }),
          200,
        );
      });
      final saved = await PhaseOneApi.updatePublicDetails(
        'DOCTOR',
        about: 'Reviewed public description',
        client: client,
      );
      expect(saved['accessToken'], 'synthetic-new-token');
      client.close();
    },
  );
  test(
    'doctor reconciliation export captures the same clinic, dates, shift and search as the screen',
    () {
      final controller = DoctorReconciliationController();
      controller.selectedClinicId.value = 'selected-clinic';
      controller.selectedPeriod.value = 'custom';
      controller.customStartDate.value = DateTime(2026, 10, 1);
      controller.customEndDate.value = DateTime(2026, 10, 31);
      controller.selectedShift.value = 'morning';
      controller.selectedStatus.value = 'COMPLETE';
      controller.searchQuery.value = '+218 123';
      final filters = controller.exportFilters;
      expect(filters['clinicId'], 'selected-clinic');
      expect(filters['startDate'], '2026-10-01');
      expect(filters['endDate'], '2026-10-31');
      expect(filters['shift'], 'morning');
      expect(filters['status'], 'COMPLETE');
      expect(filters['searchTerm'], '+218 123');
      controller.onClose();
    },
  );
  test(
    'authenticated API preserves filters and sends the saved token once',
    () async {
      await SharedPrefHelper.saveToken('Bearer synthetic-test');
      final client = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer synthetic-test');
        expect(request.url.queryParameters['status'], 'DOCTOR_ABSENT');
        expect(request.url.queryParameters['startDate'], '2026-10-01');
        expect(request.url.queryParameters.containsKey('doctorId'), false);
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'data': [],
              'meta': {'total': 0},
            },
          }),
          200,
        );
      });
      final data = await PhaseOneApi.call(
        'bookings',
        query: {
          'status': 'DOCTOR_ABSENT',
          'startDate': '2026-10-01',
          'doctorId': '',
        },
        client: client,
      );
      expect(data['meta']['total'], 0);
      client.close();
    },
  );
  test(
    'API rejection is surfaced instead of reporting a successful withdrawal',
    () async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'success': false,
            'message':
                'Doctor withdrawal requests require enabled remote consultations',
          }),
          403,
        ),
      );
      await expectLater(
        PhaseOneApi.call(
          'payouts',
          method: 'POST',
          body: {'amount': 5, 'payoutMethod': 'CASH'},
          client: client,
        ),
        throwsA(predicate((e) => e.toString().contains('enabled remote'))),
      );
      client.close();
    },
  );
  test('report download preserves date and type filters', () async {
    final client = MockClient((request) async {
      expect(request.url.path.endsWith('/reports/wallet/pdf'), true);
      expect(request.url.queryParameters['type'], 'WITHDRAW');
      expect(request.url.queryParameters['endDate'], '2026-10-31');
      return http.Response('%PDF-synthetic', 200);
    });
    final result = await PhaseOneApi.download('wallet', 'pdf', {
      'type': 'WITHDRAW',
      'endDate': '2026-10-31',
    }, client: client);
    expect(utf8.decode(result), '%PDF-synthetic');
    client.close();
  });
  test('doctor absence display retains the compatible terminal status', () {
    final absent = Appointment.fromJson({
      'id': 'b',
      'status': 'CANCELLED',
      'absenceType': 'DOCTOR_ABSENT',
    });
    expect(absent.status, 'CANCELLED');
    expect(absent.displayStatus, 'DOCTOR_ABSENT');
    expect(
      Appointment.fromJson({'status': 'NOT_SHOW'}).displayStatus,
      'PATIENT_NO_SHOW',
    );
    expect(
      Appointment.fromJson({'status': 'CANCELLED'}).displayStatus,
      'CANCELLED',
    );
  });
  testWidgets('unapproved profile editor is available after the access check', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ApprovedProfileGate(
          accessLoader: () async => {'locked': false},
          builder: (_) => const Text('Editable profile'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Editable profile'), findsOneWidget);
  });
  testWidgets('failed profile access check hides editing and supports retry', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ApprovedProfileGate(
          accessLoader: () async {
            attempts++;
            if (attempts == 1) throw Exception('Offline');
            return {'locked': false};
          },
          builder: (_) => const Text('Editable profile'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Editable profile'), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Editable profile'), findsOneWidget);
  });
  testWidgets(
    'patient menu provides complaint tracking and excludes payout/staff controls',
    (tester) async {
      await SharedPrefHelper.saveRole('PATIENT');
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: OperationsMenu())),
      );
      expect(find.text('My complaints & responses'), findsOneWidget);
      expect(find.text('Bank details & withdrawals'), findsNothing);
      expect(find.text('Receptionists'), findsNothing);
    },
  );
  testWidgets('clinic owner menu exposes bank, booking and staff flows', (
    tester,
  ) async {
    await SharedPrefHelper.saveRole('CLINIC');
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: OperationsMenu())),
    );
    expect(find.text('Bank details & withdrawals'), findsOneWidget);
    expect(find.text('Manage bookings'), findsOneWidget);
    expect(find.text('Receptionists'), findsOneWidget);
    expect(find.text('My complaints & responses'), findsNothing);
  });
}
