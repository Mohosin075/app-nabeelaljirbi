class TopUpHistoryModel {
  bool? success;
  String? message;
  TopUpData? data;

  TopUpHistoryModel({this.success, this.message, this.data});

  TopUpHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? TopUpData.fromJson(json['data']) : null;
  }
}

class TopUpData {
  Meta? meta;
  List<TopUpItem>? data;

  TopUpData({this.meta, this.data});

  TopUpData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <TopUpItem>[];
      json['data'].forEach((v) {
        data!.add(TopUpItem.fromJson(v));
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

class TopUpItem {
  String? id;
  String? userId;
  int? amount;
  String? type;
  String? createdAt;
  String? updatedAt;
  AppointmentInfo? appointment;

  TopUpItem({
    this.id,
    this.userId,
    this.amount,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.appointment,
  });

  TopUpItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    amount = json['amount'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    appointment = json['appointment'] != null
        ? AppointmentInfo.fromJson(json['appointment'])
        : null;
  }
}

class AppointmentInfo {
  DoctorInfo? doctor;

  AppointmentInfo({this.doctor});

  AppointmentInfo.fromJson(Map<String, dynamic> json) {
    doctor = json['doctor'] != null
        ? DoctorInfo.fromJson(json['doctor'])
        : null;
  }
}

class DoctorInfo {
  String? speciality;
  UserInfo? user;

  DoctorInfo({this.speciality, this.user});

  DoctorInfo.fromJson(Map<String, dynamic> json) {
    speciality = json['speciality'];
    user = json['user'] != null ? UserInfo.fromJson(json['user']) : null;
  }
}

class UserInfo {
  String? fullName;

  UserInfo({this.fullName});

  UserInfo.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
  }
}
