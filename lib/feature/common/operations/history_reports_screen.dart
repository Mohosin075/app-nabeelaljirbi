import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'phase_one_api.dart';

class HistoryReportsScreen extends StatefulWidget {
  final bool complaints;
  const HistoryReportsScreen({super.key, this.complaints = false});
  @override
  State<HistoryReportsScreen> createState() => _HistoryReportsScreenState();
}

class _HistoryReportsScreenState extends State<HistoryReportsScreen> {
  String kind = 'wallet', filter = 'ALL';
  DateTime? start, end;
  int page = 1, total = 0;
  bool busy = false;
  String? error;
  List<dynamic> rows = [];
  Map<String, dynamic> get query => {
    'page': page,
    'limit': 25,
    if (start != null) 'startDate': start!.toIso8601String().substring(0, 10),
    if (end != null) 'endDate': end!.toIso8601String().substring(0, 10),
    if (widget.complaints || kind == 'bookings')
      'status': filter
    else
      'type': filter,
  };
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final data = await PhaseOneApi.call(
        widget.complaints
            ? 'my-complaints'
            : kind == 'wallet'
            ? 'wallet-history'
            : 'bookings',
        query: query,
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
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final bytes = await PhaseOneApi.download(kind, format, query);
      if (!mounted) return;
      await Share.shareXFiles([
        XFile.fromData(
          bytes,
          name: 'salama-$kind.$format',
          mimeType: format == 'pdf'
              ? 'application/pdf'
              : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      ], sharePositionOrigin: origin);
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
  Widget build(BuildContext context) {
    final options = widget.complaints
        ? ['ALL', 'PENDING', 'UNDER_INVESTIGATION', 'RESOLVED', 'DISMISSED']
        : kind == 'wallet'
        ? [
            'ALL',
            'RECHARGE',
            'REFERALL',
            'BOOKING',
            'WITHDRAW',
            'CANCEL',
            'REFUND',
            'PENALTY',
          ]
        : [
            'ALL',
            'PENDING',
            'CONFIRMED',
            'ARRIVED',
            'COMPLETE',
            'CANCELLED',
            'REJECTED',
            'PATIENT_NO_SHOW',
            'DOCTOR_ABSENT',
          ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.complaints
              ? phaseText('My Complaints', 'شكاواي')
              : phaseText('Ledger & Reports', 'السجل والتقارير'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!widget.complaints)
              DropdownButtonFormField<String>(
                initialValue: kind,
                decoration: InputDecoration(
                  labelText: phaseText('Report', 'التقرير'),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'wallet',
                    child: Text(phaseText('Wallet ledger', 'سجل المحفظة')),
                  ),
                  DropdownMenuItem(
                    value: 'bookings',
                    child: Text(
                      phaseText('Bookings and fees', 'الحجوزات والرسوم'),
                    ),
                  ),
                ],
                onChanged: busy
                    ? null
                    : (v) {
                        kind = v!;
                        filter = 'ALL';
                        page = 1;
                        load();
                      },
              ),
            DropdownButtonFormField<String>(
              key: ValueKey('$kind-${widget.complaints}-$filter'),
              initialValue: filter,
              decoration: InputDecoration(
                labelText: phaseText('Filter', 'التصفية'),
              ),
              items: [
                for (final s in options)
                  DropdownMenuItem(value: s, child: Text(s)),
              ],
              onChanged: busy
                  ? null
                  : (v) {
                      filter = v!;
                      page = 1;
                      load();
                    },
            ),
            if (!widget.complaints)
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
                ],
              ),
            if (!widget.complaints &&
                ['DOCTOR', 'CLINIC'].contains(SharedPrefHelper.getUserRole()))
              Wrap(
                spacing: 12,
                children: [
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
            if (busy) const LinearProgressIndicator(),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Text('$total ${phaseText('records', 'سجل')}'),
            for (final r in rows)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: widget.complaints
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r['subject']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('${r['complaintNumber']} · ${r['status']}'),
                            Text('${r['description']}'),
                            if (r['resolution'] != null)
                              Text(
                                '${phaseText('Response / Resolution', 'الرد / الحل')}: ${r['resolution']}',
                              ),
                            Text(r['updatedAt'].toString().substring(0, 10)),
                          ],
                        )
                      : kind == 'wallet'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r['amount']} · ${r['direction']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${r['type']} · ${r['createdAt'].toString().substring(0, 10)}',
                            ),
                            SelectableText('${r['id']}'),
                            if (r['appointmentId'] != null)
                              Text(
                                '${phaseText('Booking', 'الحجز')}: ${r['appointmentId']}',
                              ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r['displayStatus']} · #${r['serialNumber']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${r['consultDate'].toString().substring(0, 10)} · ${r['clinic']['clinicName']}',
                            ),
                            Text('${r['doctor']['user']['fullName']}'),
                            Text(
                              '${phaseText('Consultation', 'الاستشارة')}: ${r['consultFee']}\n${phaseText('Patient fee', 'رسوم المريض')}: ${r['serviceFeeAmount']}\n${phaseText('Clinic fee', 'رسوم العيادة')}: ${r['clinicServiceFee']}\n${r['collectionMode']} · ${r['feeCountry'] ?? '—'}',
                            ),
                          ],
                        ),
                ),
              ),
            if (!busy && rows.isEmpty)
              Text(phaseText('No matching records.', 'لا توجد سجلات مطابقة.')),
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
                  onPressed: busy || page * 25 >= total
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
}
