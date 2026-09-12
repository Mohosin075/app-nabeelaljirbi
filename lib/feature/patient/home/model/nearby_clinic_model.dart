class NearbyClinicModel {
  bool? success;
  String? message;
  NearbyClinicData? data;

  NearbyClinicModel({this.success, this.message, this.data});

  NearbyClinicModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? NearbyClinicData.fromJson(json['data'])
        : null;
  }
}

class NearbyClinicData {
  Meta? meta;
  List<Clinic>? clinics;

  NearbyClinicData({this.meta, this.clinics});

  NearbyClinicData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      clinics = <Clinic>[];
      json['data'].forEach((v) {
        clinics!.add(Clinic.fromJson(v));
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

class Clinic {
  String? clinicUserId;
  String? clinicId;
  String? clinicName;
  String? logo;
  int? specialistCount;
  bool? platformSubscriptionActive;
  double? distance;

  String? country;
  String? city;

  Clinic({
    this.clinicUserId,
    this.clinicId,
    this.clinicName,
    this.logo,
    this.specialistCount,
    this.platformSubscriptionActive,
    this.distance,
    this.country,
    this.city,
  });

  Clinic.fromJson(Map<String, dynamic> json) {
    clinicUserId = json['clinicUserId'];
    clinicId = json['clinicId'];
    clinicName = json['clinicName'];
    logo = json['logo'];
    specialistCount = json['specialistCount'];
    platformSubscriptionActive = json['platformSubscriptionActive'];
    distance = (json['distance'] as num?)?.toDouble();
    country = json['country'];
    city = json['city'];
    if (json['specialties'] != null) {
      // Handle simple string list or list of objects with 'name'
      specialties = [];
      json['specialties'].forEach((v) {
        if (v is String) {
          specialties!.add(v);
        } else if (v is Map && v['name'] != null) {
          specialties!.add(v['name']);
        }
      });
    }
  }

  List<String>? specialties;
}
