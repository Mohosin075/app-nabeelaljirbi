// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart' show AppColors;
import 'package:nabeelaljirbi_app/core/const/cities_data.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/qualification_item_model.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/model/specialist_model.dart';

class DoctorEditProfileController extends GetxController {
  final _profileController = Get.find<DoctorProfileController>();

  final fullNameController = TextEditingController();
  final addressController = TextEditingController();
  final experienceController = TextEditingController();
  final specialtyController = TextEditingController();
  final licenseController = TextEditingController();
  final consultationFeeController = TextEditingController();
  final dobController = TextEditingController();
  final biographyController = TextEditingController();

  var qualifications = <QualificationItem>[].obs;

  void addQualification() {
    qualifications.add(QualificationItem());
  }

  void removeQualification(int index) {
    if (index >= 0 && index < qualifications.length) {
      final item = qualifications.removeAt(index);
      item.dispose();
    }
  }

  var isLoading = false.obs;
  var selectedGender = ''.obs;
  var selectedCountry = ''.obs;
  var selectedCity = ''.obs;
  var profileImage = Rxn<File>();
  var biographyImage = Rxn<File>();

  var specialistList = <SpecialistModel>[].obs;
  var selectedSpecialty = ''.obs;

  List<String> get specialtyNames =>
      specialistList.map((e) => e.name ?? '').toList();

  List<String> get specialtyImages =>
      specialistList.map((e) => e.image ?? '').toList();

  final List<String> genders = ['MALE', 'FEMALE'];
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
    ever(_profileController.doctorProfile, (_) => _initializeData());
    getSpecialists();
  }

  void _initializeData() {
    final data = _profileController.doctorProfile.value;
    if (data != null) {
      fullNameController.text = data.fullName ?? '';
      addressController.text = data.address ?? '';
      experienceController.text = data.doctor?.experience ?? '';
      experienceController.text = data.doctor?.experience ?? '';
      // specialtyController.text = data.doctor?.speciality ?? '';
      selectedSpecialty.value = data.doctor?.speciality ?? '';
      licenseController.text = data.doctor?.licenseNumber ?? '';
      biographyController.text = data.doctor?.biography ?? '';
      qualifications.value = QualificationItem.decodeList(data.doctor?.biography);
      consultationFeeController.text =
          data.doctor?.consultFee?.toString() ?? '';
      if (data.dateOfBirth != null) {
        dobController.text =
            "${data.dateOfBirth!.year}-${data.dateOfBirth!.month.toString().padLeft(2, '0')}-${data.dateOfBirth!.day.toString().padLeft(2, '0')}";
      } else {
        dobController.text = '';
      }

      selectedGender.value = data.gender ?? 'MALE';
      selectedCountry.value = data.country ?? '';
      selectedCity.value = data.city ?? '';
    }
  }

  void onCountryChanged(String? country) {
    if (country != null) {
      selectedCountry.value = country;
      selectedCity.value = '';
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await _showCustomDatePicker(context);
    if (picked != null) {
      dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<DateTime?> _showCustomDatePicker(BuildContext context) async {
    int? selectedYear;
    int? selectedMonth;
    DateTime? selectedDay;

    // Step 1: Select Year
    selectedYear = await showDialog<int>(
      context: context,
      builder: (context) => _YearPickerDialog(
        initialYear:
            _profileController.doctorProfile.value?.dateOfBirth?.year ?? 1990,
      ),
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

  bool _isPickerActive = false;

  Future<void> pickImage() async {
    if (_isPickerActive) return;
    _isPickerActive = true;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        biographyImage.value = File(image.path);
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    } finally {
      _isPickerActive = false;
    }
  }

  Future<void> getSpecialists() async {
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url =
          '${Urls.baseUrl}/specialist?page=1&limit=50'; // Increased limit to get more

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

  @override
  void onClose() {
    fullNameController.dispose();
    addressController.dispose();
    experienceController.dispose();
    specialtyController.dispose();
    licenseController.dispose();
    consultationFeeController.dispose();
    dobController.dispose();
    super.onClose();
  }

  Future<void> saveChanges() async {
    if (selectedCity.value.trim().isEmpty) {
      Get.snackbar('error'.tr, 'please_select_city'.tr);
      return;
    }

    final qualError = QualificationItem.validateList(qualifications);
    if (qualError != null) {
      Get.snackbar('error'.tr, qualError,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final String token = SharedPrefHelper.getAccessToken() ?? '';
      final String url = '${Urls.baseUrl}/doctor/profile-update';

      debugPrint('UPDATING DOCTOR PROFILE: $url');
      debugPrint('TOKEN: $token');

      var request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers.addAll({'Authorization': token});

      // Wrapped in a single 'data' field as a JSON string and flattened
      final Map<String, dynamic> profileData = {
        "fullName": fullNameController.text.trim(),
        "gender": selectedGender.value.toUpperCase(),
        "dateOfBirth": dobController.text.trim(),
        "country": selectedCountry.value,
        "city": selectedCity.value,
        "address": addressController.text.trim(),
        "profileCompleted": true,
        "speciality": selectedSpecialty.value,
        "experience": experienceController.text.trim(),
        "licenseNumber": licenseController.text.trim(),
        "consultFee": int.tryParse(consultationFeeController.text) ?? 0,
        "clinicId": null,
        "biography": QualificationItem.encodeList(qualifications),
      };

      request.fields['data'] = jsonEncode(profileData);
      debugPrint('PAYLOAD DATA: ${request.fields['data']}');

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

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint('RESPONSE STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['data'] != null) {
          // Save role if present
          final String? role = responseData['data']?['role'];
          if (role != null) {
            await SharedPrefHelper.saveRole(role.toUpperCase());
            debugPrint('User role saved: $role (Doctor Edit)');
          }

          // Save new accessToken if present
          if (responseData['data']['accessToken'] != null) {
            await SharedPrefHelper.saveToken(
              responseData['data']['accessToken'],
            );
            debugPrint('🔑 Access Token updated in SharedPrefs (Doctor Edit)');
          }
        }

        // Update local observables for instant UI feedback
        _profileController.name.value = fullNameController.text.trim();
        if (_profileController.doctorProfile.value != null) {
          _profileController.doctorProfile.value!.fullName = fullNameController
              .text
              .trim();
          _profileController.doctorProfile.refresh();
        }

        await _profileController.fetchProfile();

        Get.back();
        Get.snackbar(
          'success'.tr,
          'profile_updated_successfully'.tr,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
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
