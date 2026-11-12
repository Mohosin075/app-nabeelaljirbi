import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'phase_one_api.dart';
import 'profile_changes_screen.dart';
import 'payout_screen.dart';
import 'history_reports_screen.dart';
import 'managed_bookings_screen.dart';
import 'receptionists_screen.dart';

class OperationsMenu extends StatelessWidget {
  final bool financialOnly;
  final bool embedded;
  const OperationsMenu({super.key, this.financialOnly = false, this.embedded = false});
  @override
  Widget build(BuildContext context) {
    final role = SharedPrefHelper.getUserRole();
    final menu = Column(
        children: [
          if (!financialOnly && ['PATIENT', 'DOCTOR', 'CLINIC'].contains(role))
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: Text(
                phaseText('Profile change requests', 'طلبات تعديل الملف'),
              ),
              onTap: () => Get.to(() => const ProfileChangesScreen()),
            ),
          if (['DOCTOR', 'CLINIC'].contains(role))
            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: Text(
                phaseText('Bank details & withdrawals', 'بيانات البنك والسحب'),
              ),
              onTap: () => Get.to(() => const PayoutScreen()),
            ),
          if (['PATIENT', 'DOCTOR', 'CLINIC'].contains(role))
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(phaseText('Ledger & reports', 'السجل والتقارير')),
              onTap: () => Get.to(() => const HistoryReportsScreen()),
            ),
          if (!financialOnly && role == 'PATIENT')
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(
                phaseText('My complaints & responses', 'شكاواي والردود'),
              ),
              onTap: () =>
                  Get.to(() => const HistoryReportsScreen(complaints: true)),
            ),
          if (!financialOnly && ['CLINIC', 'MANAGER'].contains(role))
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text(phaseText('Manage bookings', 'إدارة الحجوزات')),
              onTap: () => Get.to(() => const ManagedBookingsScreen()),
            ),
          if (!financialOnly && role == 'CLINIC')
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(phaseText('Receptionists', 'موظفو الاستقبال')),
              onTap: () => Get.to(() => const ReceptionistsScreen()),
            ),
        ],
    );
    if (embedded) {
      return ListTileTheme.merge(
        contentPadding: EdgeInsets.zero,
        iconColor: const Color(0xff636F85),
        titleTextStyle: globalTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xff636F85),
        ),
        child: menu,
      );
    }
    return Card(child: menu);
  }
}
