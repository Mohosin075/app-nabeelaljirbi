class DoctorAppointmentModel {
  bool? success;
  String? message;
  AppointmentData? data;

  DoctorAppointmentModel({this.success, this.message, this.data});

  DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AppointmentData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['limit'] = limit;
    data['total'] = total;
    return data;
  }
}

class Appointment {
  String? id;
  String? clinicId;
  String? doctorId;
  String? patientId;
  String? consultDate;
  String? startTime;
  String? endTime;
  int? serialNumber;
  String? status;
  String? createdAt;
  String? updatedAt;
  Patient? patient;
  Clinic? clinic;
  List<DoctorRatings>? doctorRatings;

  Appointment({
    this.id,
    this.clinicId,
    this.doctorId,
    this.patientId,
    this.consultDate,
    this.startTime,
    this.endTime,
    this.serialNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.patient,
    this.clinic,
    this.doctorRatings,
  });

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clinicId = json['clinicId'];
    doctorId = json['doctorId'];
    patientId = json['patientId'];
    consultDate = json['consultDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    serialNumber = json['serialNumber'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    patient = json['patient'] != null
        ? Patient.fromJson(json['patient'])
        : null;
    clinic = json['clinic'] != null ? Clinic.fromJson(json['clinic']) : null;
    if (json['doctorRatings'] != null) {
      doctorRatings = <DoctorRatings>[];
      json['doctorRatings'].forEach((v) {
        doctorRatings!.add(DoctorRatings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['clinicId'] = clinicId;
    data['doctorId'] = doctorId;
    data['patientId'] = patientId;
    data['consultDate'] = consultDate;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['serialNumber'] = serialNumber;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (patient != null) {
      data['patient'] = patient!.toJson();
    }
    if (clinic != null) {
      data['clinic'] = clinic!.toJson();
    }
    if (doctorRatings != null) {
      data['doctorRatings'] = doctorRatings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Patient {
  User? user;

  Patient({this.user});

  Patient.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? fullName;
  String? profileImage;
  String? phoneNumber;
  String? gender;
  String? dateOfBirth;

  User({
    this.fullName,
    this.profileImage,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
  });

  User.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    profileImage = json['profileImage'];
    phoneNumber = json['phoneNumber'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['profileImage'] = profileImage;
    data['phoneNumber'] = phoneNumber;
    data['gender'] = gender;
    data['dateOfBirth'] = dateOfBirth;
    return data;
  }
}

class Clinic {
  String? id;
  String? userId;
  String? managerName;
  String? managerPhone;
  String? logo;
  String? clinicName;
  String? about;
  String? contactPhone;
  String? location;
  double? latitude;
  double? longitude;
  bool? adminVerified;
  String? createdAt;
  String? updatedAt;

  Clinic({
    this.id,
    this.userId,
    this.managerName,
    this.managerPhone,
    this.logo,
    this.clinicName,
    this.about,
    this.contactPhone,
    this.location,
    this.latitude,
    this.longitude,
    this.adminVerified,
    this.createdAt,
    this.updatedAt,
  });

  Clinic.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    managerName = json['managerName'];
    managerPhone = json['managerPhone'];
    logo = json['logo'];
    clinicName = json['clinicName'];
    about = json['about'];
    contactPhone = json['contactPhone'];
    location = json['location'];
    latitude = json['latitude']?.toDouble();
    longitude = json['longitude']?.toDouble();
    adminVerified = json['adminVerified'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['managerName'] = managerName;
    data['managerPhone'] = managerPhone;
    data['logo'] = logo;
    data['clinicName'] = clinicName;
    data['about'] = about;
    data['contactPhone'] = contactPhone;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['adminVerified'] = adminVerified;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class DoctorRatings {
  int? rating;

  DoctorRatings({this.rating});

  DoctorRatings.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    return data;
  }
}
