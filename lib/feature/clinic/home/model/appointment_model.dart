enum AppointmentStatus {
  pending,
  confirmed,
  arrived,
  completed,
  cancelled,
  notShown,
  notUpdated,
}

class AppointmentModel {
  final String id;
  final String patientName;
  final String? patientImage;
  final String time;
  final String date;
  final DateTime? appointmentDate;
  final String doctorName;
  final AppointmentStatus status;
  final int queueNo;
  final double? rating;

  AppointmentModel({
    required this.id,
    required this.patientName,
    this.patientImage,
    required this.time,
    required this.date,
    this.appointmentDate,
    required this.doctorName,
    required this.status,
    required this.queueNo,
    this.rating,
  });
}

class ClinicStatsModel {
  final int doctorCount;
  final int todayAppointment;
  final int pendingAppointment;

  ClinicStatsModel({
    required this.doctorCount,
    required this.todayAppointment,
    required this.pendingAppointment,
  });

  factory ClinicStatsModel.fromJson(Map<String, dynamic> json) {
    return ClinicStatsModel(
      todayAppointment: json['todayAppointment'] ?? 0,
      pendingAppointment: json['pendingAppointment'] ?? 0,
      doctorCount: json['doctorCount'] ?? 0,
    );
  }
}
