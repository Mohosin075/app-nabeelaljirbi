import 'package:flutter/material.dart';
import 'phase_one_api.dart';
import 'public_details_screen.dart';

class ApprovedProfileGate extends StatefulWidget {
  final WidgetBuilder builder;
  final Future<dynamic> Function()? accessLoader;
  const ApprovedProfileGate({
    super.key,
    required this.builder,
    this.accessLoader,
  });
  @override
  State<ApprovedProfileGate> createState() => _ApprovedProfileGateState();
}

class _ApprovedProfileGateState extends State<ApprovedProfileGate> {
  late Future<dynamic> access;
  @override
  void initState() {
    super.initState();
    access = widget.accessLoader?.call() ?? PhaseOneApi.call('profile-access');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<dynamic>(
    future: access,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(title: Text(phaseText('Profile', 'الملف الشخصي'))),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${snapshot.error}'),
                  TextButton(
                    onPressed: () => setState(() {
                      access =
                          widget.accessLoader?.call() ??
                          PhaseOneApi.call('profile-access');
                    }),
                    child: Text(phaseText('Retry', 'إعادة المحاولة')),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.data['locked'] == true) return const ProfileChangesScreen();
      return widget.builder(context);
    },
  );
}

class ProfileChangesScreen extends StatefulWidget {
  const ProfileChangesScreen({super.key});
  @override
  State<ProfileChangesScreen> createState() => _ProfileChangesScreenState();
}

class _ProfileChangesScreenState extends State<ProfileChangesScreen> {
  final fields = <String, TextEditingController>{};
  final reason = TextEditingController();
  Map<String, dynamic>? access;
  List<dynamic> requests = [];
  bool busy = false;
  String? error, message;
  int page = 1, total = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    reason.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final values = await PhaseOneApi.call('profile-access');
      final history = await PhaseOneApi.call(
        'profile-changes',
        query: {'page': page, 'limit': 20},
      );
      if (!mounted) return;
      access = Map<String, dynamic>.from(values);
      for (final key in access!['fields']) {
        fields.putIfAbsent(
          key,
          () => TextEditingController(text: '${access!['values'][key] ?? ''}'),
        );
      }
      requests = history['data'];
      total = history['meta']['total'];
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

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
      message = null;
    });
    try {
      final changes = <String, dynamic>{
        for (final e in fields.entries)
          if (e.value.text.trim() != '${access!['values'][e.key] ?? ''}')
            e.key: e.value.text.trim(),
      };
      await PhaseOneApi.call(
        'profile-changes',
        method: 'POST',
        body: {'changes': changes, 'reason': reason.text.trim()},
      );
      if (!mounted) return;
      message = phaseText(
        'Request submitted for Main Admin review.',
        'تم إرسال الطلب لمراجعة الإدارة.',
      );
      reason.clear();
      await load();
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(phaseText('Profile Change Requests', 'طلبات تعديل الملف')),
    ),
    body: RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            phaseText(
              'Approved core information requires Main Admin review before it changes.',
              'يتطلب تعديل البيانات الأساسية المعتمدة مراجعة الإدارة.',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
          if (message != null)
            Text(message!, style: const TextStyle(color: Colors.green)),
          if (busy) const LinearProgressIndicator(),
          if (access != null)
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final info = access!['publicInfo'] as Map?;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicDetailsScreen(
                            role: access!['role'],
                            initialAbout: info?['about'],
                            initialImage: info?['image'],
                          ),
                        ),
                      );
                      if (mounted) await load();
                    },
              child: Text(
                phaseText(
                  'Edit photo & public details',
                  'تعديل الصورة والبيانات العامة',
                ),
              ),
            ),
          for (final e in fields.entries)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: e.value,
                enabled: !busy,
                decoration: InputDecoration(
                  labelText: phaseFieldLabel(e.key),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: reason,
            enabled: !busy,
            maxLength: 2000,
            decoration: InputDecoration(
              labelText: phaseText('Reason', 'السبب'),
              border: const OutlineInputBorder(),
            ),
          ),
          FilledButton(
            onPressed: busy || access == null ? null : submit,
            child: Text(phaseText('Submit for review', 'إرسال للمراجعة')),
          ),
          const SizedBox(height: 24),
          Text(
            phaseText('Request history', 'سجل الطلبات'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final r in requests)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r['status']} · ${r['createdAt'].toString().substring(0, 10)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${r['reason'] ?? ''}'),
                    for (final e in (r['changes']['values'] as Map).entries)
                      Text(
                        '${phaseFieldLabel(e.key)}: ${r['changes']['before'][e.key] ?? '—'} → ${e.value ?? '—'}',
                      ),
                    if (r['adminResponse'] != null)
                      Text(
                        '${phaseText('Response', 'الرد')}: ${r['adminResponse']}',
                      ),
                  ],
                ),
              ),
            ),
          if (!busy && requests.isEmpty)
            Text(phaseText('No requests yet.', 'لا توجد طلبات بعد.')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: busy || page <= 1
                    ? null
                    : () {
                        page--;
                        load();
                      },
                child: Text(phaseText('Previous', 'السابق')),
              ),
              Text('$page'),
              TextButton(
                onPressed: busy || page * 20 >= total
                    ? null
                    : () {
                        page++;
                        load();
                      },
                child: Text(phaseText('Next', 'التالي')),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
