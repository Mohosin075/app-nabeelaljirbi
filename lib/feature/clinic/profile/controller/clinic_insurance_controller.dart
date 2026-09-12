import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/model/clinic_insurance_model.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/model/global_insurance_model.dart';

class ClinicInsuranceController extends GetxController {
  var isLoading = false.obs;
  var isAdding = false.obs;
  var isEditing = false.obs;
  var addingInsuranceId = ''.obs;
  var isLoadingAll = false.obs;
  var insurances = <ClinicInsuranceItem>[].obs;
  var allInsurances = <GlobalInsuranceItem>[].obs;
  var selectedImage = Rxn<File>();
  final insuranceDetailsController = TextEditingController();

  // Pagination
  var currentPage = 1;
  var hasMoreData = true.obs;
  final int limit = 10;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchInsurances();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading.value &&
        hasMoreData.value) {
      fetchInsurances();
    }
  }

  @override
  void onClose() {
    insuranceDetailsController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchInsurances({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMoreData.value = true;
      insurances.clear();
    }

    if (!hasMoreData.value || isLoading.value) return;

    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url =
          '${Urls.baseUrl}/clinic/insurances?page=$currentPage&limit=$limit';

      debugPrint('Fetching Clinic Insurances from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint('Fetch Insurance Response Status: ${response.statusCode}');
      log('Fetch Insurance Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final model = ClinicInsuranceModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data != null) {
          final newData = model.data!.data ?? [];
          if (newData.isNotEmpty) {
            insurances.addAll(newData);
            currentPage++;
          }

          if (newData.length < limit) {
            hasMoreData.value = false;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching insurances: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllInsurances() async {
    isLoadingAll.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/insurance?page=1&limit=1000';

      debugPrint('Fetching Global Insurances from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint(
        'Fetch Global Insurance Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final model = GlobalInsuranceModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data != null) {
          allInsurances.assignAll(model.data!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching global insurances: $e');
    } finally {
      isLoadingAll.value = false;
    }
  }

  Future<void> addInsuranceById(String insuranceId) async {
    if (addingInsuranceId.value.isNotEmpty) return;
    addingInsuranceId.value = insuranceId;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/clinic/insurances';

      debugPrint('Adding Insurance by ID: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode({'insuranceId': insuranceId}),
      );

      debugPrint('Add Insurance Response Status: ${response.statusCode}');
      debugPrint('Add Insurance Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close bottom sheet
        Get.snackbar(
          'success'.tr,
          'insurance_added_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        fetchInsurances(isRefresh: true);
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          responseData['message'] ?? 'failed_to_add_insurance'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error adding insurance by ID: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      addingInsuranceId.value = '';
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  Future<void> addInsurance() async {
    if (insuranceDetailsController.text.trim().isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_enter_insurance_details'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (selectedImage.value == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_an_image'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isAdding.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/clinic/insurances';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Authorization': token});

      // Based on consistent usage in this app
      request.fields['insuranceDetails'] = insuranceDetailsController.text
          .trim();

      final filePath = selectedImage.value!.path;
      final extension = filePath.split('.').last.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          filePath,
          contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
        ),
      );

      debugPrint('Adding Clinic Insurance: $url');
      debugPrint('Payload: ${request.fields}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Add Insurance Response Status: ${response.statusCode}');
      debugPrint('Add Insurance Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close bottom sheet
        Get.snackbar(
          'success'.tr,
          'insurance_added_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        // Clear inputs
        insuranceDetailsController.clear();
        selectedImage.value = null;
        fetchInsurances(isRefresh: true);
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          responseData['message'] ?? 'failed_to_add_insurance'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error adding insurance: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAdding.value = false;
    }
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
  }

  Future<void> deleteInsurance(String id) async {
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/insurances/$id';

      debugPrint('Deleting Clinic Insurance: $url');
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint('Delete Insurance Response Status: ${response.statusCode}');
      debugPrint('Delete Insurance Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        insurances.removeWhere((element) => element.id == id);
        Get.snackbar(
          'success'.tr,
          'insurance_deleted_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          responseData['message'] ?? 'failed_to_delete_insurance'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error deleting insurance: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
