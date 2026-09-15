import 'dart:convert';
import 'package:flutter/material.dart';

class QualificationItem {
  final TextEditingController degreeController;
  final TextEditingController instituteController;
  final TextEditingController yearController;

  QualificationItem({
    String degree = '',
    String institute = '',
    String year = '',
  })  : degreeController = TextEditingController(text: degree),
        instituteController = TextEditingController(text: institute),
        yearController = TextEditingController(text: year);

  Map<String, String> toJson() => {
        'degree': degreeController.text.trim(),
        'institute': instituteController.text.trim(),
        'year': yearController.text.trim(),
      };

  bool get isEmpty =>
      degreeController.text.trim().isEmpty &&
      instituteController.text.trim().isEmpty &&
      yearController.text.trim().isEmpty;

  void dispose() {
    degreeController.dispose();
    instituteController.dispose();
    yearController.dispose();
  }

  static String? validateList(List<QualificationItem> items) {
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (!item.isEmpty) {
        if (item.degreeController.text.trim().isEmpty) {
          return 'Please enter Degree / Title for Qualification #${i + 1}';
        }
        final yearText = item.yearController.text.trim();
        if (yearText.isNotEmpty && yearText.length != 4) {
          return 'Year must be a 4-digit number for Qualification #${i + 1}';
        }
      }
    }
    return null;
  }

  static String encodeList(List<QualificationItem> items) {
    final validItems =
        items.where((i) => !i.isEmpty).map((i) => i.toJson()).toList();
    return jsonEncode(validItems);
  }

  static List<QualificationItem> decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return [QualificationItem()];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final list = decoded.map((item) {
          if (item is Map) {
            return QualificationItem(
              degree: item['degree']?.toString() ?? '',
              institute: item['institute']?.toString() ?? '',
              year: item['year']?.toString() ?? '',
            );
          }
          return QualificationItem();
        }).toList();

        return list.isEmpty ? [QualificationItem()] : list;
      }
    } catch (_) {
      // Fallback if not valid JSON
    }

    // If raw is text (not JSON and not HTTP URL), place it in degree
    if (!raw.startsWith('http')) {
      return [QualificationItem(degree: raw)];
    }

    return [QualificationItem()];
  }
}

class QualificationData {
  final String degree;
  final String institute;
  final String year;

  QualificationData({
    required this.degree,
    required this.institute,
    required this.year,
  });

  static List<QualificationData> parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((item) {
              if (item is Map) {
                return QualificationData(
                  degree: item['degree']?.toString() ?? '',
                  institute: item['institute']?.toString() ?? '',
                  year: item['year']?.toString() ?? '',
                );
              }
              return null;
            })
            .whereType<QualificationData>()
            .where((q) =>
                q.degree.isNotEmpty ||
                q.institute.isNotEmpty ||
                q.year.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
