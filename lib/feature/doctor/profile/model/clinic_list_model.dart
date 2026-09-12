class ClinicListModel {
  bool? success;
  String? message;
  ClinicListData? data;

  ClinicListModel({this.success, this.message, this.data});

  ClinicListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ClinicListData.fromJson(json['data']) : null;
  }
}

class ClinicListData {
  Meta? meta;
  List<ClinicItem>? clinics;

  ClinicListData({this.meta, this.clinics});

  ClinicListData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      clinics = <ClinicItem>[];
      json['data'].forEach((v) {
        clinics!.add(ClinicItem.fromJson(v));
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

class ClinicItem {
  String? id;
  String? logo;
  String? clinicName;
  bool? adminVerified;
  int? numberOfClinicSpecialist;
  String? createdAt;
  String? contact;

  ClinicItem({
    this.id,
    this.logo,
    this.clinicName,
    this.adminVerified,
    this.numberOfClinicSpecialist,
    this.createdAt,
    this.contact,
  });

  ClinicItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    logo = json['logo'];
    clinicName = json['clinicName'];
    adminVerified = json['adminVerified'];
    numberOfClinicSpecialist = json['numberOfClinicSpecialist'];
    createdAt = json['createdAt'];
    contact = json['contact'];
  }
}
