import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import '../model/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(_getIconPath(), width: 44, height: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.subtitle,
                  style: globalTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isPositive ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)} ${CurrencyUtil.getUserCurrencySymbol()}',
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: transaction.isPositive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconPath() {
    switch (transaction.type) {
      case TransactionType.consultation:
        return IconsPath.consultationFee;
      case TransactionType.withdraw:
        return IconsPath.withdrawTwo;
      case TransactionType.referral:
        return IconsPath.refarrelBonus;
    }
  }
}
