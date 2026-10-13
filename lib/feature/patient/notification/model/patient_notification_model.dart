class PatientNotificationResponse {
  final bool? success;
  final String? message;
  final PatientNotificationDataResponse? data;

  PatientNotificationResponse({this.success, this.message, this.data});

  factory PatientNotificationResponse.fromJson(Map<String, dynamic> json) =>
      PatientNotificationResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : PatientNotificationDataResponse.fromJson(json["data"]),
      );
}

class PatientNotificationDataResponse {
  final Meta? meta;
  final List<PatientNotificationItem>? data;

  PatientNotificationDataResponse({this.meta, this.data});

  factory PatientNotificationDataResponse.fromJson(Map<String, dynamic> json) =>
      PatientNotificationDataResponse(
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
        data: json["data"] == null
            ? []
            : List<PatientNotificationItem>.from(
                json["data"]!.map((x) => PatientNotificationItem.fromJson(x)),
              ),
      );
}

class Meta {
  final int? page;
  final int? limit;
  final int? total;

  Meta({this.page, this.limit, this.total});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        page: json["page"],
        limit: json["limit"],
        total: json["total"],
      );
}

class PatientNotificationItem {
  final String? id;
  final String? patientId;
  final String? notificationType;
  final String? bookingAppointmentId;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BookingAppointmentInfo? bookingAppointment;

  PatientNotificationItem({
    this.id,
    this.patientId,
    this.notificationType,
    this.bookingAppointmentId,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.bookingAppointment,
  });

  factory PatientNotificationItem.fromJson(Map<String, dynamic> json) =>
      PatientNotificationItem(
        id: json["id"],
        patientId: json["patientId"],
        notificationType: json["notificationType"],
        bookingAppointmentId: json["bookingAppointmentId"],
        title: json["title"],
        description: json["description"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"]),
        bookingAppointment: json["bookingAppointment"] == null
            ? null
            : BookingAppointmentInfo.fromJson(json["bookingAppointment"]),
      );
}

class BookingAppointmentInfo {
  final String? id;
  final DateTime? consultDate;
  final String? startTime;
  final String? endTime;
  final int? serialNumber;
  final DoctorInfo? doctor;
  final ClinicInfo? clinic;

  BookingAppointmentInfo({
    this.id,
    this.consultDate,
    this.startTime,
    this.endTime,
    this.serialNumber,
    this.doctor,
    this.clinic,
  });

  factory BookingAppointmentInfo.fromJson(Map<String, dynamic> json) =>
      BookingAppointmentInfo(
        id: json["id"],
        consultDate: json["consultDate"] == null
            ? null
            : DateTime.tryParse(json["consultDate"]),
        startTime: json["startTime"],
        endTime: json["endTime"],
        serialNumber: json["serialNumber"] == null
            ? null
            : (json["serialNumber"] is int
                ? json["serialNumber"] as int
                : int.tryParse(json["serialNumber"].toString())),
        doctor:
            json["doctor"] == null ? null : DoctorInfo.fromJson(json["doctor"]),
        clinic:
            json["clinic"] == null ? null : ClinicInfo.fromJson(json["clinic"]),
      );
}

class DoctorInfo {
  final String? id;
  final UserInfo? user;

  DoctorInfo({this.id, this.user});

  factory DoctorInfo.fromJson(Map<String, dynamic> json) => DoctorInfo(
        id: json["id"],
        user: json["user"] == null ? null : UserInfo.fromJson(json["user"]),
      );
}

class ClinicInfo {
  final String? id;
  final String? clinicName;
  final String? location;

  ClinicInfo({this.id, this.clinicName, this.location});

  factory ClinicInfo.fromJson(Map<String, dynamic> json) => ClinicInfo(
        id: json["id"],
        clinicName: json["clinicName"],
        location: json["location"],
      );
}

class UserInfo {
  final String? fullName;
  final String? profileImage;

  UserInfo({this.fullName, this.profileImage});

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        fullName: json["fullName"],
        profileImage: json["profileImage"],
      );
}
