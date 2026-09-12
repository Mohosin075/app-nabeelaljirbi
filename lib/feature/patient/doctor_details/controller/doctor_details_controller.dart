import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/model/doctor_details_model.dart';

class DoctorDetailsController extends GetxController {
  var isLoading = true.obs;
  var doctorDetails = Rxn<DoctorDetailData>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Assuming the doctor ID is passed as an argument
    if (Get.arguments != null && Get.arguments is String) {
      getDoctorDetails(Get.arguments);
    } else {
      // Fallback or error handling if no ID is passed
      // For now, let's just log or set an error
      errorMessage.value = "Doctor ID not provided";
      isLoading.value = false;
    }
  }

  Future<void> getDoctorDetails(String doctorId) async {
    try {
      isLoading(true);
      final token = SharedPrefHelper.getAccessToken();
      final url = '${Urls.baseUrl}/patient/get-doctor/$doctorId';

      debugPrint('Fetching Doctor Details: $url');

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
        final model = DoctorDetailsModel.fromJson(jsonData);
        if (model.success == true && model.data != null) {
          doctorDetails.value = model.data;
        } else {
          errorMessage.value = model.message ?? "Failed to load doctor details";
        }
      } else {
        errorMessage.value = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage.value = "An error occurred: $e";
      debugPrint('Error fetching doctor details: $e');
    } finally {
      isLoading(false);
    }
  }
}
