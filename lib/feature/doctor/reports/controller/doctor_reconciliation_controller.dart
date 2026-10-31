import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/reports/model/doctor_reconciliation_model.dart';

class DoctorReconciliationController extends GetxController {
  var isInitialLoading = true.obs;
  var isFiltering = false.obs;
  var isMoreLoading = false.obs;

  var selectedClinicId = 'all'.obs;
  var selectedPeriod =
      'monthly'.obs; // 'daily', 'weekly', 'monthly', 'last_month', 'custom'
  var selectedDate = Rx<DateTime?>(null);
  var customStartDate = Rx<DateTime?>(null);
  var customEndDate = Rx<DateTime?>(null);
  var selectedShift = 'all'.obs; // 'all', 'morning', 'evening'
  var selectedStatus =
      'ALL'.obs; // 'ALL', 'COMPLETE', 'CONFIRMED', 'CANCELLED', 'NOT_SHOW'
  var searchQuery = ''.obs;

  var reconciliationData = Rx<DoctorReconciliationData?>(null);
  var appointments = <ReconciliationAppointment>[].obs;
  var availableClinics = <AvailableClinic>[].obs;

  var currentPage = 1.obs;
  var hasMore = true.obs;
  final int limit = 15;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchReports(isFilterChange: false);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (hasMore.value &&
          !isMoreLoading.value &&
          !isFiltering.value &&
          !isInitialLoading.value) {
        loadMoreReports();
      }
    }
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedClinicId.value != 'all') count++;
    if (selectedPeriod.value != 'monthly') count++;
    if (selectedStatus.value != 'ALL') count++;
    if (selectedShift.value != 'all') count++;
    if (searchQuery.value.trim().isNotEmpty) count++;
    if (selectedDate.value != null || customStartDate.value != null) count++;
    return count;
  }

  int get secondaryFilterCount {
    int count = 0;
    if (selectedClinicId.value != 'all') count++;
    if (selectedShift.value != 'all') count++;
    if (selectedStatus.value != 'ALL') count++;
    return count;
  }

  String getClinicName(String clinicId) {
    if (clinicId == 'all') return 'all_clinics'.tr;
    for (final c in availableClinics) {
      if (c.id == clinicId) return c.clinicName ?? clinicId;
    }
    return clinicId;
  }

  void setClinic(String clinicId) {
    if (selectedClinicId.value == clinicId) return;
    selectedClinicId.value = clinicId;
    fetchReports(isFilterChange: true);
  }

  void setPeriod(String period) {
    if (selectedPeriod.value == period && period != 'custom') return;
    selectedPeriod.value = period;
    if (period != 'custom') {
      customStartDate.value = null;
      customEndDate.value = null;
      selectedDate.value = null;
    }
    fetchReports(isFilterChange: true);
  }

  void setSingleDate(DateTime? date) {
    selectedDate.value = date;
    if (date != null) {
      selectedPeriod.value = 'daily';
    }
    fetchReports(isFilterChange: true);
  }

  void setCustomRange(DateTime start, DateTime end) {
    customStartDate.value = start;
    customEndDate.value = end;
    selectedPeriod.value = 'custom';
    selectedDate.value = null;
    fetchReports(isFilterChange: true);
  }

  void setShift(String shift) {
    if (selectedShift.value == shift) return;
    selectedShift.value = shift;
    fetchReports(isFilterChange: true);
  }

  void setStatus(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchReports(isFilterChange: true);
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (searchQuery.value != query) {
        searchQuery.value = query;
        fetchReports(isFilterChange: true);
      }
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchReports(isFilterChange: true);
  }

  void resetFilters() {
    selectedClinicId.value = 'all';
    selectedPeriod.value = 'monthly';
    selectedDate.value = null;
    customStartDate.value = null;
    customEndDate.value = null;
    selectedShift.value = 'all';
    selectedStatus.value = 'ALL';
    searchQuery.value = '';
    searchController.clear();
    fetchReports(isFilterChange: true);
  }

  void resetSecondaryFilters() {
    selectedClinicId.value = 'all';
    selectedShift.value = 'all';
    selectedStatus.value = 'ALL';
    fetchReports(isFilterChange: true);
  }

  Future<void> fetchReports({bool isFilterChange = false}) async {
    if (isFilterChange) {
      isFiltering.value = true;
    } else {
      isInitialLoading.value = true;
    }

    currentPage.value = 1;
    hasMore.value = true;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = _buildUrl(page: 1);

      debugPrint('Fetching Doctor Reconciliation Reports: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('Reconciliation Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final reportResponse = DoctorReconciliationResponse.fromJson(decoded);

        if (reportResponse.success == true && reportResponse.data != null) {
          reconciliationData.value = reportResponse.data;
          availableClinics.assignAll(
            reportResponse.data!.availableClinics ?? [],
          );

          final list = reportResponse.data!.appointments ?? [];
          appointments.assignAll(list);

          final total = reportResponse.data!.meta?.total ?? 0;
          if (appointments.length >= total || list.length < limit) {
            hasMore.value = false;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching reconciliation reports: $e');
    } finally {
      isInitialLoading.value = false;
      isFiltering.value = false;
    }
  }

  Future<void> loadMoreReports() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;
    currentPage.value += 1;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = _buildUrl(page: currentPage.value);

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final reportResponse = DoctorReconciliationResponse.fromJson(decoded);

        if (reportResponse.success == true && reportResponse.data != null) {
          final list = reportResponse.data!.appointments ?? [];
          if (list.isEmpty) {
            hasMore.value = false;
          } else {
            appointments.addAll(list);
            final total = reportResponse.data!.meta?.total ?? 0;
            if (appointments.length >= total || list.length < limit) {
              hasMore.value = false;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading more reconciliation reports: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  String _buildUrl({required int page}) {
    String url =
        '${Urls.baseUrl}/doctor/reconciliation-reports?page=$page&limit=$limit';

    if (selectedClinicId.value != 'all' && selectedClinicId.value.isNotEmpty) {
      url += '&clinicId=${selectedClinicId.value}';
    }

    if (selectedDate.value != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
      url += '&date=$dateStr';
    } else if (selectedPeriod.value == 'custom' &&
        customStartDate.value != null &&
        customEndDate.value != null) {
      final startStr = DateFormat('yyyy-MM-dd').format(customStartDate.value!);
      final endStr = DateFormat('yyyy-MM-dd').format(customEndDate.value!);
      url += '&startDate=$startStr&endDate=$endStr';
    } else {
      url += '&period=${selectedPeriod.value}';
    }

    if (selectedShift.value != 'all') {
      url += '&shift=${selectedShift.value}';
    }

    if (selectedStatus.value != 'ALL') {
      url += '&status=${selectedStatus.value}';
    }

    if (searchQuery.value.trim().isNotEmpty) {
      url += '&searchTerm=${Uri.encodeComponent(searchQuery.value.trim())}';
    }

    return url;
  }

  Map<String, dynamic> get exportFilters =>
      Uri.parse(_buildUrl(page: 1)).queryParameters;
  final isExporting = false.obs;
}
