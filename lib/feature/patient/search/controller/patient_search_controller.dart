import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nabeelaljirbi_app/feature/patient/filter/controller/patient_filter_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/controller/nearby_clinics_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/controller/popular_doctors_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/nearby_clinic_model.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/popular_doctor_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/specialist_model.dart';

class PatientSearchController extends GetxController {
  var searchQuery = ''.obs;
  var specialties = <SpecialistModel>[].obs;
  var filteredSpecialties = <SpecialistModel>[].obs;
  var selectedSpecialty = Rxn<SpecialistModel>();
  var selectedTab = 0.obs; // 0 for Doctors, 1 for Clinics

  // Data Controllers
  final PopularDoctorsController doctorsController = Get.put(
    PopularDoctorsController(),
  );
  final NearbyClinicsController clinicsController = Get.put(
    NearbyClinicsController(),
  );

  // Filter Controller - find existing or put new if not found (usually put by bottom sheet, but we need it here)
  late final PatientFilterController filterController;

  // Filtered Results - delegated to child controllers
  List<Doctor> get filteredDoctors => doctorsController.popularDoctors;
  List<Clinic> get filteredClinics => clinicsController.nearbyClinics;

  // We expose isFilterActive to show/hide sections if needed
  bool get isFilterActive {
    return filterController.selectedSpecialty.value != 'all' ||
        filterController.priceRange.value > 0 ||
        filterController.minRating.value > 0 ||
        filterController.selectedCity.value != 'all' ||
        filterController.selectedCountry.value != 'all';
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure Filter Controller is available
    if (Get.isRegistered<PatientFilterController>()) {
      filterController = Get.find<PatientFilterController>();
    } else {
      filterController = Get.put(PatientFilterController());
    }

    fetchSpecialists();

    // Reset filters to ensure a fresh state
    filterController.resetFilters();
    selectedSpecialty.value = null;

    // Handle incoming arguments for filters/tab
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('country')) {
        filterController.selectedCountry.value = args['country'];
      }
      if (args.containsKey('tab')) {
        selectedTab.value = args['tab'];
      }
    }

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSearch();
    });

    // Listen to changes
    // Debouncing is handled in child controllers updateSearchQuery usually,
    // but here we just pass the query.
  }

  Future<void> fetchSpecialists() async {
    try {
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
          specialties.assignAll(specialistResponse.data!);
          filteredSpecialties.assignAll(specialties);
        }
      }
    } catch (e) {
      debugPrint('Error fetching specialists: $e');
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    // Update local specialties filter
    if (query.isEmpty) {
      filteredSpecialties.assignAll(specialties);
    } else {
      filteredSpecialties.assignAll(
        specialties
            .where(
              (s) => (s.name ?? '').toLowerCase().contains(query.toLowerCase()),
            )
            .toList(),
      );
    }
    // Update child controllers
    doctorsController.updateSearchQuery(query);
    clinicsController.updateSearchQuery(query);
  }

  void selectSpecialty(SpecialistModel specialty) {
    selectedSpecialty.value = specialty;
    // Sync with filter controller
    filterController.selectedSpecialty.value = specialty.name ?? '';
    // We clear search query when selecting specialty tag?
    // Usually yes, or we keep it. Leaving as is (clearing).
    searchQuery.value = '';
    doctorsController.searchQuery.value = '';
    clinicsController.searchQuery.value = '';

    _triggerSearch();
  }

  void deselectSpecialty() {
    selectedSpecialty.value = null;
    filterController.selectedSpecialty.value = 'all';
    _triggerSearch();
  }

  void selectTab(int index) {
    selectedTab.value = index;
    // Do we need to trigger search?
    // If the lists are already updated, no.
    // But maybe we want to refresh data?
    // Let's just trigger to be safe or just let the UI switch.
    // UI switches based on selectedTab.
  }

  void performSearch() {
    _triggerSearch();
  }

  void _triggerSearch() {
    doctorsController.fetchPopularDoctors();
    clinicsController.fetchNearbyClinics();
  }

  void resetAndFetch() {
    searchQuery.value = '';
    filterController.resetFilters();
    selectedSpecialty.value = null;

    // Reset child controllers to their default state (empty search, empty filters)
    doctorsController.resetAndFetch();
    clinicsController.resetAndFetch();
  }
}
