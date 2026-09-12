class WithdrawHistoryModel {
  final bool success;
  final String message;
  final WithdrawHistoryData? data;

  WithdrawHistoryModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory WithdrawHistoryModel.fromJson(Map<String, dynamic> json) {
    return WithdrawHistoryModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? WithdrawHistoryData.fromJson(json['data'])
          : null,
    );
  }
}

class WithdrawHistoryData {
  final Meta? meta;
  final List<WithdrawItem>? data;

  WithdrawHistoryData({this.meta, this.data});

  factory WithdrawHistoryData.fromJson(Map<String, dynamic> json) {
    return WithdrawHistoryData(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? (json['data'] as List)
                .map((item) => WithdrawItem.fromJson(item))
                .toList()
          : null,
    );
  }
}

class Meta {
  final int page;
  final int limit;
  final int total;

  Meta({required this.page, required this.limit, required this.total});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}

class WithdrawItem {
  final String id;
  final String userId;
  final double amount;
  final String createdAt;
  final String updatedAt;

  WithdrawItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WithdrawItem.fromJson(Map<String, dynamic> json) {
    return WithdrawItem(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] ?? 0.0),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
