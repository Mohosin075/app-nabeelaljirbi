import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/patient/home/model/banner_model.dart';

class BannerController extends GetxController {
  var isLoading = false.obs;
  var banners = <BannerData>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedBanners();
    fetchBanners();
  }

  void _loadCachedBanners() {
    final cachedData = SharedPrefHelper.getBannerData();
    if (cachedData != null) {
      try {
        final jsonData = jsonDecode(cachedData);
        final bannerModel = BannerModel.fromJson(jsonData);
        if (bannerModel.success == true && bannerModel.data != null) {
          banners.assignAll(bannerModel.data!);
          debugPrint('Loaded ${banners.length} banners from cache');
        }
      } catch (e) {
        debugPrint('Error decoding cached banners: $e');
      }
    }
  }

  Future<void> fetchBanners() async {
    // Only show loading indicator if we don't have cached data
    if (banners.isEmpty) {
      isLoading.value = true;
    }

    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final url = '${Urls.baseUrl}/banner';

      debugPrint('Fetching Banners URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('Banners Response Status: ${response.statusCode}');
      // debugPrint('Banners Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final bannerModel = BannerModel.fromJson(jsonData);

        if (bannerModel.success == true && bannerModel.data != null) {
          banners.assignAll(bannerModel.data!);
          // Save to cache for next time
          await SharedPrefHelper.saveBannerData(response.body);
        }
      } else {
        debugPrint('Failed to fetch banners: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
