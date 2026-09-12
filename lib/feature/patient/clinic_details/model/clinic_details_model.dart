class ClinicDetailsModel {
  bool? success;
  String? message;
  ClinicData? data;

  ClinicDetailsModel({this.success, this.message, this.data});

  ClinicDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ClinicData.fromJson(json['data']) : null;
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

class ClinicData {
  String? clinicId;
  String? clinicName;
  String? about;
  String? logo;
  String? phoneNumber;
  String? address;
  String? location;
  double? latitude;
  double? longitude;
  int? specialistCount;
  int? doctorCount;
  List<Insurances>? insurances;
  List<Galleries>? galleries;
  List<Specialists>? specialists;
  int? views;
  bool? platformSubscriptionActive;
  String? createdAt;

  ClinicData({
    this.clinicId,
    this.clinicName,
    this.about,
    this.logo,
    this.phoneNumber,
    this.address,
    this.location,
    this.latitude,
    this.longitude,
    this.specialistCount,
    this.doctorCount,
    this.insurances,
    this.galleries,
    this.specialists,
    this.views,
    this.platformSubscriptionActive,
    this.createdAt,
  });

  ClinicData.fromJson(Map<String, dynamic> json) {
    clinicId = json['clinicId'];
    clinicName = json['clinicName'];
    about = json['about'];
    logo = json['logo'];
    phoneNumber = json['phoneNumber'];
    address = json['address'];
    location = json['location'];
    // Handle double conversion safely
    latitude = (json['latitude'] is int)
        ? (json['latitude'] as int).toDouble()
        : json['latitude'];
    longitude = (json['longitude'] is int)
        ? (json['longitude'] as int).toDouble()
        : json['longitude'];
    specialistCount = json['specialistCount'];
    doctorCount = json['doctorCount'];
    if (json['insurances'] != null) {
      insurances = <Insurances>[];
      json['insurances'].forEach((v) {
        insurances!.add(Insurances.fromJson(v));
      });
    }
    if (json['galleries'] != null) {
      galleries = <Galleries>[];
      json['galleries'].forEach((v) {
        galleries!.add(Galleries.fromJson(v));
      });
    }
    if (json['specialists'] != null) {
      specialists = <Specialists>[];
      json['specialists'].forEach((v) {
        specialists!.add(Specialists.fromJson(v));
      });
    }
    views = json['views'];
    platformSubscriptionActive = json['platformSubscriptionActive'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['clinicId'] = clinicId;
    data['clinicName'] = clinicName;
    data['about'] = about;
    data['logo'] = logo;
    data['phoneNumber'] = phoneNumber;
    data['address'] = address;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['specialistCount'] = specialistCount;
    data['doctorCount'] = doctorCount;
    if (insurances != null) {
      data['insurances'] = insurances!.map((v) => v.toJson()).toList();
    }
    if (galleries != null) {
      data['galleries'] = galleries!.map((v) => v.toJson()).toList();
    }
    if (specialists != null) {
      data['specialists'] = specialists!.map((v) => v.toJson()).toList();
    }
    data['views'] = views;
    data['platformSubscriptionActive'] = platformSubscriptionActive;
    data['createdAt'] = createdAt;
    return data;
  }
}

class Insurances {
  String? id;
  String? image;
  String? insuranceDetails;
  String? clinicId;
  String? insuranceId;
  String? createdAt;
  String? updatedAt;

  Insurances({
    this.id,
    this.image,
    this.insuranceDetails,
    this.clinicId,
    this.insuranceId,
    this.createdAt,
    this.updatedAt,
  });

  Insurances.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['insurance'] != null) {
      image = json['insurance']['image'];
      insuranceDetails = json['insurance']['name'];
    } else {
      image = json['image'];
      insuranceDetails = json['insuranceDetails'];
    }
    clinicId = json['clinicId'];
    insuranceId = json['insuranceId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['insuranceDetails'] = insuranceDetails;
    data['clinicId'] = clinicId;
    data['insuranceId'] = insuranceId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Galleries {
  String? id;
  String? image;
  String? clinicId;
  String? createdAt;
  String? updatedAt;

  Galleries({
    this.id,
    this.image,
    this.clinicId,
    this.createdAt,
    this.updatedAt,
  });

  Galleries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    clinicId = json['clinicId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['clinicId'] = clinicId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Specialists {
  String? id;
  String? image;
  String? specialistDetails;

  Specialists({this.id, this.image, this.specialistDetails});

  Specialists.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['specialist'] != null) {
      image = json['specialist']['image'];
      specialistDetails = json['specialist']['name'];
    } else {
      image = json['image'];
      specialistDetails = json['specialistDetails'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['specialistDetails'] = specialistDetails;
    return data;
  }
}

class ClinicDoctorsModel {
  bool? success;
  String? message;
  ClinicDoctorsData? data;

  ClinicDoctorsModel({this.success, this.message, this.data});

  ClinicDoctorsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? ClinicDoctorsData.fromJson(json['data'])
        : null;
  }
}

class ClinicDoctorsData {
  List<ClinicDoctor>? data;

  ClinicDoctorsData({this.data});

  ClinicDoctorsData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ClinicDoctor>[];
      json['data'].forEach((v) {
        data!.add(ClinicDoctor.fromJson(v));
      });
    }
  }
}

class ClinicDoctor {
  String? id;
  String? name;
  String? country;
  String? city;
  String? specialty;
  String? experience;
  int? consultFee;
  String? profileImage;
  String? clinicName;
  String? clinicLogo;
  num? rating;
  int? reviewCount;
  String? clinicId;
  String? doctorId;

  ClinicDoctor({
    this.id,
    this.name,
    this.country,
    this.city,
    this.specialty,
    this.experience,
    this.consultFee,
    this.profileImage,
    this.clinicName,
    this.clinicLogo,
    this.rating,
    this.reviewCount,
    this.clinicId,
    this.doctorId,
  });

  ClinicDoctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    country = json['country'];
    city = json['city'];
    specialty = json['specialty'];
    experience = json['experience'];
    consultFee = json['consultFee'];
    profileImage = json['profileImage'];
    clinicName = json['clinicName'];
    clinicLogo = json['clinicLogo'];
    rating = json['rating'];
    reviewCount = json['reviewCount'];
    clinicId = json['clinicId'];
    doctorId = json['doctorId'];
  }
}
