import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';

class VerificationController extends GetxController {
  var isLoading = false.obs;
  var isSubmitting = false.obs;

  // Current verification status data
  var verificationStatus = ''.obs;
  var badgeActive = false.obs;
  var adminNote = ''.obs;
  var submittedAt = Rxn<DateTime>();
  var reviewedAt = Rxn<DateTime>();
  var documents = <Map<String, dynamic>>[].obs;
  var entityType = ''.obs;

  // Real-time document pick & upload states
  var licenseLocalFile = Rxn<File>();
  var licenseUploadedUrl = ''.obs;
  var isUploadingLicense = false.obs;

  var idLocalFile = Rxn<File>();
  var idUploadedUrl = ''.obs;
  var isUploadingId = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/verification/my-status';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      log('Verification status response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final body = data['data'] ?? data;
        verificationStatus.value = body['verificationStatus'] ?? 'NOT_SUBMITTED';
        badgeActive.value = body['badgeActive'] ?? false;
        adminNote.value = body['verificationAdminNote'] ?? '';
        entityType.value = body['entityType'] ?? '';
        submittedAt.value = body['verificationSubmittedAt'] != null
            ? DateTime.tryParse(body['verificationSubmittedAt'])
            : null;
        reviewedAt.value = body['verificationReviewedAt'] != null
            ? DateTime.tryParse(body['verificationReviewedAt'])
            : null;
        if (body['verificationDocuments'] != null) {
          documents.assignAll(
            List<Map<String, dynamic>>.from(body['verificationDocuments']),
          );
        }
      }
    } catch (e) {
      log('Error fetching verification status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitVerification({
    required List<Map<String, dynamic>> docs,
    String? notes,
  }) async {
    isSubmitting.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/verification/submit';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode({'documents': docs, 'notes': notes}),
      );

      log('Submission response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        await fetchStatus();
        return true;
      }
      return false;
    } catch (e) {
      log('Error submitting verification: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<String?> uploadDocumentFile(File file) async {
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/verification/upload';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Authorization': token});

      final ext = file.path.split('.').last.toLowerCase();
      final mimeType = (ext == 'png')
          ? MediaType('image', 'png')
          : (ext == 'pdf')
              ? MediaType('application', 'pdf')
              : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: mimeType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Upload response status: ${response.statusCode}');
      log('Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final fileData = data['data'];
        if (fileData is Map && fileData['url'] != null) {
          return fileData['url'].toString();
        }
        if (fileData is String) {
          return fileData;
        }
      }
    } catch (e) {
      log('Error uploading document file: $e');
    }
    return null;
  }

  Future<void> pickAndUploadLicense(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked != null) {
        licenseLocalFile.value = File(picked.path);
        isUploadingLicense.value = true;
        final url = await uploadDocumentFile(File(picked.path));
        isUploadingLicense.value = false;
        if (url != null && url.isNotEmpty) {
          licenseUploadedUrl.value = url;
        } else {
          Get.snackbar(
            'Upload Error',
            'Failed to upload license document. Please try again.',
            backgroundColor: const Color(0xffFEE2E2),
            colorText: const Color(0xff991B1B),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      isUploadingLicense.value = false;
      log('Error picking license: $e');
    }
  }

  Future<void> pickAndUploadIdProof(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked != null) {
        idLocalFile.value = File(picked.path);
        isUploadingId.value = true;
        final url = await uploadDocumentFile(File(picked.path));
        isUploadingId.value = false;
        if (url != null && url.isNotEmpty) {
          idUploadedUrl.value = url;
        } else {
          Get.snackbar(
            'Upload Error',
            'Failed to upload ID document. Please try again.',
            backgroundColor: const Color(0xffFEE2E2),
            colorText: const Color(0xff991B1B),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      isUploadingId.value = false;
      log('Error picking ID: $e');
    }
  }

  void removeLicense() {
    licenseLocalFile.value = null;
    licenseUploadedUrl.value = '';
  }

  void removeIdProof() {
    idLocalFile.value = null;
    idUploadedUrl.value = '';
  }

  String get statusLabel {
    switch (verificationStatus.value) {
      case 'PENDING':
        return 'under_review'.tr;
      case 'APPROVED':
        return 'approved'.tr;
      case 'REJECTED':
        return 'rejected'.tr;
      default:
        return 'not_submitted'.tr;
    }
  }
}
