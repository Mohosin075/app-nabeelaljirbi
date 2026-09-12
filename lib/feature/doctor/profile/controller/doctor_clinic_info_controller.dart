import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/clinic_list_model.dart';

class DoctorClinicInfoController extends GetxController {
  final _profileController = Get.find<DoctorProfileController>();

  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var isUpdating = false.obs;

  var clinics = <ClinicItem>[].obs;
  var currentPage = 1;
  var limit = 10;
  var hasNextPage = true.obs;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchClinics();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (hasNextPage.value && !isMoreLoading.value && !isLoading.value) {
        fetchClinics(isLoadMore: true);
      }
    }
  }

  Future<void> fetchClinics({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (isMoreLoading.value || !hasNextPage.value) return;
      isMoreLoading.value = true;
    } else {
      isLoading.value = true;
      currentPage = 1;
      hasNextPage.value = true;
      clinics.clear();
    }

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      String url = '${Urls.baseUrl}/clinic?page=$currentPage&limit=$limit';

      if (searchController.text.isNotEmpty) {
        url = '$url&searchTerm=${searchController.text.trim()}';
      }

      debugPrint('Fetching clinics from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint('Fetch Clinics Response Status: ${response.statusCode}');
      debugPrint('Fetch Clinics Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final model = ClinicListModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data?.clinics != null) {
          if (isLoadMore) {
            clinics.addAll(model.data!.clinics!);
          } else {
            clinics.assignAll(model.data!.clinics!);
          }

          final meta = model.data!.meta;
          if (meta != null) {
            final total = meta.total ?? 0;
            if (clinics.length >= total) {
              hasNextPage.value = false;
            } else {
              hasNextPage.value = true;
              currentPage++;
            }
          } else {
            hasNextPage.value = false;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching clinics: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> selectClinic(String clinicId) async {
    if (isUpdating.value) return;

    isUpdating.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/doctor/profile-update';

      final doctorData = _profileController.doctorProfile.value;
      if (doctorData == null) return;

      final Map<String, dynamic> profileData = {
        "fullName": doctorData.fullName,
        "gender": doctorData.gender?.toUpperCase(),
        "dateOfBirth": doctorData.dateOfBirth != null
            ? "${doctorData.dateOfBirth!.year}-${doctorData.dateOfBirth!.month.toString().padLeft(2, '0')}-${doctorData.dateOfBirth!.day.toString().padLeft(2, '0')}"
            : null,
        "country": doctorData.country,
        "city": doctorData.city,
        "address": doctorData.address,
        "profileCompleted": true,
        "speciality": doctorData.doctor?.speciality,
        "experience": doctorData.doctor?.experience,
        "licenseNumber": doctorData.doctor?.licenseNumber,
        "consultFee": doctorData.doctor?.consultFee,
        "clinicId": clinicId,
      };

      var request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll({'Authorization': token});
      request.fields['data'] = jsonEncode(profileData);

      debugPrint('Updating clinic selection: $clinicId');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Update Clinic Response Status: ${response.statusCode}');
      debugPrint('Update Clinic Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close bottom sheet
        Get.snackbar(
          'success'.tr,
          'clinic_updated_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        await _profileController.fetchProfile();
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          responseData['message'] ?? 'failed_to_update_clinic'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error updating clinic: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
