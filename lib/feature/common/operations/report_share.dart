import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'phase_one_api.dart';

Future<void> sharePhaseReport(
  BuildContext context,
  String kind,
  String format,
  Map<String, dynamic> filters,
) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final bytes = await PhaseOneApi.download(
    kind,
    format,
    Map<String, dynamic>.from(filters),
  );
  if (!context.mounted) return;
  await Share.shareXFiles([
    XFile.fromData(
      bytes,
      name: 'salama-$kind.$format',
      mimeType: format == 'pdf'
          ? 'application/pdf'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ),
  ], sharePositionOrigin: origin);
}
