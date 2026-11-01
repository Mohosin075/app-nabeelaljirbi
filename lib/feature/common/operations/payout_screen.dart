import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'phase_one_api.dart';
import 'report_share.dart';

class PayoutScreen extends StatefulWidget {
  const PayoutScreen({super.key});
  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  final bank = {
    for (final key in ['beneficiaryName', 'bankName', 'iban', 'accountNumber'])
      key: TextEditingController(),
  };
  final amount = TextEditingController();
  final search = TextEditingController();
  DateTime? start, end;
  List<dynamic> rows = [];
  bool busy = false, eligible = false;
  String eligibilityReason = 'Withdrawal is unavailable.';
  String method = 'BANK', status = 'ALL';
  String? error, message;
  int page = 1, total = 0, limit = 25;
  Map<String, dynamic> get query => {
    'page': page,
    'limit': limit,
    'status': status,
    'searchTerm': search.text.trim(),
    if (start != null) 'startDate': start!.toIso8601String().substring(0, 10),
    if (end != null) 'endDate': end!.toIso8601String().substring(0, 10),
  };

  Future<void> date(bool from) async {
    final result = await showDatePicker(
      context: context,
      initialDate: (from ? start : end) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result == null || !mounted) return;
    if (from) {
      start = result;
    } else {
      end = result;
    }
    page = 1;
    await load();
  }

  Future<void> download(String format) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await sharePhaseReport(context, 'payouts', format, query);
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

  @override
  void initState() {
    super.initState();
    load(profile: true);
  }

  @override
  void dispose() {
    for (final c in bank.values) {
      c.dispose();
    }
    amount.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> load({bool profile = false}) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (profile) {
        final data = await PhaseOneApi.call('payout-profile');
        if (!mounted) return;
        eligible = data['withdrawalEligible'] == true;
        eligibilityReason =
            data['withdrawalEligibilityReason']?.toString() ??
            'Withdrawal is unavailable.';
        for (final e in bank.entries) {
          e.value.text = '${data['bankDetails']?[e.key] ?? ''}';
        }
      }
      final history = await PhaseOneApi.call('payouts', query: query);
      if (!mounted) return;
      rows = history['data'];
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

  Future<void> saveBank() async {
    setState(() {
      busy = true;
      error = null;
      message = null;
    });
    try {
      await PhaseOneApi.call(
        'payout-profile',
        method: 'PUT',
        body: {for (final e in bank.entries) e.key: e.value.text.trim()},
      );
      if (mounted) {
        message = phaseText(
          'Bank details saved for future requests.',
          'تم حفظ بيانات البنك للطلبات القادمة.',
        );
      }
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

  Future<void> request() async {
    final value = double.tryParse(amount.text.trim());
    if (value == null || !value.isFinite || value <= 0) {
      setState(() {
        error = phaseText('Enter a valid amount.', 'أدخل مبلغاً صالحاً.');
      });
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(phaseText('Confirm withdrawal request', 'تأكيد طلب السحب')),
        content: Text(
          '$method · ${value.toStringAsFixed(2)}\n${phaseText('Payment requires admin approval.', 'يتطلب الدفع موافقة الإدارة.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(phaseText('Cancel', 'إلغاء')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(phaseText('Submit', 'إرسال')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      busy = true;
      error = null;
      message = null;
    });
    try {
      await PhaseOneApi.call(
        'payouts',
        method: 'POST',
        body: {'amount': value, 'payoutMethod': method},
      );
      if (!mounted) return;
      amount.clear();
      message = phaseText(
        'Withdrawal request submitted.',
        'تم إرسال طلب السحب.',
      );
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
      title: Text(
        phaseText('Bank Details & Withdrawals', 'بيانات البنك والسحب'),
      ),
    ),
    body: RefreshIndicator(
      onRefresh: () => load(profile: true),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (busy) const LinearProgressIndicator(),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          if (message != null)
            Text(message!, style: const TextStyle(color: Colors.green)),
          Text(
            phaseText('Saved bank details', 'بيانات البنك المحفوظة'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final e in bank.entries)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: e.value,
                enabled: !busy,
                maxLength: 160,
                decoration: InputDecoration(
                  labelText: {
                    'beneficiaryName': phaseText(
                      'Beneficiary name',
                      'اسم المستفيد',
                    ),
                    'bankName': phaseText('Bank name', 'اسم البنك'),
                    'iban': 'IBAN',
                    'accountNumber': phaseText('Account number', 'رقم الحساب'),
                  }[e.key],
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          FilledButton(
            onPressed: busy ? null : saveBank,
            child: Text(phaseText('Save bank details', 'حفظ بيانات البنك')),
          ),
          const SizedBox(height: 24),
          Text(
            phaseText('Request withdrawal', 'طلب السحب'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (!eligible) Text(eligibilityReason),
          const SizedBox(height: 12),
          TextField(
            controller: amount,
            enabled: !busy && eligible,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: phaseText('Amount', 'المبلغ'),
              border: const OutlineInputBorder(),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: method,
            decoration: InputDecoration(
              labelText: phaseText('Payout method', 'طريقة الدفع'),
            ),
            items: [
              DropdownMenuItem(
                value: 'BANK',
                child: Text(phaseText('Bank transfer', 'تحويل بنكي')),
              ),
              DropdownMenuItem(
                value: 'CASH',
                child: Text(phaseText('Cash', 'نقداً')),
              ),
            ],
            onChanged: busy
                ? null
                : (v) => setState(() {
                    method = v!;
                  }),
          ),
          FilledButton(
            onPressed: busy || !eligible ? null : request,
            child: Text(phaseText('Submit request', 'إرسال الطلب')),
          ),
          const SizedBox(height: 24),
          Text(
            phaseText('Withdrawal history', 'سجل السحب'),
            style: Theme.of(context).textTheme.titleLarge,
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
                'UNDER_REVIEW',
                'APPROVED',
                'COMPLETED',
                'REJECTED',
              ])
                DropdownMenuItem(
                  value: s,
                  child: Text(
                    s == 'COMPLETED' ? phaseText('PAID', 'مدفوع') : s,
                  ),
                ),
            ],
            onChanged: busy
                ? null
                : (v) {
                    status = v!;
                    page = 1;
                    load();
                  },
          ),
          TextField(
            controller: search,
            enabled: !busy,
            decoration: InputDecoration(
              labelText: phaseText(
                'Search name, phone or reference',
                'بحث بالاسم أو الهاتف أو المرجع',
              ),
            ),
            onSubmitted: (_) {
              page = 1;
              load();
            },
          ),
          Wrap(
            spacing: 12,
            children: [
              TextButton(
                onPressed: busy ? null : () => date(true),
                child: Text(
                  '${phaseText('From', 'من')}: ${start?.toIso8601String().substring(0, 10) ?? '—'}',
                ),
              ),
              TextButton(
                onPressed: busy ? null : () => date(false),
                child: Text(
                  '${phaseText('To', 'إلى')}: ${end?.toIso8601String().substring(0, 10) ?? '—'}',
                ),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                        start = null;
                        end = null;
                        page = 1;
                        load();
                      },
                child: Text(phaseText('Clear dates', 'مسح التواريخ')),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () {
                        page = 1;
                        load();
                      },
                child: Text(phaseText('Search', 'بحث')),
              ),
              OutlinedButton(
                onPressed: busy ? null : () => download('pdf'),
                child: const Text('PDF'),
              ),
              OutlinedButton(
                onPressed: busy ? null : () => download('xlsx'),
                child: const Text('Excel'),
              ),
            ],
          ),
          DropdownButtonFormField<int>(
            initialValue: limit,
            decoration: InputDecoration(labelText: phaseText('Rows', 'الصفوف')),
            items: [
              for (final n in [25, 100, 500, 1000, 5000])
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
          for (final r in rows)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${r['amount']} · ${r['status'] == 'COMPLETED' ? phaseText('PAID', 'مدفوع') : r['status']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${r['settlementNumber']}\n${r['createdAt'].toString().substring(0, 10)} · ${r['payoutMethod'] ?? '—'}',
                    ),
                    if (r['bankDetails'] != null)
                      Text(
                        '${r['bankDetails']['beneficiaryName']} · ${r['bankDetails']['bankName']}\n${r['bankDetails']['iban'] ?? r['bankDetails']['accountNumber']}',
                      ),
                    if (r['reference'] != null)
                      Text(
                        '${phaseText('Reference', 'المرجع')}: ${r['reference']}',
                      ),
                    if (r['receiptUrl'] != null &&
                        [
                          'http',
                          'https',
                        ].contains(Uri.tryParse(r['receiptUrl'])?.scheme))
                      TextButton(
                        onPressed: () async {
                          try {
                            final ok = await launchUrl(
                              Uri.parse(r['receiptUrl']),
                              mode: LaunchMode.externalApplication,
                            );
                            if (!ok) {
                              throw Exception(
                                phaseText(
                                  'Unable to open receipt.',
                                  'تعذر فتح الإيصال.',
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setState(() {
                              error = '$e';
                            });
                          }
                        },
                        child: Text(
                          phaseText('View payment receipt', 'عرض إيصال الدفع'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (!busy && rows.isEmpty)
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
