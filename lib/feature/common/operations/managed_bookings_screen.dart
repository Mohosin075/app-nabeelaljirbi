import 'package:flutter/material.dart';
import 'phase_one_api.dart';

class ManagedBookingsScreen extends StatefulWidget {
  const ManagedBookingsScreen({super.key});
  @override
  State<ManagedBookingsScreen> createState() => _ManagedBookingsScreenState();
}

class _ManagedBookingsScreenState extends State<ManagedBookingsScreen> {
  final search = TextEditingController(), reason = TextEditingController();
  final selected = <String>{};
  List<dynamic> rows = [], doctors = [];
  String status = 'ALL', sort = 'newest', doctorId = '', action = 'CONFIRMED';
  DateTime? date;
  int page = 1, total = 0, limit = 25;
  bool busy = false;
  String? error, message;
  @override
  void initState() {
    super.initState();
    load();
    options();
  }

  @override
  void dispose() {
    search.dispose();
    reason.dispose();
    super.dispose();
  }

  Future<void> options() async {
    try {
      final data = await PhaseOneApi.call('booking-options');
      if (mounted) {
        setState(() {
          doctors = data['doctors'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
        });
      }
    }
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = null;
      selected.clear();
    });
    try {
      final data = await PhaseOneApi.call(
        'bookings',
        query: {
          'page': page,
          'limit': limit,
          'status': status,
          'sort': sort,
          'doctorId': doctorId,
          'searchTerm': search.text.trim(),
          if (date != null) 'date': date!.toIso8601String().substring(0, 10),
        },
      );
      if (!mounted) return;
      rows = data['data'];
      total = data['meta']['total'];
    } catch (e) {
      if (mounted) {
        error = '$e';
        rows = [];
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> apply() async {
    if (['CANCELLED', 'DOCTOR_ABSENT', 'PATIENT_NO_SHOW'].contains(action) &&
        reason.text.trim().isEmpty) {
      setState(() {
        error = phaseText('Enter a reason first.', 'أدخل السبب أولاً.');
      });
      return;
    }
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          phaseText('Confirm selected action', 'تأكيد الإجراء المحدد'),
        ),
        content: Text(
          '$action · ${selected.length} ${phaseText('selected bookings', 'حجوزات محددة')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(phaseText('Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(phaseText('Apply', 'تطبيق')),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    setState(() {
      busy = true;
      error = null;
      message = null;
    });
    try {
      final result = await PhaseOneApi.call(
        'bookings/bulk',
        method: 'POST',
        body: {
          'ids': selected.toList(),
          'action': action,
          'reason': reason.text.trim(),
        },
      );
      if (!mounted) return;
      message =
          '${result['successCount']} ${phaseText('succeeded', 'نجح')} · ${result['failureCount']} ${phaseText('failed', 'فشل')}\n${(result['results'] as List).where((r) => r['message'] != null).map((r) => '${r['id']}: ${r['message']}').join('\n')}';
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
    appBar: AppBar(title: Text(phaseText('Manage Bookings', 'إدارة الحجوزات'))),
    body: RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: search,
            enabled: !busy,
            decoration: InputDecoration(
              labelText: phaseText(
                'Patient name or phone',
                'اسم المريض أو الهاتف',
              ),
              suffixIcon: IconButton(
                onPressed: busy
                    ? null
                    : () {
                        page = 1;
                        load();
                      },
                icon: const Icon(Icons.search),
              ),
            ),
            onSubmitted: (_) {
              page = 1;
              load();
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: doctorId,
            decoration: InputDecoration(
              labelText: phaseText('Doctor', 'الطبيب'),
            ),
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(phaseText('All doctors', 'جميع الأطباء')),
              ),
              for (final d in doctors)
                DropdownMenuItem(
                  value: '${d['id']}',
                  child: Text(
                    '${d['user']['fullName'] ?? d['user']['phoneNumber']}',
                  ),
                ),
            ],
            onChanged: busy
                ? null
                : (v) {
                    doctorId = v!;
                    page = 1;
                    load();
                  },
          ),
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: InputDecoration(
              labelText: phaseText('Status', 'الحالة'),
            ),
            items: [
              for (final s in [
                'ALL',
                'PENDING',
                'CONFIRMED',
                'ARRIVED',
                'INPROGRESS',
                'COMPLETE',
                'CANCELLED',
                'REJECTED',
                'PATIENT_NO_SHOW',
                'DOCTOR_ABSENT',
              ])
                DropdownMenuItem(value: s, child: Text(s)),
            ],
            onChanged: busy
                ? null
                : (v) {
                    status = v!;
                    page = 1;
                    load();
                  },
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: sort,
                  decoration: InputDecoration(
                    labelText: phaseText('Sort', 'الترتيب'),
                  ),
                  items: [
                    for (final s in ['requests', 'date', 'newest', 'serial'])
                      DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged: busy
                      ? null
                      : (v) {
                          sort = v!;
                          page = 1;
                          load();
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: limit,
                  decoration: InputDecoration(
                    labelText: phaseText('Rows', 'الصفوف'),
                  ),
                  items: [
                    for (final n in [25, 100, 500, 1000])
                      DropdownMenuItem(value: n, child: Text('$n')),
                  ],
                  onChanged: busy
                      ? null
                      : (v) {
                          limit = v!;
                          page = 1;
                          load();
                        },
                ),
              ),
            ],
          ),
          Wrap(
            children: [
              TextButton(
                onPressed: busy
                    ? null
                    : () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: date ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (d != null && mounted) {
                          date = d;
                          page = 1;
                          load();
                        }
                      },
                child: Text(
                  date?.toIso8601String().substring(0, 10) ??
                      phaseText('Choose date', 'اختر التاريخ'),
                ),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                        date = null;
                        page = 1;
                        load();
                      },
                child: Text(phaseText('Clear date', 'مسح التاريخ')),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    '${selected.length}/100 ${phaseText('manually selected', 'محدد يدوياً')}',
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: action,
                    decoration: InputDecoration(
                      labelText: phaseText('Action', 'الإجراء'),
                    ),
                    items: [
                      for (final s in [
                        'CONFIRMED',
                        'ARRIVED',
                        'COMPLETE',
                        'CANCELLED',
                        'DOCTOR_ABSENT',
                        'PATIENT_NO_SHOW',
                      ])
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                    onChanged: busy
                        ? null
                        : (v) => setState(() {
                            action = v!;
                          }),
                  ),
                  TextField(
                    controller: reason,
                    enabled: !busy,
                    decoration: InputDecoration(
                      labelText: phaseText(
                        'Reason for cancellation or absence',
                        'سبب الإلغاء أو الغياب',
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: busy || selected.isEmpty ? null : apply,
                    child: Text(
                      phaseText('Apply to selected', 'تطبيق على المحدد'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (busy) const LinearProgressIndicator(),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          if (message != null) Text(message!),
          Text('$total ${phaseText('bookings', 'حجز')}'),
          for (final r in rows)
            Card(
              child: CheckboxListTile(
                value: selected.contains(r['id']),
                onChanged:
                    busy ||
                        (selected.length >= 100 && !selected.contains(r['id']))
                    ? null
                    : (v) => setState(() {
                        if (v == true) {
                          selected.add(r['id']);
                        } else {
                          selected.remove(r['id']);
                        }
                      }),
                title: Text(
                  '${r['patient']['user']['fullName'] ?? ''} · #${r['serialNumber']}',
                ),
                subtitle: Text(
                  '${r['patient']['user']['phoneNumber']}\n${r['doctor']['user']['fullName']}\n${r['consultDate'].toString().substring(0, 10)} · ${r['displayStatus']}\n${r['clinic']['clinicName']}',
                ),
              ),
            ),
          if (!busy && rows.isEmpty)
            Text(phaseText('No matching bookings.', 'لا توجد حجوزات مطابقة.')),
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
                onPressed: busy || page * limit >= total
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
