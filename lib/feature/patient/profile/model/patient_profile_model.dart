class PatientProfileModel {
  final bool? success;
  final String? message;
  final PatientProfileData? data;

  PatientProfileModel({this.success, this.message, this.data});

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? PatientProfileData.fromJson(json['data'])
          : null,
    );
  }
}

class PatientProfileData {
  final PatientUser? user;
  final ActiveSubscription? activeSubscription;

  PatientProfileData({this.user, this.activeSubscription});

  factory PatientProfileData.fromJson(Map<String, dynamic> json) {
    return PatientProfileData(
      user: json['user'] != null ? PatientUser.fromJson(json['user']) : null,
      activeSubscription: json['activeSubscription'] != null
          ? ActiveSubscription.fromJson(json['activeSubscription'])
          : null,
    );
  }
}

class PatientUser {
  final String? fullName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? country;
  final String? city;
  final String? address;
  final String? profileImage;
  final String? phoneNumber;
  final String? status;
  final String? role;
  final bool? profileCompleted;
  final bool? platformSubscriptionActive;
  final num? wallet;
  final String? email;
  final String? referralCode;
  final int? totalReferrals;
  final num? totalEarnings;
  final num? currentEarnings;
  final Patient? patient;
  final List<dynamic>? patientInsurances;

  PatientUser({
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
    this.profileCompleted,
    this.platformSubscriptionActive,
    this.wallet,
    this.email,
    this.referralCode,
    this.totalReferrals,
    this.totalEarnings,
    this.currentEarnings,
    this.patient,
    this.patientInsurances,
  });

  factory PatientUser.fromJson(Map<String, dynamic> json) {
    return PatientUser(
      fullName: json['fullName'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      country: json['country'],
      city: json['city'],
      address: json['address'],
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
      status: json['status'],
      role: json['role'],
      profileCompleted: json['profileCompleted'],
      platformSubscriptionActive: json['platformSubscriptionActive'],
      wallet: json['wallet'] as num?,
      email: json['email'],
      referralCode: json['referralCode'],
      totalReferrals: json['totalReferrals'] as int?,
      totalEarnings: json['totalEarnings'] as num?,
      currentEarnings: json['currentEarnings'] as num?,
      patient: json['patient'] != null
          ? Patient.fromJson(json['patient'])
          : null,
      patientInsurances: json['patientInsurances'] != null
          ? (json['patientInsurances'] as List).map((i) => i).toList()
          : null,
    );
  }
}

class Patient {
  final double? latitude;
  final double? longitude;

  Patient({this.latitude, this.longitude});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class PatientInsurance {
  final String? id;
  final String? insuranceDetails;
  final String? image;

  PatientInsurance({this.id, this.insuranceDetails, this.image});

  factory PatientInsurance.fromJson(Map<String, dynamic> json) {
    return PatientInsurance(
      id: json['id'],
      insuranceDetails: json['insuranceDetails'],
      image: json['image'],
    );
  }
}

class ActiveSubscription {
  String? id;
  String? userId;
  num? amount;
  String? card;
  num? usdAmount;
  bool? active;
  String? subscriptionId;
  DateTime? createdAt;
  DateTime? updatedAt;

  ActiveSubscription({
    this.id,
    this.userId,
    this.amount,
    this.card,
    this.usdAmount,
    this.active,
    this.subscriptionId,
    this.createdAt,
    this.updatedAt,
  });

  ActiveSubscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    amount = json['amount'];
    card = json['card'];
    usdAmount = json['usdAmount'];
    active = json['active'];
    subscriptionId = json['subscriptionId'];
    createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'])
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['amount'] = amount;
    data['card'] = card;
    data['usdAmount'] = usdAmount;
    data['active'] = active;
    data['subscriptionId'] = subscriptionId;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }
}
