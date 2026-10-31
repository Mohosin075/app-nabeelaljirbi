import 'package:flutter/material.dart';
import 'phase_one_api.dart';

class ReceptionistsScreen extends StatefulWidget {
  const ReceptionistsScreen({super.key});
  @override
  State<ReceptionistsScreen> createState() => _ReceptionistsScreenState();
}

class _ReceptionistsScreenState extends State<ReceptionistsScreen> {
  final form = {
    for (final key in ['fullName', 'phoneNumber', 'email', 'password'])
      key: TextEditingController(),
  };
  List<dynamic> staff = [];
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final c in form.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> run(Future<void> Function() operation) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await operation();
    } catch (e) {
      if (mounted) error = '$e';
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> load() => run(() async {
    final data = await PhaseOneApi.call('receptionists');
    if (mounted) staff = data;
  });
  Future<void> create() => run(() async {
    await PhaseOneApi.call(
      'receptionists',
      method: 'POST',
      body: {for (final e in form.entries) e.key: e.value.text.trim()},
    );
    if (!mounted) return;
    for (final c in form.values) {
      c.clear();
    }
    final data = await PhaseOneApi.call('receptionists');
    if (mounted) staff = data;
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(phaseText('Receptionists', 'موظفو الاستقبال'))),
    body: RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            phaseText(
              'Staff can manage this clinic’s bookings. They sign in to the dashboard with their email and password.',
              'يمكن للموظف إدارة حجوزات هذه العيادة والدخول للوحة التحكم بالبريد وكلمة المرور.',
            ),
          ),
          if (busy) const LinearProgressIndicator(),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          for (final e in form.entries)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: e.value,
                enabled: !busy,
                obscureText: e.key == 'password',
                autocorrect: false,
                keyboardType: e.key == 'phoneNumber'
                    ? TextInputType.phone
                    : e.key == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(
                  labelText: {
                    'fullName': phaseText('Full name', 'الاسم الكامل'),
                    'phoneNumber': phaseText('Phone number', 'رقم الهاتف'),
                    'email': phaseText('Email', 'البريد الإلكتروني'),
                    'password': phaseText(
                      'Password — at least 8 characters',
                      'كلمة المرور — 8 أحرف على الأقل',
                    ),
                  }[e.key],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: busy ? null : create,
            child: Text(phaseText('Add receptionist', 'إضافة موظف استقبال')),
          ),
          const SizedBox(height: 24),
          for (final s in staff)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s['user']['fullName']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${s['user']['email']}\n${s['user']['phoneNumber']} · ${s['user']['status']}',
                    ),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () async {
                              final yes = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    phaseText(
                                      'Change staff access?',
                                      'تغيير صلاحية الموظف؟',
                                    ),
                                  ),
                                  content: Text('${s['user']['fullName']}'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(phaseText('Cancel', 'إلغاء')),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        phaseText('Confirm', 'تأكيد'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (yes != true || !mounted) return;
                              await run(() async {
                                await PhaseOneApi.call(
                                  'receptionists/${s['user']['id']}',
                                  method: 'PATCH',
                                  body: {
                                    'status': s['user']['status'] == 'ACTIVE'
                                        ? 'SUSPENDED'
                                        : 'ACTIVE',
                                  },
                                );
                                final data = await PhaseOneApi.call(
                                  'receptionists',
                                );
                                if (mounted) staff = data;
                              });
                            },
                      child: Text(
                        s['user']['status'] == 'ACTIVE'
                            ? phaseText('Suspend access', 'تعليق الدخول')
                            : phaseText('Activate access', 'تفعيل الدخول'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
