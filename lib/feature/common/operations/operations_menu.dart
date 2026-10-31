import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'phase_one_api.dart';
import 'profile_changes_screen.dart';
import 'payout_screen.dart';
import 'history_reports_screen.dart';
import 'managed_bookings_screen.dart';
import 'receptionists_screen.dart';

class OperationsMenu extends StatelessWidget {
  const OperationsMenu({super.key});
  @override
  Widget build(BuildContext context) {
    final role = SharedPrefHelper.getUserRole();
    return Card(
      child: Column(
        children: [
          if (['PATIENT', 'DOCTOR', 'CLINIC'].contains(role))
            ListTile(
              title: Text(
                phaseText('Profile change requests', 'طلبات تعديل الملف'),
              ),
              onTap: () => Get.to(() => const ProfileChangesScreen()),
            ),
          if (['DOCTOR', 'CLINIC'].contains(role))
            ListTile(
              title: Text(
                phaseText('Bank details & withdrawals', 'بيانات البنك والسحب'),
              ),
              onTap: () => Get.to(() => const PayoutScreen()),
            ),
          if (['PATIENT', 'DOCTOR', 'CLINIC'].contains(role))
            ListTile(
              title: Text(phaseText('Ledger & reports', 'السجل والتقارير')),
              onTap: () => Get.to(() => const HistoryReportsScreen()),
            ),
          if (role == 'PATIENT')
            ListTile(
              title: Text(
                phaseText('My complaints & responses', 'شكاواي والردود'),
              ),
              onTap: () =>
                  Get.to(() => const HistoryReportsScreen(complaints: true)),
            ),
          if (['CLINIC', 'MANAGER'].contains(role))
            ListTile(
              title: Text(phaseText('Manage bookings', 'إدارة الحجوزات')),
              onTap: () => Get.to(() => const ManagedBookingsScreen()),
            ),
          if (role == 'CLINIC')
            ListTile(
              title: Text(phaseText('Receptionists', 'موظفو الاستقبال')),
              onTap: () => Get.to(() => const ReceptionistsScreen()),
            ),
        ],
      ),
    );
  }
}
