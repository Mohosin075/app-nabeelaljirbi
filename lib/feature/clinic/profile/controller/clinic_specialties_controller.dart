import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/model/clinic_specialist_model.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/specialist_model.dart';

class ClinicSpecialtiesController extends GetxController {
  // Specialists Pagination (API Data)
  var specialistsList = <ClinicSpecialistItem>[].obs;
  var isSpecialistsLoading = false.obs;
  var currentPage = 1;
  var totalPages = 1;
  final int limit = 10;
  var hasMoreSpecialists = true.obs;

  // Add Specialist Logic
  var allSpecialistList = <SpecialistModel>[].obs;
  var isAllSpecialistsLoading = false.obs;
  var isAddingSpecialist = false.obs;

  var isEditingSpecialties = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSpecialists();
  }

  Future<void> fetchSpecialists({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMoreSpecialists.value = true;
      specialistsList.clear();
    }

    if (!hasMoreSpecialists.value || isSpecialistsLoading.value) return;

    isSpecialistsLoading.value = true;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url =
          '${Urls.baseUrl}/clinic/specialists?page=$currentPage&limit=$limit';
      debugPrint('Fetch Specialists Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('Fetch Specialists Status Code: ${response.statusCode}');
      debugPrint('Fetch Specialists Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final specialistResponse = ClinicSpecialistResponse.fromJson(data);

        if (specialistResponse.success == true &&
            specialistResponse.data != null) {
          final newData = specialistResponse.data!.data ?? [];
          final meta = specialistResponse.data!.meta;

          if (newData.isNotEmpty) {
            specialistsList.addAll(newData);
            currentPage++;
          }

          if (meta != null) {
            if (newData.isEmpty ||
                specialistsList.length >= (meta.total ?? 0)) {
              hasMoreSpecialists.value = false;
            }
          } else {
            if (newData.length < limit) {
              hasMoreSpecialists.value = false;
            }
          }
        } else {
          Get.snackbar(
            'error'.tr,
            specialistResponse.message ?? 'failed_to_fetch_specialists'.tr,
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          errorData['message'] ?? 'failed_to_fetch_specialists'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error fetching specialists: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isSpecialistsLoading.value = false;
    }
  }

  Future<void> getAllSpecialists() async {
    isAllSpecialistsLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/specialist?page=1&limit=50';

      debugPrint('FETCHING ALL SPECIALISTS: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('ALL SPECIALISTS RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final specialistResponse = SpecialistResponse.fromJson(data);
        if (specialistResponse.data != null) {
          allSpecialistList.assignAll(specialistResponse.data!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching all specialists: $e');
    } finally {
      isAllSpecialistsLoading.value = false;
    }
  }

  Future<void> addSpecialist(String specialistId) async {
    if (isAddingSpecialist.value) return;

    isAddingSpecialist.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/specialists';

      debugPrint('Add Specialist Request URL: $url');
      debugPrint('Add Specialist Body: {"specialistId": "$specialistId"}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode({'specialistId': specialistId}),
      );

      debugPrint('Add Specialist Response Status Code: ${response.statusCode}');
      debugPrint('Add Specialist Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        //Get.back(); // Close bottom sheet
        Get.snackbar(
          'success'.tr,
          'specialist_added_success'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        fetchSpecialists(isRefresh: true); // Refresh clinic's specialists list
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          data['message'] ?? 'failed_to_add_specialist'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error adding specialist: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isAddingSpecialist.value = false;
    }
  }

  void toggleEditSpecialties() {
    isEditingSpecialties.value = !isEditingSpecialties.value;
  }

  Future<void> deleteSpecialist(String id) async {
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/specialists/$id';

      debugPrint('Delete Specialist Request URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint('Delete Specialist Status Code: ${response.statusCode}');
      debugPrint('Delete Specialist Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        specialistsList.removeWhere((element) => element.id == id);
        Get.snackbar(
          'success'.tr,
          'specialist_deleted_success'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('error'.tr, 'failed_to_delete_specialist'.tr);
      }
    } catch (e) {
      debugPrint('Error deleting specialist: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    }
  }
}
