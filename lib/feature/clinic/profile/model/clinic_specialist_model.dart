class ClinicSpecialistResponse {
  bool? success;
  String? message;
  ClinicSpecialistData? data;

  ClinicSpecialistResponse({this.success, this.message, this.data});

  ClinicSpecialistResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? ClinicSpecialistData.fromJson(json['data'])
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

class ClinicSpecialistData {
  ClinicSpecialistMeta? meta;
  List<ClinicSpecialistItem>? data;

  ClinicSpecialistData({this.meta, this.data});

  ClinicSpecialistData.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null
        ? ClinicSpecialistMeta.fromJson(json['meta'])
        : null;
    if (json['data'] != null) {
      data = <ClinicSpecialistItem>[];
      json['data'].forEach((v) {
        data!.add(ClinicSpecialistItem.fromJson(v));
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

class ClinicSpecialistMeta {
  int? page;
  int? limit;
  int? total;

  ClinicSpecialistMeta({this.page, this.limit, this.total});

  ClinicSpecialistMeta.fromJson(Map<String, dynamic> json) {
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

class ClinicSpecialistItem {
  String? id;
  SpecialistRole? specialist;

  ClinicSpecialistItem({this.id, this.specialist});

  ClinicSpecialistItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    specialist = json['specialist'] != null
        ? SpecialistRole.fromJson(json['specialist'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (specialist != null) {
      data['specialist'] = specialist!.toJson();
    }
    return data;
  }
}

class SpecialistRole {
  String? name;
  String? image;

  SpecialistRole({this.name, this.image});

  SpecialistRole.fromJson(Map<String, dynamic> json) {
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
