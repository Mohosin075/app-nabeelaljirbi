class PlatformSubscriptionResponse {
  final bool? success;
  final String? message;
  final PlatformSubscription? data;

  PlatformSubscriptionResponse({this.success, this.message, this.data});

  factory PlatformSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return PlatformSubscriptionResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? PlatformSubscription.fromJson(json['data'])
          : null,
    );
  }
}

class PlatformSubscription {
  final String? id;
  final num? amount;
  final num? usdAmount;
  final String? card;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PlatformSubscription({
    this.id,
    this.amount,
    this.usdAmount,
    this.card,
    this.country,
    this.createdAt,
    this.updatedAt,
  });

  factory PlatformSubscription.fromJson(Map<String, dynamic> json) {
    return PlatformSubscription(
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
