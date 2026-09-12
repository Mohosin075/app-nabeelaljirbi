class ClinicInsuranceModel {
  bool? success;
  String? message;
  ClinicInsuranceData? data;

  ClinicInsuranceModel({this.success, this.message, this.data});

  ClinicInsuranceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? ClinicInsuranceData.fromJson(json['data'])
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

class ClinicInsuranceData {
  InsuranceMeta? meta;
  List<ClinicInsuranceItem>? data;

  ClinicInsuranceData({this.meta, this.data});

  ClinicInsuranceData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? InsuranceMeta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <ClinicInsuranceItem>[];
      json['data'].forEach((v) {
        data!.add(ClinicInsuranceItem.fromJson(v));
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

class InsuranceMeta {
  int? page;
  int? limit;
  int? total;

  InsuranceMeta({this.page, this.limit, this.total});

  InsuranceMeta.fromJson(Map<String, dynamic> json) {
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

class ClinicInsuranceItem {
  String? id;
  InsuranceInfo? insurance;
  String? createdAt;
  String? updatedAt;

  ClinicInsuranceItem({
    this.id,
    this.insurance,
    this.createdAt,
    this.updatedAt,
  });

  ClinicInsuranceItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    insurance = json['insurance'] != null
        ? InsuranceInfo.fromJson(json['insurance'])
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (insurance != null) {
      data['insurance'] = insurance!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class InsuranceInfo {
  String? name;
  String? image;

  InsuranceInfo({this.name, this.image});

  InsuranceInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
