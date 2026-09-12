class ClinicSubscriptionResponse {
  final bool? success;
  final String? message;
  final ClinicSubscription? data;

  ClinicSubscriptionResponse({this.success, this.message, this.data});

  factory ClinicSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return ClinicSubscriptionResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? ClinicSubscription.fromJson(json['data'])
          : null,
    );
  }
}

class ClinicSubscription {
  final String? id;
  final num? amount;
  final num? usdAmount;
  final String? card;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClinicSubscription({
    this.id,
    this.amount,
    this.usdAmount,
    this.card,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  factory ClinicSubscription.fromJson(Map<String, dynamic> json) {
    return ClinicSubscription(
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
