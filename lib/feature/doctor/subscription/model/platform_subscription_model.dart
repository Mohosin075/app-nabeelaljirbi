class DoctorSubscriptionResponse {
  final bool? success;
  final String? message;
  final DoctorSubscription? data;

  DoctorSubscriptionResponse({this.success, this.message, this.data});

  factory DoctorSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return DoctorSubscriptionResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? DoctorSubscription.fromJson(json['data'])
          : null,
    );
  }
}

class DoctorSubscription {
  final String? id;
  final num? amount;
  final num? usdAmount;
  final String? card;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DoctorSubscription({
    this.id,
    this.amount,
    this.usdAmount,
    this.card,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  factory DoctorSubscription.fromJson(Map<String, dynamic> json) {
    return DoctorSubscription(
      id: json['id'],
      amount: json['amount'] as num?,
      usdAmount: json['usdAmount'] as num?,
      card: json['card'],
      country: json['country'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'usdAmount': usdAmount,
      'card': card,
      'country': country,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
