import 'package:get/get.dart';

/// Working times are wall-clock values in the clinic, including legacy strings.
String formatClinicTime(String? value) {
  final match = RegExp(
    r'^(?:\d{4}-\d{2}-\d{2}T)?(\d{1,2}):([0-5]\d)(?::[0-5]\d)?(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?$',
  ).firstMatch(value?.trim() ?? '');
  if (match == null) return 'na'.tr;
  final hour = int.parse(match.group(1)!);
  if (hour > 23) return 'na'.tr;
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final period = (hour < 12 ? 'am' : 'pm').tr;
  return '$displayHour:${match.group(2)} $period';
}
