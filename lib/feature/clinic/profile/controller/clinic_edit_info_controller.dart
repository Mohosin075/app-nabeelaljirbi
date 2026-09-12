import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/cities_data.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';

class ClinicEditInfoController extends GetxController {
  final ClinicProfileController _profileController =
      Get.find<ClinicProfileController>();

  // Profile Data
  var isLoading = false.obs;
  var logoFile = Rxn<XFile>();

  // Clinic Manager Info
  final managerNameController = TextEditingController();
  final managerPhoneController = TextEditingController();

  // Clinic Information
  final clinicNameController = TextEditingController();
  final aboutClinicController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final locationController = TextEditingController();

  // Coordinates
  double latitude = 23.7808875;
  double longitude = 90.2792371;

  final RxList<Map<String, dynamic>> locationPredictions =
      <Map<String, dynamic>>[].obs;
  Timer? _debounce;

  // Dropdown values
  final RxString selectedCountry = "".obs;
  final RxString selectedCity = "".obs;

  final List<String> countries = citiesData.keys.toList();

  List<String> get cities =>
      selectedCountry.value.isNotEmpty &&
          citiesData.containsKey(selectedCountry.value)
      ? citiesData[selectedCountry.value]!
      : [];

  // Manager Phone Country Selection
  RxString managerPhoneCountryCode = '+218'.obs;
  RxString managerPhoneCountryName = 'libya'.obs;
  RxString managerPhoneCountryFlag = IconsPath.libya.obs;

  // Contact Phone Country Selection
  RxString contactPhoneCountryCode = '+218'.obs;
  RxString contactPhoneCountryName = 'libya'.obs;
  RxString contactPhoneCountryFlag = IconsPath.libya.obs;

  // List of countries with flags and codes
  final List<Map<String, String>> countryPhoneList = [
    {'code': '+218', 'name': 'libya', 'flag': IconsPath.libya},
    {'code': '+216', 'name': 'tunisia', 'flag': IconsPath.tunisia},
    {'code': '+20', 'name': 'egypt', 'flag': IconsPath.egypt},
    {'code': '+213', 'name': 'algeria', 'flag': IconsPath.algeria},
  ];

  @override
  void onInit() {
    super.onInit();
    _preFillData();
  }

  void _preFillData() {
    final data = _profileController.clinicProfile.value;
    if (data != null) {
      managerNameController.text = data.clinic?.managerName ?? '';
      // Extract phone number without country code if present
      String managerPhone = data.clinic?.managerPhone ?? '';
      _parsePhoneNumber(managerPhone, isManager: true);

      clinicNameController.text = data.clinic?.clinicName ?? '';
      aboutClinicController.text = data.clinic?.about ?? '';

      String contactPhone = data.clinic?.contactPhone ?? '';
      _parsePhoneNumber(contactPhone, isManager: false);

      locationController.text = data.clinic?.location ?? '';
      selectedCountry.value = data.country ?? '';
      selectedCity.value = data.city ?? '';
      if (data.clinic?.latitude != null) latitude = data.clinic!.latitude!;
      if (data.clinic?.longitude != null) longitude = data.clinic!.longitude!;
    }
  }

  void _parsePhoneNumber(String phone, {required bool isManager}) {
    if (phone.isEmpty) return;

    // Try to find matching country code
    for (var country in countryPhoneList) {
      if (phone.startsWith(country['code']!)) {
        if (isManager) {
          managerPhoneCountryCode.value = country['code']!;
          managerPhoneCountryName.value = country['name']!;
          managerPhoneCountryFlag.value = country['flag']!;
          managerPhoneController.text = phone.substring(
            country['code']!.length,
          );
        } else {
          contactPhoneCountryCode.value = country['code']!;
          contactPhoneCountryName.value = country['name']!;
          contactPhoneCountryFlag.value = country['flag']!;
          contactPhoneController.text = phone.substring(
            country['code']!.length,
          );
        }
        return;
      }
    }
    // If no country code found, use the phone as is
    if (isManager) {
      managerPhoneController.text = phone;
    } else {
      contactPhoneController.text = phone;
    }
  }

  void onCountryChanged(String? country) {
    if (country != null) {
      selectedCountry.value = country;
      selectedCity.value = '';
    }
  }

  void selectManagerPhoneCountry(String code, String name, String flag) {
    managerPhoneCountryCode.value = code;
    managerPhoneCountryName.value = name;
    managerPhoneCountryFlag.value = flag;
  }

  void selectContactPhoneCountry(String code, String name, String flag) {
    contactPhoneCountryCode.value = code;
    contactPhoneCountryName.value = name;
    contactPhoneCountryFlag.value = flag;
  }

  int getPhoneRequiredLength(String countryCode) {
    switch (countryCode) {
      case '+218':
        return 9;
      case '+216':
        return 8;
      case '+20':
        return 10;
      case '+213':
        return 9;
      default:
        return 15;
    }
  }

  int get managerPhoneRequiredLength =>
      getPhoneRequiredLength(managerPhoneCountryCode.value);

  int get contactPhoneRequiredLength =>
      getPhoneRequiredLength(contactPhoneCountryCode.value);

  String? validatePhone(String? value, String countryCode) {
    if (value == null || value.isEmpty) {
      return 'please_enter_phone'.tr;
    }

    // Remove any non-digits
    final cleanPhone = value.replaceAll(RegExp(r'\D'), '');

    switch (countryCode) {
      case '+218': // Libya
        if (cleanPhone.length != 9) {
          return 'phone_9_digits'.tr;
        }
        if (!RegExp(r'^(91|92|94|93|95)').hasMatch(cleanPhone)) {
          return 'invalid_provider_libya'.tr;
        }
        break;

      case '+216': // Tunisia
        if (cleanPhone.length != 8) {
          return 'phone_8_digits'.tr;
        }
        break;

      case '+20': // Egypt
        if (cleanPhone.length != 10) {
          return 'phone_10_digits'.tr;
        }
        if (!RegExp(r'^(10|11|12|15)').hasMatch(cleanPhone)) {
          return 'invalid_provider_egypt'.tr;
        }
        break;

      case '+213': // Algeria
        if (cleanPhone.length != 9) {
          return 'phone_9_digits'.tr;
        }
        if (!RegExp(r'^(5|6|7)').hasMatch(cleanPhone)) {
          return 'invalid_provider_algeria'.tr;
        }
        break;

      default:
        if (cleanPhone.length < 8) {
          return 'phone_min_8_digits'.tr;
        }
    }

    return null;
  }

  String? validateManagerPhone(String? value) =>
      validatePhone(value, managerPhoneCountryCode.value);

  String? validateContactPhone(String? value) =>
      validatePhone(value, contactPhoneCountryCode.value);

  Future<void> pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logoFile.value = image;
    }
  }

  Future<void> searchLocation(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        locationPredictions.clear();
        return;
      }

      try {
        final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'limit': '7',
        });

        debugPrint('Requesting: $uri');

        final response = await http.get(
          uri,
          headers: {
            'User-Agent':
                'NabeelAljirbi-FlutterApp/1.0.0 (admin@nabeelaljirbi.com)',
            'Accept': 'application/json',
            'Accept-Language': 'en-US,en;q=0.9,ar;q=0.8',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          locationPredictions.value = data.cast<Map<String, dynamic>>();
        } else {
          debugPrint(
            'Location search failed with status: ${response.statusCode}',
          );
          debugPrint('Response Body: ${response.body}');
          locationPredictions.clear();
        }
      } catch (e) {
        debugPrint('Error searching location: $e');
        locationPredictions.clear();
      }
    });
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
        'addressdetails': '1',
      });

      debugPrint('Reverse Geocoding: $uri');

      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'NabeelAljirbi-FlutterApp/1.0.0 (admin@nabeelaljirbi.com)',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9,ar;q=0.8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['display_name'] ?? '';
      } else {
        debugPrint(
          'Reverse geocoding failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error reverse geocoding location: $e');
    }
    return null;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    managerNameController.dispose();
    managerPhoneController.dispose();
    clinicNameController.dispose();
    aboutClinicController.dispose();
    contactPhoneController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<void> saveChanges() async {
    // Validate city is selected
    if (selectedCity.value.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_select_city'.tr);
      return;
    }

    // Validate manager phone
    String? managerPhoneError = validateManagerPhone(
      managerPhoneController.text,
    );
    if (managerPhoneError != null) {
      Get.snackbar('error'.tr, managerPhoneError);
      return;
    }

    // Validate contact phone
    String? contactPhoneError = validateContactPhone(
      contactPhoneController.text,
    );
    if (contactPhoneError != null) {
      Get.snackbar('error'.tr, contactPhoneError);
      return;
    }

    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      final uri = Uri.parse('${Urls.baseUrl}/clinic/update-info');

      var request = http.MultipartRequest('PATCH', uri);
      request.headers.addAll({'Authorization': token});

      debugPrint('UPDATING CLINIC INFO: $uri');
      debugPrint('TOKEN: $token');

      // Wrap all fields in a single 'data' field as a JSON string
      final Map<String, dynamic> profileData = {
        'country': selectedCountry.value,
        'city': selectedCity.value,
        'address': locationController.text,
        'profileCompleted': true,
        'managerName': managerNameController.text.trim(),
        'managerPhone':
            '${managerPhoneCountryCode.value}${managerPhoneController.text.trim()}',
        'clinicName': clinicNameController.text.trim(),
        'about': aboutClinicController.text.trim(),
        'contactPhone':
            '${contactPhoneCountryCode.value}${contactPhoneController.text.trim()}',
        'location': locationController.text.trim(),
        'latitude': latitude,
        'longitude': longitude,
      };

      request.fields['data'] = jsonEncode(profileData);
      debugPrint('PAYLOAD DATA: ${request.fields['data']}');

      // Add logo file if picked
      if (logoFile.value != null) {
        final filePath = logoFile.value!.path;
        final extension = filePath.split('.').last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            'companyLogo',
            filePath,
            contentType: MediaType(
              'image',
              extension == 'png' ? 'png' : 'jpeg',
            ),
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('RESPONSE STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          // Save new accessToken if present
          if (responseData['data']['accessToken'] != null) {
            await SharedPrefHelper.saveToken(
              responseData['data']['accessToken'],
            );
            debugPrint('🔑 Access Token updated in SharedPrefs (Clinic Edit)');
          }
        }

        Get.back();
        Get.snackbar(
          'success'.tr,
          'clinic_updated_success'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        // Refresh profile data
        await _profileController.fetchClinicProfile();
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message']?.toString() ?? '';
        if (errorMessage.isEmpty) {
          errorMessage = 'failed_to_update_clinic'.tr;
        }
        Get.snackbar(
          'error'.tr,
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('UPDATE ERROR: $e');
      Get.snackbar(
        'error'.tr,
        e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
