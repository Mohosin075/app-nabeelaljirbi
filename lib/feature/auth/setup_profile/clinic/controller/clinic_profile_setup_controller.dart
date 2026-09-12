import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nabeelaljirbi_app/core/const/cities_data.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/clinic/view/clinic_refer_screen.dart';

class ClinicProfileSetupController extends GetxController {
  final RxBool isLoading = false.obs;
  // Reactive Text Values
  final RxString managerName = "".obs;
  final RxString managerPhone = "".obs;
  final RxString clinicName = "".obs;
  final RxString aboutClinic = "".obs;
  final RxString contactPhone = "".obs;
  final RxString location = "".obs;

  final RxString latitude = "".obs;
  final RxString longitude = "".obs;

  final RxList<Map<String, dynamic>> locationPredictions =
      <Map<String, dynamic>>[].obs;
  Timer? _debounce;

  // Manager Phone Country Selection
  RxString managerPhoneCountryCode = '+218'.obs;
  RxString managerPhoneCountryName = 'libya'.obs;
  RxString managerPhoneCountryFlag = IconsPath.libya.obs;

  // Contact Phone Country Selection
  RxString contactPhoneCountryCode = '+218'.obs;
  RxString contactPhoneCountryName = 'libya'.obs;
  RxString contactPhoneCountryFlag = IconsPath.libya.obs;

  // List of countries with flags and codes
  final List<Map<String, String>> countries = [
    {'code': '+218', 'name': 'libya', 'flag': IconsPath.libya},
    {'code': '+216', 'name': 'tunisia', 'flag': IconsPath.tunisia},
    {'code': '+20', 'name': 'egypt', 'flag': IconsPath.egypt},
    {'code': '+213', 'name': 'algeria', 'flag': IconsPath.algeria},
  ];

  // Text Controllers
  final TextEditingController managerNameController = TextEditingController();
  final TextEditingController managerPhoneController = TextEditingController();
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController emailController =
      TextEditingController(); // Added email controller
  final TextEditingController aboutClinicController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Validators
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ${'is_required'.tr}';
    }
    return null;
  }

  String? validateEmail(String? value) {
    // if (value == null || value.trim().isEmpty) {
    //   return 'enter_valid_email'.tr;
    // }
    // if (!GetUtils.isEmail(value.trim())) {
    //   return 'enter_valid_email'.tr;
    // }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to Rx variables to trigger validation
    // ever(managerName, (_) => updateValidation());
    // ever(managerPhone, (_) => updateValidation());
    // ever(clinicName, (_) => updateValidation());
    // emailController.addListener(updateValidation); // Listen to email changes
    // ever(aboutClinic, (_) => updateValidation());
    // ever(contactPhone, (_) => updateValidation());
    // ever(selectedCountry, (_) => updateValidation());
    // ever(selectedCity, (_) => updateValidation());
    // ever(isCertified, (_) => updateValidation());
    // ever(clinicLogo, (_) => updateValidation());
    // ever(managerPhoneCountryCode, (_) => updateValidation());
    // ever(contactPhoneCountryCode, (_) => updateValidation());

    // Request location permission on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestLocationPermission();
    });
  }

  Future<void> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      latitude.value = position.latitude.toString();
      longitude.value = position.longitude.toString();
      debugPrint('Location fetched: ${latitude.value}, ${longitude.value}');
    } catch (e) {
      debugPrint('Error fetching location: $e');
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

  @override
  void onClose() {
    _debounce?.cancel();
    managerNameController.dispose();
    managerPhoneController.dispose();
    clinicNameController.dispose();
    emailController.dispose(); // Dispose email controller
    aboutClinicController.dispose();
    contactPhoneController.dispose();
    locationController.dispose();
    super.onClose();
  }

  // Reactive Variables for Selections
  final Rx<String?> selectedCountry = Rx<String?>(null);
  final Rx<String?> selectedCity = Rx<String?>(null);
  final RxBool isCertified = false.obs;
  final Rx<File?> clinicLogo = Rx<File?>(null);

  // Data
  // ignore: unused_field
  final Map<String, List<String>> _citiesData = citiesData;

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> countryOptions = citiesData.keys.toList();

  List<String> get cityOptions =>
      selectedCountry.value != null &&
          citiesData.containsKey(selectedCountry.value)
      ? citiesData[selectedCountry.value]!
      : [];

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      clinicLogo.value = File(image.path);
    }
  }

  // Selection Methods
  void selectCountry(String country) {
    selectedCountry.value = country;
    selectedCity.value = null;
  }

  void selectCity(String city) {
    selectedCity.value = city;
  }

  Future<void> submitProfile() async {
    if (!formKey.currentState!.validate()) {
      // Get.snackbar('error'.tr, 'error_fill_fields'.tr); // Inline errors are enough
      return;
    }

    if (clinicLogo.value == null) {
      Get.snackbar('error'.tr, 'please_select_image'.tr);
      return;
    }

    if (!isCertified.value) {
      Get.snackbar('error'.tr, 'certification_required'.tr);
      return;
    }

    isLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken();
      if (token == null) {
        Get.snackbar('error'.tr, 'error_token_expired'.tr);
        return;
      }

      var uri = Uri.parse('${Urls.baseUrl}/clinic/update-info');
      var request = http.MultipartRequest('PATCH', uri);

      request.headers.addAll({
        'Authorization': token,
        // 'Content-Type': 'multipart/form-data', // Let http package hande this
      });

      debugPrint("🚀 Submitting Clinic Profile...");

      final Map<String, dynamic> data = {
        "clinicName": clinicName.value,
        "managerName": managerName.value,
        "managerPhone": "${managerPhoneCountryCode.value}${managerPhone.value}",
        "email": emailController.text.trim(),
        "country": selectedCountry.value ?? "",
        "city": selectedCity.value ?? "",
        "about": aboutClinic.value,
        "contactPhone": "${contactPhoneCountryCode.value}${contactPhone.value}",
        "location": location.value,
        "latitude": double.tryParse(latitude.value) ?? 0.0,
        "longitude": double.tryParse(longitude.value) ?? 0.0,
        "profileCompleted": true,
      };

      debugPrint("📦 Request Payload: $data");

      request.fields['data'] = jsonEncode(data);

      if (clinicLogo.value != null) {
        final filePath = clinicLogo.value!.path;
        final extension = filePath.split('.').last.toLowerCase();
        var file = await http.MultipartFile.fromPath(
          'companyLogo', // Changed from 'logo' to 'companyLogo'
          filePath,
          contentType: MediaType('image', extension == 'png' ? 'png' : 'jpeg'),
        );
        request.files.add(file);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("📡 Response Status Code: ${response.statusCode}");
      debugPrint("📄 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Clinic Profile Created Successfully!");

        // Parse response and save role & token
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['data'] != null) {
            // Save role if present
            if (responseData['data']['role'] != null) {
              final String role = responseData['data']['role'];
              await SharedPrefHelper.saveRole(role);
              debugPrint("💾 Role saved to SharedPreferences: $role");
            }

            // Save new accessToken if present
            if (responseData['data']['accessToken'] != null) {
              await SharedPrefHelper.saveToken(
                responseData['data']['accessToken'],
              );
              debugPrint("🔑 Access Token updated in SharedPrefs (Clinic)");
            }
          }
        } catch (e) {
          debugPrint("⚠️ Error parsing role/token from response: $e");
        }

        // Proceed to next step
        Get.to(() => ClinicReferScreen());
      } else {
        debugPrint("❌ Failed to create profile: ${response.statusCode}");
        Get.snackbar('error'.tr, 'error_occurred_try_again'.tr);
        debugPrint("⚠️ API Error: ${response.body}");
      }
    } catch (e) {
      debugPrint("⛔ Exception caught: $e");
      Get.snackbar('error'.tr, 'error_occurred_try_again'.tr);
      debugPrint("Exception: $e");
    } finally {
      isLoading.value = false;
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
}
