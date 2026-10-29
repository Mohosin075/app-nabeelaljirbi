import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/appointment/model/doctor_appointment_model.dart';

class DoctorHomeScreenController extends GetxController {
  // Observable statistics
  var totalBook = 0.obs;
  var todayCount = 0.obs;
  var upcomingCount = 0.obs;
  var consultationGross = 0.0.obs;

  // Observable appointment list
  var appointments = <Appointment>[].obs;
  var isLoading = false.obs;

  // Observable selected tab (0=Pending, 1=Upcoming, 2=Arrived, 3=Completed)
  var selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getHomeData();
  }

  Future<void> getHomeData() async {
    isLoading.value = true;
    try {
      await Future.wait([getTodayAppointments(), getStatistics()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTodayAppointments() async {
    try {
      final token = SharedPrefHelper.getAccessToken();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final collected = <Appointment>[];
      for (var page = 1; page <= 1000; page++) {
        final response = await http.get(
          Uri.parse(
            '${Urls.baseUrl}/doctor/appointments?consultDate=$today&page=$page&limit=100',
          ),
          headers: {
            'Authorization': token ?? '',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode != 200) {
          throw Exception('Unable to load appointments');
        }
        final model = DoctorAppointmentModel.fromJson(
          jsonDecode(response.body),
        );
        if (model.success != true || model.data == null) {
          throw Exception('Invalid appointment response');
        }
        final rows = model.data!.data ?? [];
        collected.addAll(rows);
        if (collected.length >= (model.data!.meta?.total ?? 0)) break;
        if (rows.isEmpty) throw Exception('Incomplete appointment response');
      }
      appointments.assignAll(collected);
    } catch (error) {
      debugPrint('Error fetching today appointments: $error');
    }
  }

  Future<void> getStatistics() async {
    // Assuming there might be a stats endpoint or we just use meta from appointments
    // For now, let's fetch all (or a large page) to get some counts if no specific endpoint
    try {
      final token = SharedPrefHelper.getAccessToken();
      String url = '${Urls.baseUrl}/doctor/appointments';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final model = DoctorAppointmentModel.fromJson(body);

        if (model.success == true && model.data != null) {
          final statistics = body['data']?['statistics'];
          if (statistics is Map) {
            consultationGross.value =
                (statistics['consultationGross'] as num? ?? 0).toDouble();
            totalBook.value = (statistics['totalBookings'] as num? ?? 0)
                .toInt();
            todayCount.value = (statistics['todayCount'] as num? ?? 0).toInt();
            upcomingCount.value = (statistics['upcomingCount'] as num? ?? 0)
                .toInt();
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
    }
  }

  // Filter appointments based on selected tab
  List<Appointment> get filteredAppointments {
    return appointments.where((apt) {
      final status = apt.status?.toUpperCase() ?? 'PENDING';
      if (selectedTab.value == 0) {
        return status == 'PENDING';
      } else if (selectedTab.value == 1) {
        return status == 'CONFIRMED' || status == 'INPROGRESS';
      } else if (selectedTab.value == 2) {
        return status == 'ARRIVED';
      } else {
        return status == 'COMPLETE';
      }
    }).toList();
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }
}
