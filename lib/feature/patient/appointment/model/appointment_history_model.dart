class AppointmentHistoryModel {
  bool? success;
  String? message;
  AppointmentData? data;

  AppointmentHistoryModel({this.success, this.message, this.data});

  AppointmentHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AppointmentData.fromJson(json['data']) : null;
  }
}

class AppointmentData {
  Meta? meta;
  List<Appointment>? data;

  AppointmentData({this.meta, this.data});

  AppointmentData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <Appointment>[];
      json['data'].forEach((v) {
        data!.add(Appointment.fromJson(v));
      });
    }
  }
}

class Meta {
  int? page;
  int? limit;
  int? total;

  Meta({this.page, this.limit, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
  }
}

class Appointment {
  String? id;
  int? serialNumber;
  String? consultDate;
  String? status;
  String? absenceType;
  String get displayStatus => absenceType == 'DOCTOR_ABSENT'
      ? 'DOCTOR_ABSENT'
      : status == 'NOT_SHOW'
      ? 'PATIENT_NO_SHOW'
      : status ?? '';
  String? startTime;
  String? endTime;
  String? approximateEstimatedTime;
  String? bookedFor;
  String? familyMemberName;
  String? familyMemberRelation;
  String? cancellationReason;
  String? rejectionReason;
  String? noShowReason;
  Doctor? doctor;
  List<DoctorRating>? doctorRatings;
  Clinic? clinic;

  Appointment({
    this.id,
    this.serialNumber,
    this.consultDate,
    this.status,
    this.startTime,
    this.endTime,
    this.approximateEstimatedTime,
    this.bookedFor,
    this.familyMemberName,
    this.familyMemberRelation,
    this.cancellationReason,
    this.rejectionReason,
    this.noShowReason,
    this.doctor,
    this.doctorRatings,
    this.clinic,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serialNumber = json['serialNumber'];
    consultDate = json['consultDate'];
    status = json['status'];
    absenceType = json['absenceType'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    approximateEstimatedTime = json['approximateEstimatedTime'];
    bookedFor = json['bookedFor'];
    familyMemberName = json['familyMemberName'];
    familyMemberRelation = json['familyMemberRelation'];
    cancellationReason = json['cancellationReason'] ?? json['noShowReason'];
    rejectionReason = json['rejectionReason'];
    noShowReason =
        json['noShowReason'] ??
        (json['status'] == 'NOT_SHOW' ? json['cancellationReason'] : null);
    doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
    if (json['doctorRatings'] != null) {
      doctorRatings = <DoctorRating>[];
      json['doctorRatings'].forEach((v) {
        doctorRatings!.add(DoctorRating.fromJson(v));
      });
    }
    clinic = json['clinic'] != null ? Clinic.fromJson(json['clinic']) : null;
  }
}

class Doctor {
  String? speciality;
  User? user;

  Doctor({this.speciality, this.user});

  Doctor.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
}

class User {
  String? fullName;
  String? profileImage;
  String? address;

  User({this.fullName, this.profileImage, this.address});

  User.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    profileImage = json['profileImage'];
    address = json['address'];
  }
}

class Clinic {
  String? clinicName;
  String? location;
  String? contactPhone;
  String? logo;

  Clinic({this.clinicName, this.location, this.contactPhone, this.logo});

  Clinic.fromJson(Map<String, dynamic> json) {
    clinicName = json['clinicName'];
    location = json['location'];
    contactPhone = json['contactPhone'];
    logo = json['logo'];
  }
}

class DoctorRating {
  int? rating;

  DoctorRating({this.rating});

  DoctorRating.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
  }
}
