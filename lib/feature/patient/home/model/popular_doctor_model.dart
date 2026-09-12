class PopularDoctorModel {
  bool? success;
  String? message;
  PopularDoctorData? data;

  PopularDoctorModel({this.success, this.message, this.data});

  PopularDoctorModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? PopularDoctorData.fromJson(json['data'])
        : null;
  }
}

class PopularDoctorData {
  Meta? meta;
  List<Doctor>? doctors;

  PopularDoctorData({this.meta, this.doctors});

  PopularDoctorData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      doctors = <Doctor>[];
      json['data'].forEach((v) {
        doctors!.add(Doctor.fromJson(v));
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

class Doctor {
  String? id;
  String? doctorId;
  String? name;
  String? country;
  String? city;
  String? specialty;
  String? experience;
  int? fee;
  String? profileImage;
  num? rating;
  int? reviewCount;
  num? weightedScore;
  num? avgRating;

  Doctor({
    this.id,
    this.doctorId,
    this.name,
    this.country,
    this.city,
    this.specialty,
    this.experience,
    this.fee,
    this.profileImage,
    this.rating,
    this.reviewCount,
    this.weightedScore,
    this.avgRating,
  });

  Doctor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctorId'];
    name = json['name'];
    country = json['country'];
    city = json['city'];
    specialty = json['specialty'];
    experience = json['experience'];
    fee = json['fee'];
    profileImage = json['profileImage'];
    rating = json['rating'];
    reviewCount = json['reviewCount'];
    weightedScore = json['weightedScore'];
    avgRating = json['avgRating'];
  }
}
