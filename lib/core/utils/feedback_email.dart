import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openFeedbackEmail() async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'info@spidertech.ly',
    query: 'subject=${Uri.encodeComponent('Salama feedback')}',
  );
  try {
    if (await launchUrl(uri)) return;
  } catch (_) {
    // Show the same message when the mail application rejects the launch.
  }
  Get.snackbar('error'.tr, 'could_not_open_email'.tr);
}
