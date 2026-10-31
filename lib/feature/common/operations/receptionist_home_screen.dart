import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/auth/login/view/login_screen.dart';
import 'operations_menu.dart';
import 'phase_one_api.dart';

class ReceptionistHomeScreen extends StatelessWidget {
  const ReceptionistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(phaseText('Receptionist', 'موظف الاستقبال'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          phaseText(
            'Manage appointments for your assigned clinic.',
            'إدارة المواعيد في العيادة المخصصة لك.',
          ),
        ),
        const OperationsMenu(),
        TextButton(
          onPressed: () async {
            await SharedPrefHelper.removeAccessToken();
            await SharedPrefHelper.removeRefreshToken();
            await SharedPrefHelper.removeUserRole();
            Get.deleteAll(force: true);
            Get.offAll(() => LoginScreen());
          },
          child: Text(phaseText('Log out', 'تسجيل الخروج')),
        ),
      ],
    ),
  );
}
