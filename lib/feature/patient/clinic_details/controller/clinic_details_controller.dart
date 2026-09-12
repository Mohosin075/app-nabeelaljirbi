import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/patient/clinic_details/model/clinic_details_model.dart';
import 'package:nabeelaljirbi_app/feature/patient/filter/controller/patient_filter_controller.dart';

class ClinicDetailsController extends GetxController {
  var selectedTabIndex = 0.obs;

  var isLoading = false.obs;
  var clinicDetails = Rxn<ClinicData>();
  final TextEditingController searchController = TextEditingController();
  var currentClinicId = "".obs;
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      currentClinicId.value = Get.arguments.toString();
      fetchClinicDetails(currentClinicId.value);
      fetchClinicDoctors(currentClinicId.value);
    }
  }

  Future<void> fetchClinicDetails(String clinicId) async {
    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/patient/clinics/$clinicId';

      debugPrint('Fetching Clinic Details: $url');
      debugPrint('Token: $token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = ClinicDetailsModel.fromJson(jsonData);
        if (model.success == true && model.data != null) {
          clinicDetails.value = model.data;
          errorMessage.value = "";
          debugPrint('Clinic Data Loaded: ${model.data?.clinicName}');
        } else {
          errorMessage.value = model.message ?? "api_error".tr;
          debugPrint('API Error: ${model.message}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
        // Handle http error
      }
    } catch (e, stackTrace) {
      debugPrint('Exception fetching clinic details: $e');
      debugPrint('Stacktrace: $stackTrace');
      // Handle exception
    } finally {
      isLoading.value = false;
    }
  }

  var clinicDoctors = <ClinicDoctor>[].obs;
  var isDoctorsLoading = false.obs;

  Future<void> fetchClinicDoctors(
    String clinicId, {
    String? search,
    String? country,
    String? city,
    String? specialty,
    double? consultFee,
    int? minRating,
  }) async {
    isDoctorsLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      String url = '${Urls.baseUrl}/patient/get-clinic-doctors/$clinicId';

      // Add query parameters for filtering
      Map<String, String> queryParams = {};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (specialty != null && specialty != 'all') {
        queryParams['specialty'] = specialty;
      }
      if (country != null && country != 'all') {
        queryParams['country'] = country;
      }
      if (city != null && city != 'all') {
        queryParams['city'] = city;
      }

      if (consultFee != null && consultFee > 0) {
        queryParams['consultFee'] = consultFee.toString();
      }

      if (minRating != null && minRating > 0) {
        queryParams['minRating'] = minRating.toString();
      }

      /* 
      // Availability and Insurance logic commented out as per requirement
      if (insurance != null && insurance != 'all') {
        queryParams['insurance'] = insurance;
      }
      if (availability != null) {
        queryParams['availability'] = availability;
      }
      */

      if (queryParams.isNotEmpty) {
        url += '?${Uri(queryParameters: queryParams).query}';
      }

      debugPrint('Fetching Clinic Doctors: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = ClinicDoctorsModel.fromJson(jsonData);
        if (model.success == true &&
            model.data != null &&
            model.data!.data != null) {
          clinicDoctors.assignAll(model.data!.data!);
        }
      } else {
        debugPrint('HTTP Error fetching doctors: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception fetching clinic doctors: $e');
    } finally {
      isDoctorsLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void performSearch() {
    final filterController = Get.find<PatientFilterController>();
    fetchClinicDoctors(
      currentClinicId.value,
      search: searchController.text.trim(),
      country: filterController.selectedCountry.value,
      city: filterController.selectedCity.value,
      specialty: filterController.selectedSpecialty.value,
      consultFee: filterController.priceRange.value > 0
          ? filterController.priceRange.value
          : null,
      minRating: filterController.minRating.value,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
