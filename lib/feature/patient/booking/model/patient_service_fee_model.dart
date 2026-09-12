class PatientServiceFeeModel {
  String? id;
  double? amount;
  String? country;
  String? createdAt;
  String? updatedAt;

  PatientServiceFeeModel({
    this.id,
    this.amount,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  PatientServiceFeeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = (json['amount'] is int)
        ? (json['amount'] as int).toDouble()
        : json['amount'];
    country = json['country'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['country'] = country;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
