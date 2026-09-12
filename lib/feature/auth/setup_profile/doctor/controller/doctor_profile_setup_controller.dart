// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/clinic_list_model.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/specialist_model.dart';
import 'package:nabeelaljirbi_app/core/const/cities_data.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/auth/setup_profile/doctor/view/doctor_refer_screen.dart';

class DoctorProfileSetupController extends GetxController {
  // Text Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController =
      TextEditingController(); // Added email controller
  final TextEditingController addressController =
      TextEditingController(); // Optional
  final Rx<String?> selectedSpecialty = Rx<String?>(null);
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController consultationFeeController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Validators
  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'is_required'.tr;
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

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ${'is_required'.tr}';
    }
    return null;
  }

  final ImagePicker _picker = ImagePicker();

  final RxString latitude = ''.obs;
  final RxString longitude = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Request location permission on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestLocationPermission();
      requestLocationPermission();
      fetchClinics();
      getSpecialists();
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

  // Reactive Variables for Selections
  final Rx<String?> selectedGender = Rx<String?>(null);
  final Rx<DateTime?> selectedDob = Rx<DateTime?>(null);
  final Rx<String?> selectedCountry = Rx<String?>(null);
  final Rx<String?> selectedCity = Rx<String?>(null);
  final Rx<String?> selectedClinicInfo = Rx<String?>(null); // Name
  final Rx<String?> selectedClinicId = Rx<String?>(null); // ID
  final RxBool isCertified = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<File?> biographyImage = Rx<File?>(null);

  // Clinic Fetching
  var isClinicsLoading = false.obs;
  var clinics = <ClinicItem>[].obs;

  Future<void> fetchClinics({String? searchTerm}) async {
    isClinicsLoading.value = true;
    try {
      final token = SharedPrefHelper.getAccessToken() ?? '';
      String url =
          '${Urls.baseUrl}/clinic?page=1&limit=50'; // Simplified for setup

      if (searchTerm != null && searchTerm.isNotEmpty) {
        url = '$url&searchTerm=${searchTerm.trim()}';
      }

      debugPrint('Fetching clinics for setup from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final model = ClinicListModel.fromJson(jsonDecode(response.body));
        if (model.success == true && model.data?.clinics != null) {
          clinics.assignAll(model.data!.clinics!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching clinics in setup: $e');
    } finally {
      isClinicsLoading.value = false;
    }
  }

  // Specialist Fetching
  var specialistList = <SpecialistModel>[].obs;

  Future<void> getSpecialists() async {
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/specialist?page=1&limit=50';

      debugPrint('FETCHING SPECIALISTS: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': token, 'Content-Type': 'application/json'},
      );

      debugPrint('SPECIALISTS RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final specialistResponse = SpecialistResponse.fromJson(data);
        if (specialistResponse.data != null) {
          specialistList.assignAll(specialistResponse.data!);
        }
      }
    } catch (e) {
      debugPrint('Error fetching specialists: $e');
    }
  }

  bool _isPickerActive = false;

  Future<void> pickImage() async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    } finally {
      _isPickerActive = false;
    }
  }

  Future<void> pickBiography() async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        biographyImage.value = File(image.path);
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    } finally {
      _isPickerActive = false;
    }
  }

  // Mock Data for Dropdowns
  // Data imported from cities.json
  // ignore: unused_field
  final Map<String, List<String>> _citiesData = citiesData;

  final List<String> genderOptions = ['male', 'female'];
  final List<String> countryOptions = citiesData.keys.toList();
  List<String> get cityOptions =>
      selectedCountry.value != null &&
          citiesData.containsKey(selectedCountry.value)
      ? citiesData[selectedCountry.value]!
      : [];

  final List<String> clinicOptions = [];

  List<String> get specialtyOptions =>
      specialistList.map((e) => e.name ?? '').toList();

  List<String> get specialtyImages =>
      specialistList.map((e) => e.image ?? '').toList();

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose(); // Dispose email controller
    addressController.dispose();
    experienceController.dispose();
    licenseController.dispose();
    consultationFeeController.dispose();
    super.onClose();
  }

  // Selection Methods
  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void selectCountry(String country) {
    selectedCountry.value = country;
    // Reset city when country changes
    selectedCity.value = null;
  }

  void selectCity(String city) {
    selectedCity.value = city;
  }

  void selectSpecialty(String specialty) {
    selectedSpecialty.value = specialty;
  }

  void selectClinic(ClinicItem clinic) {
    selectedClinicInfo.value = clinic.clinicName;
    selectedClinicId.value = clinic.id;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await _showCustomDatePicker(context);
    if (picked != null) {
      selectedDob.value = picked;
    }
  }

  Future<DateTime?> _showCustomDatePicker(BuildContext context) async {
    int? selectedYear;
    int? selectedMonth;
    DateTime? selectedDay;

    // Step 1: Select Year
    selectedYear = await showDialog<int>(
      context: context,
      builder: (context) =>
          _YearPickerDialog(initialYear: selectedDob.value?.year ?? 1990),
    );
    if (!context.mounted) return null;

    if (selectedYear == null) return null;

    // Step 2: Select Month
    selectedMonth = await showDialog<int>(
      context: context,
      builder: (context) => _MonthPickerDialog(selectedYear: selectedYear!),
    );
    if (!context.mounted) return null;

    if (selectedMonth == null) return null;

    // Step 3: Select Day
    selectedDay = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear, selectedMonth, 1),
      firstDate: DateTime(selectedYear, selectedMonth, 1),
      lastDate: DateTime(
        selectedYear,
        selectedMonth,
        DateTime(selectedYear, selectedMonth + 1, 0).day,
      ),
      initialEntryMode: DatePickerEntryMode.calendar,
      helpText: 'select_day'.tr,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff137CCF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff137CCF),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    return selectedDay;
  }

  // Date Formatting Helper
  String? get formattedDob {
    if (selectedDob.value == null) return null;
    return "${selectedDob.value!.year}-${selectedDob.value!.month.toString().padLeft(2, '0')}-${selectedDob.value!.day.toString().padLeft(2, '0')}";
  }

  Future<void> submitProfile() async {
    // Add validation logic here
    if (!formKey.currentState!.validate()) {
      // Get.snackbar('error'.tr, 'error_fill_fields'.tr); // Inline errors are enough
      return;
    }

    if (profileImage.value == null) {
      Get.snackbar('error'.tr, 'please_select_image'.tr);
      return;
    }

    if (!isCertified.value) {
      Get.snackbar('error'.tr, 'certification_required'.tr);
      return;
    }

    isLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/doctor/profile-update';

      var request = http.MultipartRequest('PATCH', Uri.parse(url));

      request.headers.addAll({
        'Authorization': token, // No Bearer prefix as requested previously
      });

      // Wrap all fields in a single 'data' field as a JSON string
      final Map<String, dynamic> profileData = {
        "fullName": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "gender": (selectedGender.value ?? 'male').toUpperCase(),
        "dateOfBirth": formattedDob!,
        "country": selectedCountry.value ?? '',
        "city": selectedCity.value ?? '',
        "address": addressController.text.trim(),
        "profileCompleted": true,
        "speciality": selectedSpecialty.value ?? '',
        "experience": experienceController.text.trim(),
        "licenseNumber": licenseController.text.trim(),
        "consultFee": int.tryParse(consultationFeeController.text.trim()) ?? 0,
        "clinicId": selectedClinicId.value,
      };

      request.fields['data'] = jsonEncode(profileData);

      if (profileImage.value != null) {
        final filePath = profileImage.value!.path;
        final extension = filePath.split('.').last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            filePath,
            contentType: MediaType(
              'image',
              extension == 'png' ? 'png' : 'jpeg',
            ),
          ),
        );
      }

      if (biographyImage.value != null) {
        final filePath = biographyImage.value!.path;
        final extension = filePath.split('.').last.toLowerCase();
        request.files.add(
          await http.MultipartFile.fromPath(
            'biography',
            filePath,
            contentType: MediaType(
              'image',
              extension == 'png' ? 'png' : 'jpeg',
            ),
          ),
        );
      }

      debugPrint('Submitting Doctor Profile Update to: $url');
      debugPrint('Data Field: ${request.fields['data']}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['data'] != null) {
          // Save role if present
          final String? role = responseData['data']?['role'];
          if (role != null) {
            await SharedPrefHelper.saveRole(role.toUpperCase());
            debugPrint('User role saved: $role');
          }

          // Save new accessToken if present
          if (responseData['data']['accessToken'] != null) {
            await SharedPrefHelper.saveToken(
              responseData['data']['accessToken'],
            );
            debugPrint('🔑 Access Token updated in SharedPrefs (Doctor Setup)');
          }
        }
        // Proceed to next step
        Get.to(() => DoctorReferScreen());
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          responseData['message'] ?? 'failed_to_update_profile'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error updating doctor profile: $e');
      Get.snackbar('error'.tr, 'something_went_wrong'.tr);
    } finally {
      isLoading.value = false;
    }
  }
}

// Year Picker Dialog Widget
class _YearPickerDialog extends StatelessWidget {
  final int initialYear;

  const _YearPickerDialog({required this.initialYear});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - 1900 + 1,
      (index) => currentYear - index,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'select_year'.tr,
              style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = year == initialYear;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: const Color(
                      0xff137CCF,
                    ).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(
                      year.toString(),
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xff137CCF)
                            : const Color(0xff2D2D2D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () => Navigator.of(context).pop(year),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Month Picker Dialog Widget
class _MonthPickerDialog extends StatelessWidget {
  final int selectedYear;

  const _MonthPickerDialog({required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    final months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${'select_month'.tr} - $selectedYear',
              style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Navigator.of(context).pop(index + 1),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff137CCF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xff137CCF).withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      months[index].tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff137CCF),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
