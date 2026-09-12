class ClinicDoctorModel {
  bool? success;
  String? message;
  ClinicDoctorData? data;

  ClinicDoctorModel({this.success, this.message, this.data});

  ClinicDoctorModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? ClinicDoctorData.fromJson(json['data'])
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

class ClinicDoctorData {
  DoctorMeta? meta;
  List<ClinicDoctorItem>? data;

  ClinicDoctorData({this.meta, this.data});

  ClinicDoctorData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? DoctorMeta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <ClinicDoctorItem>[];
      json['data'].forEach((v) {
        data!.add(ClinicDoctorItem.fromJson(v));
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

class DoctorMeta {
  int? page;
  int? limit;
  int? total;

  DoctorMeta({this.page, this.limit, this.total});

  DoctorMeta.fromJson(Map<String, dynamic> json) {
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

class ClinicDoctorItem {
  String? id;
  String? doctorId;
  String? name;
  String? country;
  String? city;
  String? specialty;
  String? experience;
  num? fee;
  String? profileImage;
  String? clinic;
  num? rating;
  num? reviewCount;
  num? weightedRating;
  num? totalConsult;
  num? upcomingConsult;
  String? about;

  ClinicDoctorItem({
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
    this.rating,
    this.reviewCount,
    this.weightedRating,
    this.totalConsult,
    this.upcomingConsult,
    this.about,
  });

  ClinicDoctorItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctorId'];
    name = json['name'];
    country = json['country'];
    city = json['city'];
    specialty = json['specialty'];
    experience = json['experience'];
    fee = json['fee'];
    profileImage = json['profileImage'];
    clinic = json['clinic'];
    rating = json['rating'];
    reviewCount = json['reviewCount'];
    weightedRating = json['weightedRating'];
    totalConsult = json['totalConsult'];
    upcomingConsult = json['upcomingConsult'];
    about = json['about'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['doctorId'] = doctorId;
    data['name'] = name;
    data['country'] = country;
    data['city'] = city;
    data['specialty'] = specialty;
    data['experience'] = experience;
    data['fee'] = fee;
    data['profileImage'] = profileImage;
    data['clinic'] = clinic;
    data['rating'] = rating;
    data['reviewCount'] = reviewCount;
    data['weightedRating'] = weightedRating;
    data['totalConsult'] = totalConsult;
    data['upcomingConsult'] = upcomingConsult;
    data['about'] = about;
    return data;
  }
}
