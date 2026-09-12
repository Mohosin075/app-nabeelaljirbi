class DoctorTransactionModel {
  final String id;
  final String title;
  final String transactionId;
  final String date;
  final String amount;
  final bool isCredit;
  final String type; // 'consultation', 'withdraw', 'referral'

  DoctorTransactionModel({
    required this.id,
    required this.title,
    required this.transactionId,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.type,
  });
}
