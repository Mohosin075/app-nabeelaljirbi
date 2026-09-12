enum TransactionType { consultation, withdraw, referral }

class TransactionModel {
  final TransactionType type;
  final String title;
  final String subtitle;
  final double amount;
  final bool isPositive;
  final String dateTime;

  TransactionModel({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isPositive,
    required this.dateTime,
  });
}
