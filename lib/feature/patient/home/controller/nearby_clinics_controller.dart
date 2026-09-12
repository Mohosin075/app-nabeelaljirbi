import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'dart:async';
import 'package:nabeelaljirbi_app/feature/patient/filter/controller/patient_filter_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/nearby_clinic_model.dart';

class NearbyClinicsController extends GetxController {
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var nearbyClinics = <Clinic>[].obs;
  var currentPage = 1.obs;
  var hasMore = true.obs;
  final int limit = 10;

  Timer? _debounce;
  final PatientFilterController filterController = Get.put(
    PatientFilterController(),
  );
  var searchQuery = ''.obs;

  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchNearbyClinics();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void updateSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = query;
      fetchNearbyClinics();
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (hasMore.value && !isMoreLoading.value) {
        loadMoreClinics();
      }
    }
  }

  String _buildFilterParams() {
    String params = '';

    // Specialty
    if (filterController.selectedSpecialty.value != 'all') {
      final selectedSpec = filterController.specialtiesList.firstWhereOrNull(
        (s) => s.name == filterController.selectedSpecialty.value,
      );
      if (selectedSpec != null && selectedSpec.id != null) {
        params += '&specialistId=${selectedSpec.id}';
        params += '&specialty=${filterController.selectedSpecialty.value}';
      } else {
        params += '&specialty=${filterController.selectedSpecialty.value}';
      }
    }

    // Price
    if (filterController.priceRange.value > 0) {
      params += '&consultFee=${filterController.priceRange.value.toInt()}';
    }

    // Rating
    if (filterController.minRating.value > 0) {
      params += '&rating=${filterController.minRating.value}';
    }

    // City
    if (filterController.selectedCity.value != 'all') {
      params += '&city=${filterController.selectedCity.value}';
    }

    // Country
    if (filterController.selectedCountry.value != 'all') {
      params += '&country=${filterController.selectedCountry.value}';
    }

    return params;
  }

  List<Clinic> _applyLocalFilters(List<Clinic> clinics) {
    var filtered = List<Clinic>.from(clinics);

    // Specialty
    if (filterController.selectedSpecialty.value != 'all') {
      final specName = filterController.selectedSpecialty.value.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                (c.specialties != null &&
                c.specialties!.any((s) => s.toLowerCase().contains(specName))),
          )
          .toList();
    }

    // City
    if (filterController.selectedCity.value != 'all') {
      final city = filterController.selectedCity.value.toLowerCase();
      filtered = filtered
          .where((c) => (c.city?.toLowerCase().contains(city) ?? false))
          .toList();
    }

    // Country
    if (filterController.selectedCountry.value != 'all') {
      final country = filterController.selectedCountry.value.toLowerCase();
      filtered = filtered
          .where((c) => (c.country?.toLowerCase().contains(country) ?? false))
          .toList();
    }

    return filtered;
  }

  Future<void> fetchNearbyClinics() async {
    if (isLoading.value) return;
    isLoading.value = true;
    currentPage.value = 1;
    nearbyClinics.clear();
    hasMore.value = true;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      String url =
          '${Urls.baseUrl}/patient/clinics/nearest?page=${currentPage.value}&limit=$limit';

      if (searchQuery.value.isNotEmpty) {
        url += '&search=${searchQuery.value}';
      }

      url += _buildFilterParams();

      debugPrint('Fetching Nearby Clinics URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('Nearby Clinics Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final nearbyClinicModel = NearbyClinicModel.fromJson(jsonData);

        if (nearbyClinicModel.success == true &&
            nearbyClinicModel.data?.clinics != null) {
          var fetchedClinics = nearbyClinicModel.data!.clinics!;

          // Apply Local Filters
          var filteredClinics = _applyLocalFilters(fetchedClinics);
          nearbyClinics.assignAll(filteredClinics);

          if (fetchedClinics.length < limit) {
            hasMore.value = false;
          } else if (filteredClinics.isEmpty && hasMore.value) {
            // Recursive fetching to avoid empty screen
            loadMoreClinics();
          }
        }
      } else {
        // Get.snackbar('Error', 'Failed to fetch nearby clinics');
      }
    } catch (e) {
      debugPrint('Error fetching nearby clinics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreClinics() async {
    if (isMoreLoading.value || !hasMore.value) return;

    isMoreLoading.value = true;
    currentPage.value++;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      String url =
          '${Urls.baseUrl}/patient/clinics/nearest?page=${currentPage.value}&limit=$limit';

      if (searchQuery.value.isNotEmpty) {
        url += '&search=${searchQuery.value}';
      }

      url += _buildFilterParams();

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final nearbyClinicModel = NearbyClinicModel.fromJson(jsonData);

        if (nearbyClinicModel.success == true &&
            nearbyClinicModel.data?.clinics != null) {
          final newClinics = nearbyClinicModel.data!.clinics!;

          // Apply Local Filters
          var filteredNewClinics = _applyLocalFilters(newClinics);

          if (filteredNewClinics.isNotEmpty) {
            nearbyClinics.addAll(filteredNewClinics);
          }

          if (newClinics.length < limit) {
            hasMore.value = false;
          } else if (filteredNewClinics.isEmpty && hasMore.value) {
            isMoreLoading.value = false;
            loadMoreClinics();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading more nearby clinics: $e');
      currentPage.value--; // Revert page on failure
    } finally {
      if (isMoreLoading.value) isMoreLoading.value = false;
    }
  }

  void resetAndFetch() {
    searchQuery.value = '';
    filterController.resetFilters();
    fetchNearbyClinics();
  }
}
