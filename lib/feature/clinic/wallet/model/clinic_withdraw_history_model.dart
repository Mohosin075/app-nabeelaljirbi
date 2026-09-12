class ClinicWithdrawHistoryModel {
  final bool success;
  final String message;
  final ClinicWithdrawHistoryData? data;

  ClinicWithdrawHistoryModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ClinicWithdrawHistoryModel.fromJson(Map<String, dynamic> json) {
    return ClinicWithdrawHistoryModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ClinicWithdrawHistoryData.fromJson(json['data'])
          : null,
    );
  }
}

class ClinicWithdrawHistoryData {
  final Meta? meta;
  final List<ClinicWithdrawItem>? data;

  ClinicWithdrawHistoryData({this.meta, this.data});

  factory ClinicWithdrawHistoryData.fromJson(Map<String, dynamic> json) {
    return ClinicWithdrawHistoryData(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      data: json['data'] != null
          ? (json['data'] as List)
                .map((item) => ClinicWithdrawItem.fromJson(item))
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

class ClinicWithdrawItem {
  final String id;
  final String userId;
  final double amount;
  final String createdAt;
  final String updatedAt;

  ClinicWithdrawItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClinicWithdrawItem.fromJson(Map<String, dynamic> json) {
    return ClinicWithdrawItem(
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
