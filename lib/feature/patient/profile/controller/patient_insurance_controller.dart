import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';

class PatientInsuranceController extends GetxController {
  var isLoading = false.obs;
  var isAdding = false.obs;
  var insurances = <PatientInsuranceItem>[].obs;
  var selectedImage = Rxn<File>();
  final insuranceDetailsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchInsurances();
  }

  @override
  void onClose() {
    insuranceDetailsController.dispose();
    super.onClose();
  }

  Future<void> fetchInsurances() async {
    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/patient/insurance';

      debugPrint('Fetching Patient Insurances from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint('Fetch Insurance Response Status: ${response.statusCode}');
      debugPrint('Fetch Insurance Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          insurances.assignAll(
            list.map((e) => PatientInsuranceItem.fromJson(e)).toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching insurances: $e');
    } finally {
      isLoading.value = false;
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
      final String url = '${Urls.baseUrl}/patient/insurance';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Authorization': token});

      final Map<String, dynamic> data = {
        "insuranceDetails": insuranceDetailsController.text.trim(),
      };

      request.fields['data'] = jsonEncode(data);

      final filePath = selectedImage.value!.path;
      final extension = filePath.split('.').last.toLowerCase();
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          filePath,
          contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
        ),
      );

      debugPrint('Adding Insurance: $url');
      debugPrint('Payload: ${request.fields['data']}');

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
        fetchInsurances();
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
}

class PatientInsuranceItem {
  String? id;
  String? insuranceDetails;
  String? image;

  PatientInsuranceItem({this.id, this.insuranceDetails, this.image});

  PatientInsuranceItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    insuranceDetails = json['insuranceDetails'];
    image = json['image'];
  }
}
