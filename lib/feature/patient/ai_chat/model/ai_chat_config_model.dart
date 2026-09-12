class AiChatConfig {
  String? id;
  int? limit;
  bool? isEnable;

  AiChatConfig({this.id, this.limit, this.isEnable});

  AiChatConfig.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    limit = json['limit'];
    isEnable = json['isEnable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['limit'] = limit;
    data['isEnable'] = isEnable;
    return data;
  }
}
