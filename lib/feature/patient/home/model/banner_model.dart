class BannerModel {
  bool? success;
  String? message;
  List<BannerData>? data;

  BannerModel({this.success, this.message, this.data});

  BannerModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BannerData>[];
      json['data'].forEach((v) {
        data!.add(BannerData.fromJson(v));
      });
    }
  }
}

class BannerData {
  String? id;
  String? image;
  String? createdAt;
  String? updatedAt;

  BannerData({this.id, this.image, this.createdAt, this.updatedAt});

  BannerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }
}
