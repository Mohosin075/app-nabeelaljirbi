import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';

class DoctorBiographyController extends GetxController {
  final DoctorProfileController _profileController =
      Get.find<DoctorProfileController>();

  final Rxn<File> selectedFile = Rxn<File>();
  var isLoading = false.obs;

  String? get currentBiographyUrl =>
      _profileController.doctorProfile.value?.doctor?.biography;

  String get selectedFileName {
    final file = selectedFile.value;
    if (file == null) return 'No file selected';
    return file.path.split('/').last;
  }

  Future<void> pickFile() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedFile.value = File(picked.path);
    }
  }

  Future<void> uploadBiography() async {
    if (selectedFile.value == null) {
      Get.snackbar(
        'Error',
        'Please select a CV / Biography file first.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/doctor/profile-update';
      final doctorData = _profileController.doctorProfile.value;
      if (doctorData == null) {
        throw Exception('Doctor profile not loaded');
      }

      final profileData = {
        'fullName': doctorData.fullName,
        'gender': doctorData.gender?.toUpperCase(),
        'dateOfBirth': doctorData.dateOfBirth != null
            ? '${doctorData.dateOfBirth!.year}-${doctorData.dateOfBirth!.month.toString().padLeft(2, '0')}-${doctorData.dateOfBirth!.day.toString().padLeft(2, '0')}'
            : null,
        'country': doctorData.country,
        'city': doctorData.city,
        'address': doctorData.address,
        'profileCompleted': true,
        'speciality': doctorData.doctor?.speciality,
        'experience': doctorData.doctor?.experience,
        'licenseNumber': doctorData.doctor?.licenseNumber,
        'consultFee': doctorData.doctor?.consultFee,
        'clinicId': doctorData.doctor?.clinicId,
      };

      final request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll({'Authorization': token});
      request.fields['data'] = jsonEncode(profileData);

      final file = selectedFile.value!;
      final extension = file.path.split('.').last.toLowerCase();
      String mimeType = 'application/octet-stream';
      switch (extension) {
        case 'png':
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/$extension';
          break;
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        case 'doc':
          mimeType = 'application/msword';
          break;
        case 'docx':
          mimeType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
      }

      final mimeParts = mimeType.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'biography',
          file.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'CV / Biography uploaded successfully.',
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        await _profileController.fetchProfile();
        Get.back();
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'Error',
          responseData['message'] ?? 'Failed to upload CV / Biography.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong while uploading the file.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
