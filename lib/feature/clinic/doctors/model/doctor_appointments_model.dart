class DoctorAppointmentsModel {
  bool? success;
  String? message;
  DoctorAppointmentsData? data;

  DoctorAppointmentsModel({this.success, this.message, this.data});

  DoctorAppointmentsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? DoctorAppointmentsData.fromJson(json['data'])
        : null;
  }
}

class DoctorAppointmentsData {
  Meta? meta;
  AppointmentDoctor? doctor;
  List<DoctorAppointmentItem>? data;

  DoctorAppointmentsData({this.meta, this.doctor, this.data});

  DoctorAppointmentsData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    doctor = json['doctor'] != null
        ? AppointmentDoctor.fromJson(json['doctor'])
        : null;
    if (json['data'] != null) {
      data = <DoctorAppointmentItem>[];
      json['data'].forEach((v) {
        data!.add(DoctorAppointmentItem.fromJson(v));
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

class AppointmentDoctor {
  String? id;
  String? doctorId;
  String? name;
  String? country;
  String? city;
  String? specialty;
  String? experience;
  int? fee;
  String? profileImage;
  String? clinic;
  int? reviewCount;
  double? weightedRating;
  int? totalConsult;
  int? upcomingConsult;
  String? about;

  AppointmentDoctor({
    this.id,
    this.doctorId,
    this.name,
    this.country,
    this.city,
    this.specialty,
    this.experience,
    this.fee,
    this.profileImage,
    this.clinic,
    this.reviewCount,
    this.weightedRating,
    this.totalConsult,
    this.upcomingConsult,
    this.about,
  });

  AppointmentDoctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctorId'];
    name = json['name'];
    country = json['country'];
    city = json['city'];
    specialty = json['specialty'];
    experience = json['experience']?.toString();
    fee = json['fee'];
    profileImage = json['profileImage'];
    clinic = json['clinic'];
    reviewCount = json['reviewCount'];
    weightedRating = json['weightedRating']?.toDouble();
    totalConsult = json['totalConsult'];
    upcomingConsult = json['upcomingConsult'];
    about = json['about'];
  }
}

class DoctorAppointmentItem {
  String? id;
  String? consultDate;
  String? status;
  String? startTime;
  String? endTime;
  int? serialNumber;
  AppointmentPatient? patient;

  DoctorAppointmentItem({
    this.id,
    this.consultDate,
    this.status,
    this.startTime,
    this.endTime,
    this.serialNumber,
    this.patient,
  });

  DoctorAppointmentItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    consultDate = json['consultDate'];
    status = json['status'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    serialNumber = json['serialNumber'];
    patient = json['patient'] != null
        ? AppointmentPatient.fromJson(json['patient'])
        : null;
  }
}

class AppointmentPatient {
  PatientUser? user;

  AppointmentPatient({this.user});

  AppointmentPatient.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? PatientUser.fromJson(json['user']) : null;
  }
}

class PatientUser {
  String? fullName;
  String? phoneNumber;
  String? profileImage;
  String? gender;
  String? dateOfBirth;

  PatientUser({
    this.fullName,
    this.phoneNumber,
    this.profileImage,
    this.gender,
    this.dateOfBirth,
  });

  PatientUser.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    profileImage = json['profileImage'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'];
  }
}
