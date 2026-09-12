import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/model/clinic_gallery_model.dart';

class ClinicPhotosController extends GetxController {
  var isUploading = false.obs;
  var isDeleting = false.obs;
  var isGalleryLoading = false.obs;
  var galleryList = <GalleryItem>[].obs;
  var selectedGalleryIds = <String>{}.obs;

  // Pagination
  var currentPage = 1;
  var hasMoreData = true.obs;
  final int limit = 10;

  final ImagePicker _picker = ImagePicker();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchGallery();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isGalleryLoading.value &&
        hasMoreData.value) {
      fetchGallery();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchGallery({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMoreData.value = true;
      galleryList.clear();
    }

    if (!hasMoreData.value || isGalleryLoading.value) return;

    isGalleryLoading.value = true;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url =
          '${Urls.baseUrl}/clinic/galleries?page=$currentPage&limit=$limit';

      debugPrint('Fetch Gallery URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      debugPrint('Fetch Gallery Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final model = ClinicGalleryModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data != null) {
          final newData = model.data!.data ?? [];
          if (newData.isNotEmpty) {
            galleryList.addAll(newData);
            currentPage++;
          }

          if (newData.length < limit) {
            hasMoreData.value = false;
          }

          final currentIds = galleryList
              .map((item) => item.id)
              .whereType<String>()
              .toSet();
          selectedGalleryIds.removeWhere((id) => !currentIds.contains(id));
        }
      }
    } catch (e) {
      debugPrint('Error fetching gallery: $e');
    } finally {
      isGalleryLoading.value = false;
    }
  }

  Future<void> pickAndUploadImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isEmpty) return;

    if (isUploading.value) return;

    isUploading.value = true;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/galleries';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Authorization': token});

      for (var image in images) {
        final filePath = image.path;
        final extension = filePath.split('.').last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            filePath,
            contentType: MediaType(
              'image',
              extension == 'png' ? 'png' : 'jpeg',
            ),
          ),
        );
      }

      debugPrint('Upload Photos Request URL: $url');
      debugPrint('Upload Photos Request Files Count: ${request.files.length}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      log('Upload Photos Response Status Code: ${response.statusCode}');
      log('Upload Photos Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'success'.tr,
          'photos_uploaded_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        fetchGallery(isRefresh: true);
      } else {
        Get.snackbar('error'.tr, 'failed_to_upload_photos'.tr);
      }
    } catch (e) {
      debugPrint('Error uploading photos: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isUploading.value = false;
    }
  }

  bool isSelected(String? galleryId) {
    if (galleryId == null || galleryId.isEmpty) return false;
    return selectedGalleryIds.contains(galleryId);
  }

  void toggleSelection(String? galleryId) {
    if (galleryId == null || galleryId.isEmpty) return;
    if (selectedGalleryIds.contains(galleryId)) {
      selectedGalleryIds.remove(galleryId);
    } else {
      selectedGalleryIds.add(galleryId);
    }
  }

  Future<void> deleteSelectedPhotos() async {
    if (selectedGalleryIds.isEmpty || isDeleting.value) return;

    isDeleting.value = true;

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/clinic/clear-galleries';

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
        body: jsonEncode({'galleryIds': selectedGalleryIds.toList()}),
      );

      log('Delete Photos Response Status Code: ${response.statusCode}');
      log('Delete Photos Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        galleryList.removeWhere((item) => selectedGalleryIds.contains(item.id));
        selectedGalleryIds.clear();

        Get.snackbar(
          'success'.tr,
          'photos_deleted_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('error'.tr, 'failed_to_delete_photos'.tr);
      }
    } catch (e) {
      debugPrint('Error deleting photos: $e');
      Get.snackbar('error'.tr, 'failed_to_delete_photos'.tr);
    } finally {
      isDeleting.value = false;
    }
  }
}
