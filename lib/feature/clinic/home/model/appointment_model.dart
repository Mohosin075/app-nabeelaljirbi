enum AppointmentStatus {
  pending,
  confirmed,
  arrived,
  inProgress,
  completed,
  cancelled,
  rejected,
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
  final String? absenceType;
  final int queueNo;
  final double? rating;
  final String? approximateEstimatedTime;
  final String? cancellationReason;
  final String? rejectionReason;
  final String? clinicName;
  final String? clinicLocation;
  final String? bookedFor;
  final String? familyMemberName;
  final String? familyMemberRelation;

  AppointmentModel({
    required this.id,
    required this.patientName,
    this.patientImage,
    required this.time,
    required this.date,
    this.appointmentDate,
    required this.doctorName,
    required this.status,
    this.absenceType,
    required this.queueNo,
    this.rating,
    this.approximateEstimatedTime,
    this.cancellationReason,
    this.rejectionReason,
    this.clinicName,
    this.clinicLocation,
    this.bookedFor,
    this.familyMemberName,
    this.familyMemberRelation,
  });
}

class ClinicStatsModel {
  final int doctorCount;
  final int todayAppointment;
  final int pendingAppointment;
  final int upcomingAppointment;
  final num? consultationNet;

  ClinicStatsModel({
    required this.doctorCount,
    required this.todayAppointment,
    required this.pendingAppointment,
    this.upcomingAppointment = 0,
    this.consultationNet,
  });

  factory ClinicStatsModel.fromJson(Map<String, dynamic> json) {
    return ClinicStatsModel(
      todayAppointment: json['todayAppointment'] ?? 0,
      pendingAppointment: json['pendingAppointment'] ?? 0,
      doctorCount: json['doctorCount'] ?? 0,
      upcomingAppointment: json['upcomingAppointment'] ?? 0,
      consultationNet: json['consultationNet'],
    );
  }
}
