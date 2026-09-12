import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/specialist_model.dart';
import 'package:nabeelaljirbi_app/core/const/cities_data.dart';

class PatientFilterController extends GetxController {
  var selectedSpecialty = 'all'.obs;
  var priceRange = 0.0.obs;
  var minRating = 0.obs;
  var selectedCity = 'all'.obs;
  var selectedCountry = 'all'.obs;
  // var selectedDate = Rxn<DateTime>();

  // Note: selectedInsurance is kept for model compatibility but search logic is focused on other params
  var selectedInsurance = 'all'.obs;

  var specialtiesList = <SpecialistModel>[].obs;
  var isLoadingSpecialties = false.obs;

  List<String> get specialties => [
    'all',
    ...specialtiesList.map((e) => e.name ?? ''),
  ];

  final List<String> insurances = [
    'all',
    'LIBYA INSURANCE co.',
    'Al Madar',
    'Takaful',
  ];

  List<String> get countries => ['all', ...citiesData.keys];

  List<String> get cities {
    if (selectedCountry.value == 'all') {
      return ['all'];
    }
    return ['all', ...(citiesData[selectedCountry.value] ?? [])];
  }

  @override
  void onInit() {
    super.onInit();
    fetchSpecialists();
  }

  Future<void> fetchSpecialists() async {
    try {
      isLoadingSpecialties.value = true;
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/specialist?page=1&limit=50';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final specialistResponse = SpecialistResponse.fromJson(data);
        if (specialistResponse.data != null) {
          specialtiesList.assignAll(specialistResponse.data!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching specialists: $e');
    } finally {
      isLoadingSpecialties.value = false;
    }
  }

  void resetFilters() {
    selectedSpecialty.value = 'all';
    priceRange.value = 0.0;
    selectedInsurance.value = 'all';
    minRating.value = 0;
    selectedCity.value = 'all';
    selectedCountry.value = 'all';
    // selectedDate.value = null;
  }

  void updateSpecialty(String value) => selectedSpecialty.value = value;
  void updatePriceRange(double value) => priceRange.value = value;
  void updateInsurance(String value) => selectedInsurance.value = value;
  void updateMinRating(int value) => minRating.value = value;
  void updateCountry(String value) {
    selectedCountry.value = value;
    selectedCity.value = 'all';
  }

  void updateCity(String value) => selectedCity.value = value;
  // void updateDate(DateTime? date) => selectedDate.value = date;
}
