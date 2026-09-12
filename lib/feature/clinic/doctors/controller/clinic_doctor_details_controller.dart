import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/model/doctor_details_model.dart';
import '../../home/model/appointment_model.dart';
import '../model/clinic_doctor_model.dart';
import '../model/doctor_appointments_model.dart';

class ClinicDoctorDetailsController extends GetxController {
  final Rx<ClinicDoctorItem?> initialDoctor = Rx<ClinicDoctorItem?>(null);
  final Rxn<DoctorDetailData> doctorDetails = Rxn<DoctorDetailData>();
  final RxBool isLoading = true.obs;
  final RxBool isLoadingAppointments = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedAppointmentTab = 'arrived'.obs;

  final List<String> appointmentTabs = [
    'pending',
    'confirmed',
    'arrived',
    'completed',
    'cancelled',
    'unresolved',
  ];

  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxBool isExpanded = false.obs;

  void setDoctor(ClinicDoctorItem doctorModel) {
    initialDoctor.value = doctorModel;
    if (doctorModel.doctorId != null) {
      getDoctorDetails(doctorModel.doctorId!);
      getDoctorAppointments(doctorModel.doctorId!);
    } else {
      errorMessage.value = "doctor_id_missing".tr;
      isLoading.value = false;
    }
  }

  Future<void> getDoctorDetails(String doctorId) async {
    try {
      isLoading(true);
      errorMessage.value = '';
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/patient/get-doctor/$doctorId';

      debugPrint('Fetching Clinic Doctor Details: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = DoctorDetailsModel.fromJson(jsonData);
        if (model.success == true && model.data != null) {
          doctorDetails.value = model.data;
        } else {
          errorMessage.value =
              model.message ?? "failed_to_load_doctor_details".tr;
        }
      } else {
        errorMessage.value = "${"server_error".tr}: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "${"error_occurred".tr}: $e";
      debugPrint('Error fetching doctor details: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> getDoctorAppointments(String doctorId) async {
    try {
      isLoadingAppointments(true);
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/clinic/doctor-appointments/$doctorId';

      debugPrint('Fetching Doctor Appointments: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = DoctorAppointmentsModel.fromJson(jsonData);
        if (model.success == true && model.data?.data != null) {
          final mapped = model.data!.data!.map((item) {
            return AppointmentModel(
              id: item.id ?? '',
              patientName: item.patient?.user?.fullName ?? 'N/A',
              patientImage: item.patient?.user?.profileImage,
              time:
                  '${_formatApiTime(item.startTime)} - ${_formatApiTime(item.endTime)}',
              date: _formatApiDate(item.consultDate),
              doctorName: model.data?.doctor?.name ?? '',
              status: _mapStatus(item.status),
              queueNo: item.serialNumber ?? 0,
            );
          }).toList();
          appointments.assignAll(mapped);
        }
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      isLoadingAppointments(false);
    }
  }

  AppointmentStatus _mapStatus(String? apiStatus) {
    switch (apiStatus?.toUpperCase()) {
      case 'PENDING':
        return AppointmentStatus.pending;
      case 'NOTSHOWN':
      case 'NOT_SHOWN':
      case 'NO_SHOW':
      case 'NOT_SHOW':
        return AppointmentStatus.notShown;
      case 'NOTUPDATED':
      case 'NOT_UPDATED':
        return AppointmentStatus.notUpdated;
      case 'COMPLETE':
      case 'COMPLETED':
        return AppointmentStatus.completed;
      case 'ARRIVED':
        return AppointmentStatus.arrived;
      case 'CONFIRMED':
        return AppointmentStatus.confirmed;
      case 'CANCELLED':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  String _formatApiTime(String? time) {
    if (time == null) return "na".tr;
    try {
      // Time from API is often like "09:30.000Z"
      final cleanTime = time.contains('.') ? time.split('.').first : time;
      final dateTime = DateFormat("HH:mm").parse(cleanTime);
      return DateFormat("h:mm a").format(dateTime);
    } catch (e) {
      return time;
    }
  }

  String _formatApiDate(String? date) {
    if (date == null) return "na".tr;
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('EEEE, MMM d').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  List<AppointmentModel> get filteredAppointments {
    switch (selectedAppointmentTab.value) {
      case 'arrived':
        return appointments
            .where((e) => e.status == AppointmentStatus.arrived)
            .toList();
      case 'pending':
        return appointments
            .where((e) => e.status == AppointmentStatus.pending)
            .toList();
      case 'confirmed':
        return appointments
            .where((e) => e.status == AppointmentStatus.confirmed)
            .toList();
      case 'unresolved':
        return appointments
            .where(
              (e) =>
                  e.status == AppointmentStatus.notShown ||
                  e.status == AppointmentStatus.notUpdated,
            )
            .toList();
      case 'completed':
        return appointments
            .where((e) => e.status == AppointmentStatus.completed)
            .toList();
      case 'cancelled':
        return appointments
            .where((e) => e.status == AppointmentStatus.cancelled)
            .toList();
      default:
        return appointments;
    }
  }

  int getAppointmentCountByTab(String tab) {
    switch (tab) {
      case 'arrived':
        return appointments
            .where((e) => e.status == AppointmentStatus.arrived)
            .length;
      case 'pending':
        return appointments
            .where((e) => e.status == AppointmentStatus.pending)
            .length;
      case 'confirmed':
        return appointments
            .where((e) => e.status == AppointmentStatus.confirmed)
            .length;
      case 'unresolved':
        return appointments
            .where(
              (e) =>
                  e.status == AppointmentStatus.notShown ||
                  e.status == AppointmentStatus.notUpdated,
            )
            .length;
      case 'completed':
        return appointments
            .where((e) => e.status == AppointmentStatus.completed)
            .length;
      case 'cancelled':
        return appointments
            .where((e) => e.status == AppointmentStatus.cancelled)
            .length;
      default:
        return 0;
    }
  }

  Future<void> updateAppointmentStatus(String bookingId, String status) async {
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/update/appointment-status';

      final body = {'bookingId': bookingId, 'status': status};
      debugPrint('Updating Appointment: $url');
      debugPrint('Body: $body');

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Update Status Code: ${response.statusCode}');
      debugPrint('Update Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Get.snackbar(
            'success'.tr,
            data['message'] ?? 'status_updated_successfully'.tr,
            backgroundColor: AppColors.primaryColor,
            colorText: Colors.white,
          );
          if (initialDoctor.value?.doctorId != null) {
            getDoctorAppointments(initialDoctor.value!.doctorId!);
          }
        } else {
          Get.snackbar(
            'error'.tr,
            data['message'] ?? 'failed_to_update_status'.tr,
          );
        }
      } else {
        Get.snackbar('error'.tr, 'failed_to_update_status'.tr);
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    }
  }

  Future<bool> removeDoctor(String clinicDoctorId) async {
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/remove-clinic-doctor/$clinicDoctorId';

      debugPrint('Removing Doctor from Clinic: $url');

      final response = await http.patch(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('Remove Doctor Status Code: ${response.statusCode}');
      debugPrint('Remove Doctor Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error removing doctor: $e');
      return false;
    }
  }

  void changeTabIndex(int index) => selectedTabIndex.value = index;
  void changeAppointmentTab(String tab) => selectedAppointmentTab.value = tab;
  void toggleExpanded() => isExpanded.value = !isExpanded.value;
}
