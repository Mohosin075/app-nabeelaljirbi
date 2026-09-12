class SpecialistResponse {
  bool? success;
  String? message;
  SpecialistMeta? meta;
  List<SpecialistModel>? data;

  SpecialistResponse({this.success, this.message, this.meta, this.data});

  SpecialistResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    meta = json['meta'] != null ? SpecialistMeta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <SpecialistModel>[];
      json['data'].forEach((v) {
        data!.add(SpecialistModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SpecialistMeta {
  int? page;
  int? limit;
  int? total;

  SpecialistMeta({this.page, this.limit, this.total});

  SpecialistMeta.fromJson(Map<String, dynamic> json) {
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

class SpecialistModel {
  String? id;
  String? name;
  String? image;
  String? createdAt;
  String? updatedAt;

  SpecialistModel({
    this.id,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  SpecialistModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
