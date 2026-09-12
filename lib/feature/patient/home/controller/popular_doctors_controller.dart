import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/patient/filter/controller/patient_filter_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/popular_doctor_model.dart';

class PopularDoctorsController extends GetxController {
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var popularDoctors = <Doctor>[].obs;
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var searchQuery = ''.obs;
  final int limit = 10;
  Timer? _debounce;
  final PatientFilterController filterController = Get.put(
    PatientFilterController(),
  );

  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchPopularDoctors();
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
      fetchPopularDoctors();
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (hasMore.value && !isMoreLoading.value) {
        loadMoreDoctors();
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

    // Insurance
    /*
    if (filterController.selectedInsurance.value != 'all') {
      params += '&insurance=${filterController.selectedInsurance.value}';
    }
    */

    // Date
    /*
    if (filterController.selectedDate.value != null) {
      params +=
          '&date=${filterController.selectedDate.value!.toIso8601String().split('T')[0]}';
    }
    */

    return params;
  }

  List<Doctor> _applyLocalFilters(List<Doctor> doctors) {
    var filtered = List<Doctor>.from(doctors);

    // Specialty
    if (filterController.selectedSpecialty.value != 'all') {
      final specName = filterController.selectedSpecialty.value.toLowerCase();
      filtered = filtered
          .where(
            (d) => (d.specialty?.toLowerCase().contains(specName) ?? false),
          )
          .toList();
    }

    // City
    if (filterController.selectedCity.value != 'all') {
      final city = filterController.selectedCity.value.toLowerCase();
      filtered = filtered
          .where((d) => (d.city?.toLowerCase().contains(city) ?? false))
          .toList();
    }

    // Country
    if (filterController.selectedCountry.value != 'all') {
      final country = filterController.selectedCountry.value.toLowerCase();
      filtered = filtered
          .where((d) => (d.country?.toLowerCase().contains(country) ?? false))
          .toList();
    }

    // Rating
    if (filterController.minRating.value > 0) {
      filtered = filtered
          .where((d) => (d.rating ?? 0) >= filterController.minRating.value)
          .toList();
    }

    // Fee (Price Range in Filter is usually Max Price?)
    if (filterController.priceRange.value > 0) {
      filtered = filtered
          .where((d) => (d.fee ?? 0) <= filterController.priceRange.value)
          .toList();
    }

    return filtered;
  }

  Future<void> fetchPopularDoctors() async {
    if (isLoading.value) return;
    isLoading.value = true;
    currentPage.value = 1;
    popularDoctors.clear();
    hasMore.value = true;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      String url =
          '${Urls.baseUrl}/patient/doctors/popular?page=${currentPage.value}&limit=$limit';

      if (searchQuery.value.isNotEmpty) {
        url += '&search=${searchQuery.value}';
      }

      url += _buildFilterParams();

      debugPrint('Fetching Popular Doctors URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('Popular Doctors Response Status: ${response.statusCode}');
      log('Popular Doctors Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final popularDoctorModel = PopularDoctorModel.fromJson(jsonData);

        if (popularDoctorModel.success == true &&
            popularDoctorModel.data?.doctors != null) {
          var fetchedDoctors = popularDoctorModel.data!.doctors!;

          // Apply Local Filters
          var filteredDocs = _applyLocalFilters(fetchedDoctors);
          popularDoctors.assignAll(filteredDocs);

          if (fetchedDoctors.length < limit) {
            hasMore.value = false;
          } else if (filteredDocs.isEmpty && hasMore.value) {
            // If we got data but filtered everything out, try to load more automatically
            // to avoid empty screen
            loadMoreDoctors();
          }
        }
      } else {
        // Get.snackbar('Error', 'Failed to fetch popular doctors'); // Optional
      }
    } catch (e) {
      debugPrint('Error fetching popular doctors: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreDoctors() async {
    if (isMoreLoading.value || !hasMore.value) return;

    isMoreLoading.value = true;
    currentPage.value++;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      String url =
          '${Urls.baseUrl}/patient/doctors/popular?page=${currentPage.value}&limit=$limit';

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
        final popularDoctorModel = PopularDoctorModel.fromJson(jsonData);

        if (popularDoctorModel.success == true &&
            popularDoctorModel.data?.doctors != null) {
          final newDoctors = popularDoctorModel.data!.doctors!;

          // Apply Local Filters
          var filteredNewDoctors = _applyLocalFilters(newDoctors);

          if (filteredNewDoctors.isNotEmpty) {
            popularDoctors.addAll(filteredNewDoctors);
          }

          if (newDoctors.length < limit) {
            hasMore.value = false;
          } else if (filteredNewDoctors.isEmpty && hasMore.value) {
            // Recursive load if filtered out
            // Be careful of stack overflow, but async/await breaks stack usually.
            // Just call it again.
            // We must ensure isMoreLoading is false before calling?
            // The method checks isMoreLoading. So correct logic: set to false then call?
            // Or better: wrapping in future logic?
            // Simple recursion here works because we await.
            isMoreLoading.value = false; // Reset to allow re-entry
            loadMoreDoctors();
            return; // Return early after recursive call
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading more popular doctors: $e');
      currentPage.value--; // Revert page on failure
    } finally {
      if (isMoreLoading.value) isMoreLoading.value = false;
    }
  }

  void resetAndFetch() {
    searchQuery.value = '';
    filterController.resetFilters();
    fetchPopularDoctors();
  }
}
