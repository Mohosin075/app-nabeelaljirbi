import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/feature/patient/nav_bar/view/patient_nav_bar_screen.dart';
import 'package:nabeelaljirbi_app/feature/splash/view/splash_screen.dart';

import 'package:nabeelaljirbi_app/feature/patient/search/view/patient_search_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/clinic_details/view/clinic_details_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/view/doctor_details_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/booking/view/appointment_booking_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/booking/view/booking_confirmation_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/home/view/doctor_notification_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/notification/view/patient_notification_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/subscription/view/patient_subscription_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/subscription/view/clinic_subscription_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/nav_bar/view/doctor_nav_bar_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/nav_bar/view/clinic_nav_bar_screen.dart';
import 'package:nabeelaljirbi_app/feature/common/operations/receptionist_home_screen.dart';
import 'package:nabeelaljirbi_app/feature/clinic/home/view/clinic_notification_screen.dart';
import 'package:nabeelaljirbi_app/feature/doctor/subscription/view/doctor_subscription_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String patientNavBar = '/patientNavBar';
  static const String patientSearch = '/patientSearch';
  static const String clinicDetails = '/clinicDetails';
  static const String doctorDetails = '/doctorDetails';
  static const String bookAppointment = '/bookAppointment';
  static const String bookingConfirmation = '/bookingConfirmation';
  static const String doctorNotification = '/doctorNotification';
  static const String patientNotification = '/patientNotification';
  static const String patientSubscription = '/patientSubscription';
  static const String clinicSubscription = '/clinicSubscription';
  static const String doctorNavBar = '/doctorNavBar';
  static const String clinicNavBar = '/clinicNavBar';
  static const String receptionistHome = '/receptionistHome';
  static const String clinicNotification = '/clinicNotification';
  static const String doctorSubscription = '/doctorSubscription';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.leftToRight,
    ),
    GetPage(
      name: patientNavBar,
      page: () => PatientNavBarScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: patientSearch,
      page: () => PatientSearchScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: clinicDetails, page: () => ClinicDetailsScreen()),
    GetPage(name: doctorDetails, page: () => DoctorDetailsScreen()),
    GetPage(name: bookAppointment, page: () => AppointmentBookingScreen()),
    GetPage(
      name: bookingConfirmation,
      page: () => const BookingConfirmationScreen(),
    ),
    GetPage(
      name: doctorNotification,
      page: () => const DoctorNotificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: patientNotification,
      page: () => const PatientNotificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: patientSubscription,
      page: () => const PatientSubscriptionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: clinicSubscription,
      page: () => const ClinicSubscriptionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: doctorNavBar,
      page: () => DoctorNavBarScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: clinicNavBar,
      page: () => ClinicNavBarScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: receptionistHome,
      page: () => const ReceptionistHomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: clinicNotification,
      page: () => ClinicNotificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: doctorSubscription,
      page: () => const DoctorSubscriptionScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
