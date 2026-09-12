class DoctorProfileModel {
  bool? success;
  String? message;
  DoctorProfileData? data;

  DoctorProfileModel({this.success, this.message, this.data});

  DoctorProfileModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? DoctorProfileData.fromJson(json['data'])
        : null;
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

class DoctorProfileData {
  String? id;
  String? fullName;
  String? gender;
  DateTime? dateOfBirth;
  String? country;
  String? city;
  String? address;
  String? profileImage;
  String? phoneNumber;
  String? status;
  String? role;
  String? email;
  String? referralCode;
  num? wallet;
  int? totalReferrals;
  num? totalEarnings;
  num? currentEarnings;
  Doctor? doctor;
  num? weightedRating;
  int? reviewCount;

  DoctorProfileData({
    this.id,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    this.country,
    this.city,
    this.address,
    this.profileImage,
    this.phoneNumber,
    this.status,
    this.role,
    this.email,
    this.referralCode,
    this.wallet,
    this.totalReferrals,
    this.totalEarnings,
    this.currentEarnings,
    this.doctor,
    this.weightedRating,
    this.reviewCount,
  });

  DoctorProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'] != null
        ? DateTime.tryParse(json['dateOfBirth'])
        : null;
    country = json['country'];
    city = json['city'];
    address = json['address'];
    profileImage = json['profileImage'];
    phoneNumber = json['phoneNumber'];
    status = json['status'];
    role = json['role'];
    email = json['email'];
    referralCode = json['referralCode'];
    wallet = json['wallet'];
    totalReferrals = json['totalReferrals'];
    totalEarnings = json['totalEarnings'];
    currentEarnings = json['currentEarnings'];
    doctor = json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null;
    weightedRating = json['weightedRating'];
    reviewCount = json['reviewCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['gender'] = gender;
    data['dateOfBirth'] = dateOfBirth?.toIso8601String();
    data['country'] = country;
    data['city'] = city;
    data['address'] = address;
    data['profileImage'] = profileImage;
    data['phoneNumber'] = phoneNumber;
    data['status'] = status;
    data['role'] = role;
    data['email'] = email;
    data['referralCode'] = referralCode;
    data['wallet'] = wallet;
    data['totalReferrals'] = totalReferrals;
    data['totalEarnings'] = totalEarnings;
    data['currentEarnings'] = currentEarnings;
    if (doctor != null) {
      data['doctor'] = doctor!.toJson();
    }
    data['weightedRating'] = weightedRating;
    data['reviewCount'] = reviewCount;
    return data;
  }
}

class Doctor {
  String? speciality;
  String? experience;
  String? licenseNumber;
  int? consultFee;
  String? clinicId;
  String? joinClinicDate;
  String? createdAt;
  String? biography;
  Clinic? clinic;

  Doctor({
    this.speciality,
    this.experience,
    this.licenseNumber,
    this.consultFee,
    this.clinicId,
    this.joinClinicDate,
    this.createdAt,
    this.biography,
    this.clinic,
  });

  Doctor.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'];
    experience = json['experience'];
    licenseNumber = json['licenseNumber'];
    consultFee = json['consultFee'];
    clinicId = json['clinicId'];
    joinClinicDate = json['joinClinicDate'];
    createdAt = json['createdAt'];
    biography = json['biography'];
    clinic = json['clinic'] != null ? Clinic.fromJson(json['clinic']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['speciality'] = speciality;
    data['experience'] = experience;
    data['licenseNumber'] = licenseNumber;
    data['consultFee'] = consultFee;
    data['clinicId'] = clinicId;
    data['joinClinicDate'] = joinClinicDate;
    data['createdAt'] = createdAt;
    data['biography'] = biography;
    if (clinic != null) {
      data['clinic'] = clinic!.toJson();
    }
    return data;
  }
}

class Clinic {
  String? logo;
  String? clinicName;
  String? about;
  String? contactPhone;
  String? location;
  double? latitude;
  double? longitude;
  bool? adminVerified;

  Clinic({
    this.logo,
    this.clinicName,
    this.about,
    this.contactPhone,
    this.location,
    this.latitude,
    this.longitude,
    this.adminVerified,
  });

  Clinic.fromJson(Map<String, dynamic> json) {
    logo = json['logo'];
    clinicName = json['clinicName'];
    about = json['about'];
    contactPhone = json['contactPhone'];
    location = json['location'];
    latitude = json['latitude']?.toDouble();
    longitude = json['longitude']?.toDouble();
    adminVerified = json['adminVerified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logo'] = logo;
    data['clinicName'] = clinicName;
    data['about'] = about;
    data['contactPhone'] = contactPhone;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['adminVerified'] = adminVerified;
    return data;
  }
}
