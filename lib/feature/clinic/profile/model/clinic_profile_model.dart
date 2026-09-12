class ClinicProfileModel {
  bool? success;
  String? message;
  ClinicProfileData? data;

  ClinicProfileModel({this.success, this.message, this.data});

  ClinicProfileModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? ClinicProfileData.fromJson(json['data'])
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

class ClinicProfileData {
  String? id;
  String? country;
  String? city;
  String? address;
  String? phoneNumber;
  String? email;
  num? wallet;
  String? referralCode;
  int? totalReferrals;
  num? totalEarnings;
  num? currentEarnings;
  bool? platformSubscriptionActive;
  num? serviceFree;
  Clinic? clinic;
  ActiveSubscription? activeSubscription;

  ClinicProfileData({
    this.id,
    this.country,
    this.city,
    this.address,
    this.phoneNumber,
    this.email,
    this.wallet,
    this.referralCode,
    this.totalReferrals,
    this.totalEarnings,
    this.currentEarnings,
    this.platformSubscriptionActive,
    this.serviceFree,
    this.clinic,
    this.activeSubscription,
  });

  ClinicProfileData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    country = json['country'];
    city = json['city'];
    address = json['address'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    wallet = json['wallet'];
    referralCode = json['referralCode'];
    totalReferrals = json['totalReferrals'];
    totalEarnings = json['totalEarnings'];
    currentEarnings = json['currentEarnings'];
    platformSubscriptionActive = json['platformSubscriptionActive'];
    serviceFree = json['serviceFree'];
    clinic = json['clinic'] != null ? Clinic.fromJson(json['clinic']) : null;
    activeSubscription = json['activeSubscription'] != null
        ? ActiveSubscription.fromJson(json['activeSubscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country'] = country;
    data['city'] = city;
    data['address'] = address;
    data['phoneNumber'] = phoneNumber;
    data['email'] = email;
    data['wallet'] = wallet;
    data['referralCode'] = referralCode;
    data['totalReferrals'] = totalReferrals;
    data['totalEarnings'] = totalEarnings;
    data['currentEarnings'] = currentEarnings;
    data['platformSubscriptionActive'] = platformSubscriptionActive;
    data['serviceFree'] = serviceFree;
    if (clinic != null) {
      data['clinic'] = clinic!.toJson();
    }
    if (activeSubscription != null) {
      data['activeSubscription'] = activeSubscription!.toJson();
    }
    return data;
  }
}

class Clinic {
  String? managerName;
  String? managerPhone;
  String? logo;
  String? clinicName;
  String? about;
  String? contactPhone;
  String? location;
  double? latitude;
  double? longitude;
  int? views;
  bool? adminVerified;
  num? averageRating;
  num? reviewCount;

  Clinic({
    this.managerName,
    this.managerPhone,
    this.logo,
    this.clinicName,
    this.about,
    this.contactPhone,
    this.location,
    this.latitude,
    this.longitude,
    this.views,
    this.adminVerified,
    this.averageRating,
    this.reviewCount,
  });

  Clinic.fromJson(Map<String, dynamic> json) {
    managerName = json['managerName'];
    managerPhone = json['managerPhone'];
    logo = json['logo'];
    clinicName = json['clinicName'];
    about = json['about'];
    contactPhone = json['contactPhone'];
    location = json['location'];
    latitude = json['latitude']?.toDouble();
    longitude = json['longitude']?.toDouble();
    views = json['views'];
    adminVerified = json['adminVerified'];
    averageRating = json['averageRating'];
    reviewCount = json['reviewCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['managerName'] = managerName;
    data['managerPhone'] = managerPhone;
    data['logo'] = logo;
    data['clinicName'] = clinicName;
    data['about'] = about;
    data['contactPhone'] = contactPhone;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['views'] = views;
    data['adminVerified'] = adminVerified;
    data['averageRating'] = averageRating;
    data['reviewCount'] = reviewCount;
    return data;
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
