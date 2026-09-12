import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/specialist_model.dart';
import '../model/clinic_doctor_model.dart';

class ClinicDoctorController extends GetxController {
  var isLoading = false.obs;
  var isPaginationLoading = false.obs;
  var doctors = <ClinicDoctorItem>[].obs;
  var filteredDoctors = <ClinicDoctorItem>[].obs;
  var searchQuery = ''.obs;

  // Filter States
  var selectedSpecialty = 'all'.obs;
  var selectedRating = 0.obs;
  var maxFee = 1000.0.obs;
  var selectedExperience = 'all'.obs;
  void updateSpecialty(String value) => selectedSpecialty.value = value;

  final List<String> specialties = [
    'all',
    'neurologist',
    'cardiologist',
    'dentist',
    'orthopedic',
  ]; // Mocking for now
  final List<String> experiences = [
    'all',
    '1_3_years',
    '3_5_years',
    '5_10_years',
    '10_plus_years',
  ];

  // Pagination
  var currentPage = 1;
  var hasMoreData = true.obs;
  final int limit = 10;
  final ScrollController scrollController = ScrollController();

  // Concurrency & Debounce
  Timer? _searchDebounce;
  int _requestCounter = 0;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
    scrollController.addListener(_scrollListener);
    getSpecialists();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading.value &&
        !isPaginationLoading.value &&
        hasMoreData.value) {
      fetchDoctors(isPagination: true);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  var specialistList = <SpecialistModel>[].obs;

  List<String> get specialtyNames =>
      specialistList.map((e) => e.name ?? '').toList();
  List<String> get specialtyImages =>
      specialistList.map((e) => e.image ?? '').toList();

  Future<void> getSpecialists() async {
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url =
          '${Urls.baseUrl}/specialist?page=1&limit=50'; // Increased limit to get more

      debugPrint('FETCHING SPECIALISTS: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('SPECIALISTS RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final specialistResponse = SpecialistResponse.fromJson(data);
        if (specialistResponse.data != null) {
          specialistList.assignAll(specialistResponse.data!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching specialists: $e');
    }
  }

  Future<void> fetchDoctors({
    bool isRefresh = false,
    bool isPagination = false,
  }) async {
    final int currentRequest = ++_requestCounter;

    if (isRefresh) {
      currentPage = 1;
      hasMoreData.value = true;
      doctors.clear();
      filteredDoctors.clear();
    }

    if (!hasMoreData.value && !isRefresh) return;

    if (isPagination) {
      isPaginationLoading.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';

      // Building query parameters
      String url =
          '${Urls.baseUrl}/clinic/doctors?page=$currentPage&limit=$limit';
      if (searchQuery.value.isNotEmpty) {
        url += '&search=${searchQuery.value}';
      }
      if (selectedSpecialty.value != 'all') {
        url += '&specialty=${selectedSpecialty.value}';
      }
      if (selectedRating.value > 0) {
        url += '&rating=${selectedRating.value}';
      }
      if (maxFee.value < 1000) {
        url += '&consultFee=${maxFee.value}';
      }

      debugPrint('Fetching Clinic Doctors [Req: $currentRequest] from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      // Ignore if a newer request has started
      if (currentRequest != _requestCounter) {
        debugPrint('Ignoring stale response for [Req: $currentRequest]');
        return;
      }

      debugPrint(
        'Fetch Clinic Doctors Response Status: ${response.statusCode} [Req: $currentRequest]',
      );

      if (response.statusCode == 200) {
        final model = ClinicDoctorModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data != null) {
          final newData = model.data!.data ?? [];
          if (newData.isNotEmpty) {
            doctors.addAll(newData);
            currentPage++;
          }

          if (newData.length < limit) {
            hasMoreData.value = false;
          }

          _updateFilteredList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching clinic doctors: $e');
    } finally {
      if (currentRequest == _requestCounter) {
        isLoading.value = false;
        isPaginationLoading.value = false;
      }
    }
  }

  void search(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchDoctors(isRefresh: true);
    });
  }

  void resetFilters() {
    selectedSpecialty.value = 'all';
    selectedRating.value = 0;
    maxFee.value = 1000.0;
    selectedExperience.value = 'all';
    fetchDoctors(isRefresh: true);
  }

  void applyFilters() {
    fetchDoctors(isRefresh: true);
  }

  void _updateFilteredList() {
    filteredDoctors.assignAll(doctors);
  }

  int get totalDoctors => doctors.length;
}
