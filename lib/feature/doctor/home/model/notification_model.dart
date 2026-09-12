class NotificationResponse {
  final bool? success;
  final String? message;
  final NotificationDataResponse? data;

  NotificationResponse({this.success, this.message, this.data});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : NotificationDataResponse.fromJson(json["data"]),
      );
}

class NotificationDataResponse {
  final Meta? meta;
  final List<NotificationData>? data;

  NotificationDataResponse({this.meta, this.data});

  factory NotificationDataResponse.fromJson(Map<String, dynamic> json) =>
      NotificationDataResponse(
        meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
        data: json["data"] == null
            ? []
            : List<NotificationData>.from(
                json["data"]!.map((x) => NotificationData.fromJson(x)),
              ),
      );
}

class NotificationData {
  final String? id;
  final String? doctorId;
  final String? notificationType;
  final String? bookingAppointmentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BookingAppointment? bookingAppointment;

  NotificationData({
    this.id,
    this.doctorId,
    this.notificationType,
    this.bookingAppointmentId,
    this.createdAt,
    this.updatedAt,
    this.bookingAppointment,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      NotificationData(
        id: json["id"],
        doctorId: json["doctorId"],
        notificationType: json["notificationType"],
        bookingAppointmentId: json["bookingAppointmentId"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        bookingAppointment: json["bookingAppointment"] == null
            ? null
            : BookingAppointment.fromJson(json["bookingAppointment"]),
      );
}

class BookingAppointment {
  final DateTime? consultDate;
  final String? startTime;
  final String? endTime;
  final int? serialNumber;
  final Patient? patient;

  BookingAppointment({
    this.consultDate,
    this.startTime,
    this.endTime,
    this.serialNumber,
    this.patient,
  });

  factory BookingAppointment.fromJson(Map<String, dynamic> json) =>
      BookingAppointment(
        consultDate: json["consultDate"] == null
            ? null
            : DateTime.parse(json["consultDate"]),
        startTime: json["startTime"],
        endTime: json["endTime"],
        serialNumber: json["serialNumber"],
        patient: json["patient"] == null
            ? null
            : Patient.fromJson(json["patient"]),
      );
}

class Patient {
  final User? user;

  Patient({this.user});

  factory Patient.fromJson(Map<String, dynamic> json) =>
      Patient(user: json["user"] == null ? null : User.fromJson(json["user"]));
}

class User {
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;

  User({this.fullName, this.phoneNumber, this.profileImage});

  factory User.fromJson(Map<String, dynamic> json) => User(
    fullName: json["fullName"],
    phoneNumber: json["phoneNumber"],
    profileImage: json["profileImage"],
  );
}

class Meta {
  final int? page;
  final int? limit;
  final int? total;

  Meta({this.page, this.limit, this.total});

  factory Meta.fromJson(Map<String, dynamic> json) =>
      Meta(page: json["page"], limit: json["limit"], total: json["total"]);
}
