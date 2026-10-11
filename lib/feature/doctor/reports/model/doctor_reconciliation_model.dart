class DoctorReconciliationResponse {
  final bool? success;
  final String? message;
  final DoctorReconciliationData? data;

  DoctorReconciliationResponse({
    this.success,
    this.message,
    this.data,
  });

  factory DoctorReconciliationResponse.fromJson(Map<String, dynamic> json) {
    return DoctorReconciliationResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? DoctorReconciliationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DoctorReconciliationData {
  final ReconciliationSummary? summary;
  final List<AvailableClinic>? availableClinics;
  final List<ClinicBreakdownItem>? clinicBreakdown;
  final List<DailyBreakdownItem>? dailyBreakdown;
  final ReconciliationMeta? meta;
  final List<ReconciliationAppointment>? appointments;

  DoctorReconciliationData({
    this.summary,
    this.availableClinics,
    this.clinicBreakdown,
    this.dailyBreakdown,
    this.meta,
    this.appointments,
  });

  factory DoctorReconciliationData.fromJson(Map<String, dynamic> json) {
    return DoctorReconciliationData(
      summary: json['summary'] != null
          ? ReconciliationSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      availableClinics: (json['availableClinics'] as List<dynamic>?)
          ?.map((e) => AvailableClinic.fromJson(e as Map<String, dynamic>))
          .toList(),
      clinicBreakdown: (json['clinicBreakdown'] as List<dynamic>?)
          ?.map((e) => ClinicBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      dailyBreakdown: (json['dailyBreakdown'] as List<dynamic>?)
          ?.map((e) => DailyBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] != null
          ? ReconciliationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      appointments: (json['data'] as List<dynamic>?)
          ?.map((e) => ReconciliationAppointment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReconciliationSummary {
  final int totalAppointments;
  final int completedAppointments;
  final int confirmedAppointments;
  final int cancelledAppointments;
  final int noShowAppointments;
  final int pendingAppointments;
  final double consultFeePerSession;
  final double totalEarnedAmount;
  final double totalPotentialAmount;

  ReconciliationSummary({
    this.totalAppointments = 0,
    this.completedAppointments = 0,
    this.confirmedAppointments = 0,
    this.cancelledAppointments = 0,
    this.noShowAppointments = 0,
    this.pendingAppointments = 0,
    this.consultFeePerSession = 0.0,
    this.totalEarnedAmount = 0.0,
    this.totalPotentialAmount = 0.0,
  });

  factory ReconciliationSummary.fromJson(Map<String, dynamic> json) {
    return ReconciliationSummary(
      totalAppointments: json['totalAppointments'] as int? ?? 0,
      completedAppointments: json['completedAppointments'] as int? ?? 0,
      confirmedAppointments: json['confirmedAppointments'] as int? ?? 0,
      cancelledAppointments: json['cancelledAppointments'] as int? ?? 0,
      noShowAppointments: json['noShowAppointments'] as int? ?? 0,
      pendingAppointments: json['pendingAppointments'] as int? ?? 0,
      consultFeePerSession: (json['consultFeePerSession'] as num?)?.toDouble() ?? 0.0,
      totalEarnedAmount: (json['totalEarnedAmount'] as num?)?.toDouble() ?? 0.0,
      totalPotentialAmount: (json['totalPotentialAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AvailableClinic {
  final String id;
  final String? clinicName;
  final String? location;
  final String? logo;

  AvailableClinic({
    required this.id,
    this.clinicName,
    this.location,
    this.logo,
  });

  factory AvailableClinic.fromJson(Map<String, dynamic> json) {
    return AvailableClinic(
      id: json['id'] as String? ?? '',
      clinicName: json['clinicName'] as String?,
      location: json['location'] as String?,
      logo: json['logo'] as String?,
    );
  }
}

class ClinicBreakdownItem {
  final String clinicId;
  final String clinicName;
  final String? logo;
  final int totalCount;
  final int completedCount;
  final double totalAmount;

  ClinicBreakdownItem({
    required this.clinicId,
    required this.clinicName,
    this.logo,
    this.totalCount = 0,
    this.completedCount = 0,
    this.totalAmount = 0.0,
  });

  factory ClinicBreakdownItem.fromJson(Map<String, dynamic> json) {
    return ClinicBreakdownItem(
      clinicId: json['clinicId'] as String? ?? '',
      clinicName: json['clinicName'] as String? ?? '',
      logo: json['logo'] as String?,
      totalCount: json['totalCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyBreakdownItem {
  final String date;
  final int totalCount;
  final int completedCount;
  final double totalAmount;

  DailyBreakdownItem({
    required this.date,
    this.totalCount = 0,
    this.completedCount = 0,
    this.totalAmount = 0.0,
  });

  factory DailyBreakdownItem.fromJson(Map<String, dynamic> json) {
    return DailyBreakdownItem(
      date: json['date'] as String? ?? '',
      totalCount: json['totalCount'] as int? ?? 0,
      completedCount: json['completedCount'] as int? ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReconciliationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPage;

  ReconciliationMeta({
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPage = 1,
  });

  factory ReconciliationMeta.fromJson(Map<String, dynamic> json) {
    return ReconciliationMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPage: json['totalPage'] as int? ?? 1,
    );
  }
}

class ReconciliationAppointment {
  final String id;
  final int serialNumber;
  final DateTime? consultDate;
  final String? startTime;
  final String? endTime;
  final String status;
  final double consultFee;
  final ReconciliationClinic? clinic;
  final ReconciliationPatient? patient;
  final DateTime? createdAt;

  ReconciliationAppointment({
    required this.id,
    this.serialNumber = 0,
    this.consultDate,
    this.startTime,
    this.endTime,
    required this.status,
    this.consultFee = 0.0,
    this.clinic,
    this.patient,
    this.createdAt,
  });

  factory ReconciliationAppointment.fromJson(Map<String, dynamic> json) {
    return ReconciliationAppointment(
      id: json['id'] as String? ?? '',
      serialNumber: json['serialNumber'] as int? ?? 0,
      consultDate: json['consultDate'] != null
          ? DateTime.tryParse(json['consultDate'] as String)
          : null,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      consultFee: (json['consultFee'] as num?)?.toDouble() ?? 0.0,
      clinic: json['clinic'] != null
          ? ReconciliationClinic.fromJson(json['clinic'] as Map<String, dynamic>)
          : null,
      patient: json['patient'] != null
          ? ReconciliationPatient.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class ReconciliationClinic {
  final String id;
  final String? clinicName;
  final String? location;
  final String? logo;
  final String? contactPhone;

  ReconciliationClinic({
    required this.id,
    this.clinicName,
    this.location,
    this.logo,
    this.contactPhone,
  });

  factory ReconciliationClinic.fromJson(Map<String, dynamic> json) {
    return ReconciliationClinic(
      id: json['id'] as String? ?? '',
      clinicName: json['clinicName'] as String?,
      location: json['location'] as String?,
      logo: json['logo'] as String?,
      contactPhone: json['contactPhone'] as String?,
    );
  }
}

class ReconciliationPatient {
  final String id;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImage;

  ReconciliationPatient({
    required this.id,
    this.fullName,
    this.phoneNumber,
    this.profileImage,
  });

  factory ReconciliationPatient.fromJson(Map<String, dynamic> json) {
    return ReconciliationPatient(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }
}
