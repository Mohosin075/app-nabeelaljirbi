import 'package:nabeelaljirbi_app/feature/clinic/home/model/appointment_model.dart';

class BookingHistoryResponse {
  final bool success;
  final String message;
  final BookingHistoryData? data;

  BookingHistoryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BookingHistoryResponse.fromJson(Map<String, dynamic> json) {
    return BookingHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? BookingHistoryData.fromJson(json['data'])
          : null,
    );
  }
}

class BookingHistoryData {
  final BookingMeta meta;
  final List<BookingItem> data;

  BookingHistoryData({required this.meta, required this.data});

  factory BookingHistoryData.fromJson(Map<String, dynamic> json) {
    return BookingHistoryData(
      meta: BookingMeta.fromJson(json['meta'] ?? {}),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => BookingItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BookingMeta {
  final int page;
  final int limit;
  final int total;

  BookingMeta({required this.page, required this.limit, required this.total});

  factory BookingMeta.fromJson(Map<String, dynamic> json) {
    return BookingMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}

class BookingItem {
  final String id;
  final DateTime? consultDate;
  final String status;
  final int serialNumber;
  final String? startTime;
  final String? endTime;
  final String? approximateEstimatedTime;
  final String? cancellationReason;
  final String? rejectionReason;
  final String? bookedFor;
  final String? familyMemberName;
  final String? familyMemberRelation;
  final BookingDoctor? doctor;
  final BookingPatient? patient;
  final BookingClinic? clinic;

  BookingItem({
    required this.id,
    this.consultDate,
    required this.status,
    required this.serialNumber,
    this.startTime,
    this.endTime,
    this.approximateEstimatedTime,
    this.cancellationReason,
    this.rejectionReason,
    this.bookedFor,
    this.familyMemberName,
    this.familyMemberRelation,
    this.doctor,
    this.patient,
    this.clinic,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'] ?? '',
      consultDate: json['consultDate'] != null
          ? DateTime.tryParse(json['consultDate'])
          : null,
      status: json['status'] ?? 'PENDING',
      serialNumber: json['serialNumber'] ?? 0,
      startTime: json['startTime'],
      endTime: json['endTime'],
      approximateEstimatedTime: json['approximateEstimatedTime'],
      cancellationReason: json['cancellationReason'] ?? json['noShowReason'],
      rejectionReason: json['rejectionReason'],
      bookedFor: json['bookedFor'],
      familyMemberName: json['familyMemberName'],
      familyMemberRelation: json['familyMemberRelation'],
      doctor: json['doctor'] != null
          ? BookingDoctor.fromJson(json['doctor'])
          : null,
      patient: json['patient'] != null
          ? BookingPatient.fromJson(json['patient'])
          : null,
      clinic: json['clinic'] != null
          ? BookingClinic.fromJson(json['clinic'])
          : null,
    );
  }

  /// Convert API status string to AppointmentStatus enum
  AppointmentStatus get appointmentStatus {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppointmentStatus.pending;
      case 'CONFIRMED':
        return AppointmentStatus.confirmed;
      case 'ARRIVED':
        return AppointmentStatus.arrived;
      case 'INPROGRESS':
        return AppointmentStatus.inProgress;
      case 'NOTSHOWN':
      case 'NOT_SHOWN':
      case 'NO_SHOW':
      case 'NOT_SHOW':
        return AppointmentStatus.notShown;
      case 'NOTUPDATED':
      case 'NOT_UPDATED':
        return AppointmentStatus.notUpdated;
      case 'COMPLETE':
      case 'COMPLETED':
        return AppointmentStatus.completed;
      case 'REJECTED':
        return AppointmentStatus.rejected;
      case 'CANCELLED':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  /// Convert to AppointmentModel for UI display
  AppointmentModel toAppointmentModel() {
    return AppointmentModel(
      id: id,
      patientName: patient?.user?.fullName ?? 'Unknown',
      patientImage: patient?.user?.profileImage,
      time: _formatTimeRange(),
      date: _formatDate(),
      appointmentDate: consultDate,
      doctorName: doctor?.user?.fullName ?? 'Unknown Doctor',
      status: appointmentStatus,
      queueNo: serialNumber,
      approximateEstimatedTime: approximateEstimatedTime,
      cancellationReason: cancellationReason,
      rejectionReason: rejectionReason,
      clinicName: clinic?.clinicName,
      clinicLocation: clinic?.location,
      bookedFor: bookedFor,
      familyMemberName: familyMemberName,
      familyMemberRelation: familyMemberRelation,
    );
  }

  String _formatTimeRange() {
    if (startTime == null) return '';
    // Handle time format like "10:51.000Z"
    final start = startTime!.replaceAll('.000Z', '');
    final end = endTime?.replaceAll('.000Z', '') ?? '';
    return '$start - $end';
  }

  String _formatDate() {
    if (consultDate == null) return '';
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = consultDate!;
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}

class BookingDoctor {
  final String id;
  final BookingUser? user;
  final String? speciality;

  BookingDoctor({required this.id, this.user, this.speciality});

  factory BookingDoctor.fromJson(Map<String, dynamic> json) {
    return BookingDoctor(
      id: json['id'] ?? '',
      user: json['user'] != null ? BookingUser.fromJson(json['user']) : null,
      speciality: json['speciality'],
    );
  }
}

class BookingPatient {
  final BookingUser? user;

  BookingPatient({this.user});

  factory BookingPatient.fromJson(Map<String, dynamic> json) {
    return BookingPatient(
      user: json['user'] != null ? BookingUser.fromJson(json['user']) : null,
    );
  }
}

class BookingClinic {
  final String? id;
  final String? clinicName;
  final String? location;
  final String? logo;
  final String? contactPhone;

  BookingClinic({
    this.id,
    this.clinicName,
    this.location,
    this.logo,
    this.contactPhone,
  });

  factory BookingClinic.fromJson(Map<String, dynamic> json) {
    return BookingClinic(
      id: json['id'],
      clinicName: json['clinicName'],
      location: json['location'],
      logo: json['logo'],
      contactPhone: json['contactPhone'],
    );
  }
}

class BookingUser {
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;
  final String? gender;
  final DateTime? dateOfBirth;

  BookingUser({
    this.fullName,
    this.phoneNumber,
    this.profileImage,
    this.gender,
    this.dateOfBirth,
  });

  factory BookingUser.fromJson(Map<String, dynamic> json) {
    return BookingUser(
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
    );
  }
}
