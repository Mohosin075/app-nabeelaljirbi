class DoctorDetailsModel {
  bool? success;
  String? message;
  DoctorDetailData? data;

  DoctorDetailsModel({this.success, this.message, this.data});

  DoctorDetailsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? DoctorDetailData.fromJson(json['data'])
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

class DoctorDetailData {
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
  String? clinicCountry;
  List<ClinicPhoto>? clinicPhoto;
  num? rating;
  int? reviewCount;
  List<ScheduleDay>? schedule;
  String? about;
  String? biography;
  String? clinicId;
  String? doctorId;

  DoctorDetailData({
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
    this.clinicCountry,
    this.clinicPhoto,
    this.rating,
    this.reviewCount,
    this.schedule,
    this.about,
    this.biography,
    this.clinicId,
    this.doctorId,
  });

  DoctorDetailData.fromJson(Map<String, dynamic> json) {
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
    clinicCountry = json['clinicCountry'];
    if (json['clinicPhoto'] != null) {
      clinicPhoto = <ClinicPhoto>[];
      json['clinicPhoto'].forEach((v) {
        clinicPhoto!.add(ClinicPhoto.fromJson(v));
      });
    }
    rating = json['rating'];
    reviewCount = json['reviewCount'];
    if (json['schedule'] != null) {
      schedule = <ScheduleDay>[];
      json['schedule'].forEach((v) {
        schedule!.add(ScheduleDay.fromJson(v));
      });
    }
    about = json['about'];
    biography = json['biography'];
    clinicId = json['clinicId'];
    doctorId = json['doctorId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['country'] = country;
    data['city'] = city;
    data['specialty'] = specialty;
    data['experience'] = experience;
    data['consultFee'] = consultFee;
    data['profileImage'] = profileImage;
    data['clinicName'] = clinicName;
    data['clinicLogo'] = clinicLogo;
    data['clinicCountry'] = clinicCountry;
    if (clinicPhoto != null) {
      data['clinicPhoto'] = clinicPhoto!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;
    data['reviewCount'] = reviewCount;
    if (schedule != null) {
      data['schedule'] = schedule!.map((v) => v.toJson()).toList();
    }
    data['about'] = about;
    data['biography'] = biography;
    data['clinicId'] = clinicId;
    data['doctorId'] = doctorId;
    return data;
  }
}

class ClinicPhoto {
  String? image;

  ClinicPhoto({this.image});

  ClinicPhoto.fromJson(Map<String, dynamic> json) {
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    return data;
  }
}

class ScheduleDay {
  String? day;
  List<Slot>? slots;

  ScheduleDay({this.day, this.slots});

  ScheduleDay.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['slots'] != null) {
      slots = <Slot>[];
      json['slots'].forEach((v) {
        slots!.add(Slot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Slot {
  String? id;
  String? startTime;
  String? endTime;
  int? capacity;
  bool? isActive;

  Slot({this.id, this.startTime, this.endTime, this.capacity, this.isActive});

  Slot.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    capacity = json['capacity'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['capacity'] = capacity;
    data['isActive'] = isActive;
    return data;
  }
}
