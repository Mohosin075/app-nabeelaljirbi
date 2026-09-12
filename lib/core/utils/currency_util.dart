import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_profile_controller.dart';

class CurrencyUtil {
  /// Returns the currency symbol for the given country.
  /// Defaults to Libya's currency if the country is not recognized.
  static String getCurrencySymbol(String country) {
    switch (country.toLowerCase()) {
      case 'libya':
        return 'currency_libya'.tr; // Libyan Dinar
      case 'algeria':
        return 'currency_algeria'.tr; // Algerian Dinar
      case 'tunisia':
      case 'tunishia': // Handling user's spelling just in case
        return 'currency_tunisia'.tr; // Tunisian Dinar
      case 'egypt':
        return 'currency_egypt'.tr; // Egyptian Pound
      default:
        return 'currency_libya'.tr; // Default to Libya
    }
  }

  /// Gets the currency symbol based on the currently selected country in PatientProfileController or ClinicProfileController.
  static String getUserCurrencySymbol() {
    try {
      if (Get.isRegistered<PatientProfileController>()) {
        final controller = Get.find<PatientProfileController>();
        return getCurrencySymbol(controller.selectedCountry.value);
      } else if (Get.isRegistered<ClinicProfileController>()) {
        final controller = Get.find<ClinicProfileController>();
        return getCurrencySymbol(controller.selectedCountry.value);
      } else if (Get.isRegistered<DoctorProfileController>()) {
        final controller = Get.find<DoctorProfileController>();
        return getCurrencySymbol(controller.selectedCountry.value);
      }
      return 'currency_libya'.tr;
    } catch (e) {
      // Fallback if controller is not found or other error
      return 'currency_libya'.tr;
    }
  }
}
