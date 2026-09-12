class OtpSystemModel {
  bool? success;
  String? message;
  List<OtpSystemData>? data;

  OtpSystemModel({this.success, this.message, this.data});

  OtpSystemModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <OtpSystemData>[];
      json['data'].forEach((v) {
        data!.add(OtpSystemData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OtpSystemData {
  String? id;
  bool? sMS;
  bool? whatsApp;
  String? createdAt;
  String? updatedAt;

  OtpSystemData({
    this.id,
    this.sMS,
    this.whatsApp,
    this.createdAt,
    this.updatedAt,
  });

  OtpSystemData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sMS = json['SMS'];
    whatsApp = json['WhatsApp'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['SMS'] = sMS;
    data['WhatsApp'] = whatsApp;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
