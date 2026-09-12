class ClinicGalleryModel {
  bool? success;
  String? message;
  ClinicGalleryData? data;

  ClinicGalleryModel({this.success, this.message, this.data});

  ClinicGalleryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? ClinicGalleryData.fromJson(json['data'])
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

class ClinicGalleryData {
  GalleryMeta? meta;
  List<GalleryItem>? data;

  ClinicGalleryData({this.meta, this.data});

  ClinicGalleryData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? GalleryMeta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <GalleryItem>[];
      json['data'].forEach((v) {
        data!.add(GalleryItem.fromJson(v));
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

class GalleryMeta {
  int? page;
  int? limit;
  int? total;

  GalleryMeta({this.page, this.limit, this.total});

  GalleryMeta.fromJson(Map<String, dynamic> json) {
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

class GalleryItem {
  String? id;
  String? image;
  String? clinicId;
  String? createdAt;
  String? updatedAt;

  GalleryItem({
    this.id,
    this.image,
    this.clinicId,
    this.createdAt,
    this.updatedAt,
  });

  GalleryItem.fromJson(Map<String, dynamic> json) {
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
