// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/cities_data.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_profile_controller.dart';

class PatientEditProfileController extends GetxController {
  final PatientProfileController _profileController =
      Get.find<PatientProfileController>();

  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();

  var isLoading = false.obs;
  var selectedGender = 'male'.obs;
  var selectedCountry = ''.obs;
  var selectedCity = ''.obs;
  var selectedDob = Rxn<DateTime>();
  var profileImage = Rxn<File>();

  final List<String> genders = ['male', 'female'];
  final List<String> countries = citiesData.keys.toList();

  List<String> get cities =>
      selectedCountry.value.isNotEmpty &&
          citiesData.containsKey(selectedCountry.value)
      ? citiesData[selectedCountry.value]!
      : [];

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    // Re-initialize if profile updates
    ever(_profileController.patientProfile, (_) => _initializeData());
  }

  void _initializeData() {
    final profileData = _profileController.patientProfile.value;
    if (profileData != null && profileData.user != null) {
      final user = profileData.user!;
      fullNameController.text = user.fullName ?? '';
      selectedDob.value = user.dateOfBirth;
      if (user.dateOfBirth != null) {
        dobController.text =
            "${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}";
      }
      addressController.text = user.address ?? '';
      selectedGender.value = (user.gender?.toLowerCase() == 'female')
          ? 'female'
          : 'male';
      selectedCountry.value = user.country ?? '';
      selectedCity.value = user.city ?? '';
    }
  }

  void onCountryChanged(String? country) {
    if (country != null) {
      selectedCountry.value = country;
      selectedCity.value = '';
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await _showCustomDatePicker(context);
    if (picked != null) {
      selectedDob.value = picked;
      dobController.text = "${picked.day}/${picked.month}/${picked.year}";
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

    if (selectedYear == null) return null;

    // Step 2: Select Month
    selectedMonth = await showDialog<int>(
      context: context,
      builder: (context) => _MonthPickerDialog(selectedYear: selectedYear!),
    );

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

  @override
  void onClose() {
    fullNameController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> saveChanges() async {
    if (selectedCity.value.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_select_city'.tr);
      return;
    }

    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/patient/profile-update';

      var request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll({'Authorization': token});

      final Map<String, dynamic> profileData = {
        "fullName": fullNameController.text.trim(),
        "gender": selectedGender.value.toUpperCase(),
        "dateOfBirth": selectedDob.value != null
            ? "${selectedDob.value!.year}-${selectedDob.value!.month.toString().padLeft(2, '0')}-${selectedDob.value!.day.toString().padLeft(2, '0')}"
            : "",
        "country": selectedCountry.value,
        "city": selectedCity.value,
        "address": addressController.text.trim(),
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

      debugPrint('Updating Profile: $url');
      debugPrint('Data: ${request.fields['data']}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          // Save new accessToken if present
          if (responseData['data']['accessToken'] != null) {
            SharedPrefHelper.saveToken(responseData['data']['accessToken']);
            debugPrint('🔑 Access Token updated in SharedPrefs (Edit Profile)');
          }
        }

        Get.back();
        Get.snackbar(
          'success'.tr,
          'profile_updated_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
        await _profileController.fetchProfile();
        Get.back();
      } else {
        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'error'.tr,
          responseData['message'] ?? 'failed_to_update_profile'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
