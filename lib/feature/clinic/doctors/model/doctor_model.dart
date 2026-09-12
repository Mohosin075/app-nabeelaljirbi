class DoctorModel {
  final String name;
  final String specialty;
  final String experience;
  final int totalAppointments;
  final int upcomingAppointments;
  final double rating;
  final int ratingCount;
  final double consultationFee;
  final String? imageUrl;
  final bool isOnline;
  final String? bio;
  final String? scheduleStart;
  final String? scheduleEnd;

  DoctorModel({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.totalAppointments,
    required this.upcomingAppointments,
    required this.rating,
    required this.ratingCount,
    required this.consultationFee,
    this.imageUrl,
    this.isOnline = false,
    this.bio,
    this.scheduleStart,
    this.scheduleEnd,
  });
}
