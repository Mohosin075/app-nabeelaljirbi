class NotificationModel {
  final String title;
  final String description;
  final String time;
  final bool isUnread;

  NotificationModel({
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? 'Notification';
    final patientName =
        json['patient']?['user']?['fullName'] ?? 'Unknown Patient';
    // final doctorName = json['doctor']?['user']?['fullName'] ?? 'Unknown Doctor';
    final date = json['consultDate'] ?? '';

    return NotificationModel(
      title: 'Appointment ${_formatStatus(status)}',
      description: 'Patient: $patientName',
      time: _formatDate(date),
      isUnread: false, // API doesn't provide unread status
    );
  }

  static String _formatStatus(String status) {
    if (status.isEmpty) return '';
    // Handle specific cases if needed, or generic Capitalization
    if (status.toUpperCase() == 'NOT_SHOWN' || status.toUpperCase() == 'NOT_SHOW') return 'Not Shown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  static String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (date.isAfter(now)) {
        // Future date
        return "${date.day}/${date.month}/${date.year}";
      }

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return "${difference.inMinutes} mins ago";
        }
        return "${difference.inHours} hours ago";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else {
        return "${date.day}/${date.month}/${date.year}";
      }
    } catch (e) {
      return dateStr;
    }
  }
}
