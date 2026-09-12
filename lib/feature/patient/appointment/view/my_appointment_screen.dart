import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/controller/appointment_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/model/appointment_history_model.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/widget/review_bottom_sheet.dart';

class MyAppointmentScreen extends StatelessWidget {
  MyAppointmentScreen({super.key});

  final AppointmentController controller = Get.put(AppointmentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'my_appointment'.tr,
          style: globalTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.allAppointments.isEmpty) {
          return Center(child: Text("no_appointments_found".tr));
        }

        return Column(
          children: [
            // Tabs
            Container(
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Obx(() {
                  // Calculate counts for each status
                  final pendingCount = controller.allAppointments
                      .where(
                        (apt) =>
                            apt.status?.toUpperCase() == 'PENDING' ||
                            apt.status?.toUpperCase() == 'INPROGRESS',
                      )
                      .length;
                  final confirmedCount = controller.allAppointments
                      .where((apt) => apt.status?.toUpperCase() == 'CONFIRMED')
                      .length;
                  final arrivedCount = controller.allAppointments
                      .where((apt) => apt.status?.toUpperCase() == 'ARRIVED')
                      .length;
                  final completedCount = controller.allAppointments
                      .where((apt) => apt.status?.toUpperCase() == 'COMPLETE')
                      .length;
                  final cancelledCount = controller.allAppointments
                      .where((apt) => apt.status?.toUpperCase() == 'CANCELLED')
                      .length;

                  return Row(
                    children: [
                      _buildTab(
                        '${'pending'.tr} ($pendingCount)',
                        0,
                        controller,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        '${'confirmed'.tr} ($confirmedCount)',
                        1,
                        controller,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        '${'arrived'.tr} ($arrivedCount)',
                        2,
                        controller,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        '${'completed'.tr} ($completedCount)',
                        3,
                        controller,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        '${'cancelled'.tr} ($cancelledCount)',
                        4,
                        controller,
                      ),
                    ],
                  );
                }),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E9F2)),
            // Appointment List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.getAppointmentHistory(),
                color: AppColors.primaryColor,
                child: Obx(() {
                  final appointments = controller.filteredAppointments;
                  if (appointments.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Text(
                              'no_appointments_found'.tr,
                              style: globalTextStyle(
                                fontSize: 14,
                                color: const Color(0xff636F85),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final apt = appointments[index];
                      final status = apt.status?.toUpperCase() ?? '';

                      // Show in appropriate card style
                      if (status == 'COMPLETE' || status == 'CANCELLED') {
                        return _buildFinishedCard(apt, context);
                      } else {
                        return _buildUpcomingCard(apt, context);
                      }
                    },
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTab(String label, int index, AppointmentController controller) {
    final isSelected = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFE5E9F2),
          ),
        ),
        child: Text(
          label,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xff636F85),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(Appointment apt, BuildContext context) {
    final status = apt.status ?? 'upcoming'.tr;
    final queue = apt.serialNumber?.toString() ?? '-';
    final doctorName = apt.doctor?.user?.fullName ?? 'unknown_doctor'.tr;
    final specialty = apt.doctor?.speciality ?? 'doctor'.tr;
    final doctorImage = apt.doctor?.user?.profileImage ?? '';
    final time = "${_formatTime(apt.startTime)} - ${_formatTime(apt.endTime)}";
    final date = _formatDate(apt.consultDate);
    final title = "${'consultation_with'.tr} $doctorName";

    return GestureDetector(
      onTap: () {
        debugPrint('status: $status');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(status),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryColor),
                  ),
                  child: Text(
                    '${'queue'.tr} $queue',
                    style: globalTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xff1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    doctorImage,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 48, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: globalTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1A1A1A),
                        ),
                      ),
                      Text(
                        specialty,
                        style: globalTextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff1A1A1A),
                      ),
                    ),
                    Text(
                      date,
                      style: globalTextStyle(
                        fontSize: 12,
                        color: const Color(0xff636F85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (status.toUpperCase() == 'PENDING') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final isCancelling =
                      controller.cancellingAppointmentId.value == apt.id;
                  return OutlinedButton(
                    onPressed: isCancelling
                        ? null
                        : () {
                            if (apt.id != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Text(
                                    'cancel_appointment'.tr,
                                    style: globalTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff2D2D2D),
                                    ),
                                  ),
                                  content: Text(
                                    'are_you_sure_cancel'.tr,
                                    style: globalTextStyle(
                                      fontSize: 14,
                                      color: const Color(0xff636F85),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'no'.tr,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xff636F85),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        controller.cancelAppointment(apt.id!);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'yes'.tr,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E9F2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isCancelling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          )
                        : Text(
                            'cancel'.tr,
                            style: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff636F85),
                            ),
                          ),
                  );
                }),
              ),
            ],
            if (status.toUpperCase() == 'CONFIRMED') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final isUpdating =
                      controller.updatingAppointmentId.value == apt.id;
                  return ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                            if (apt.id != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Text(
                                    'mark_as_arrived'.tr,
                                    style: globalTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff2D2D2D),
                                    ),
                                  ),
                                  content: Text(
                                    'confirm_arrival_message'.tr,
                                    style: globalTextStyle(
                                      fontSize: 14,
                                      color: const Color(0xff636F85),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'no'.tr,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xff636F85),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        controller.updateAppointmentStatus(
                                          apt.id!,
                                          'ARRIVED',
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'yes'.tr,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'ive_arrived'.tr,
                            style: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  );
                }),
              ),
            ],
            if (status.toUpperCase() == 'ARRIVED') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final isUpdating =
                      controller.updatingAppointmentId.value == apt.id;
                  return ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                            if (apt.id != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Text(
                                    'complete_appointment'.tr,
                                    style: globalTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff2D2D2D),
                                    ),
                                  ),
                                  content: Text(
                                    'confirm_complete_message'.tr,
                                    style: globalTextStyle(
                                      fontSize: 14,
                                      color: const Color(0xff636F85),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'no'.tr,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xff636F85),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        controller.updateAppointmentStatus(
                                          apt.id!,
                                          'COMPLETE',
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF4CAF50,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'yes'.tr,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'complete'.tr,
                            style: globalTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinishedCard(Appointment apt, BuildContext context) {
    final status = apt.status ?? 'finished'.tr;
    final doctorName = apt.doctor?.user?.fullName ?? 'unknown_doctor'.tr;
    final specialty = apt.doctor?.speciality ?? 'doctor'.tr;
    final doctorImage = apt.doctor?.user?.profileImage ?? '';
    final time = "${_formatTime(apt.startTime)} - ${_formatTime(apt.endTime)}";
    final date = _formatDate(apt.consultDate);
    final title =
        "${apt.doctor?.speciality}\n${'consultation_with'.tr} $doctorName";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(status),
              if (status.toUpperCase() == 'COMPLETE' ||
                  status.toUpperCase() == 'COMPLETED')
                Builder(
                  builder: (context) {
                    final hasReview =
                        (apt.doctorRatings != null &&
                        apt.doctorRatings!.isNotEmpty);
                    if (hasReview) {
                      return const SizedBox.shrink();
                    }
                    return TextButton(
                      onPressed: () {
                        controller.selectedReviewRating.value = 0;
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              ReviewBottomSheet(appointment: apt),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      child: Text(
                        'review'.tr,
                        style: globalTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            title,
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xff1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  doctorImage,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 48, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff1A1A1A),
                      ),
                    ),
                    Text(
                      specialty,
                      style: globalTextStyle(
                        fontSize: 12,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff1A1A1A),
                    ),
                  ),
                  Text(
                    date,
                    style: globalTextStyle(
                      fontSize: 12,
                      color: const Color(0xff636F85),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if ((status.toUpperCase() == 'COMPLETE' ||
                  status.toUpperCase() == 'COMPLETED') &&
              (apt.doctorRatings != null && apt.doctorRatings!.isNotEmpty)) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'your_review'.tr,
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    final rating =
                        (apt.doctorRatings != null &&
                            apt.doctorRatings!.isNotEmpty)
                        ? (apt.doctorRatings![0].rating ?? 0)
                        : 0;
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFB800),
                      size: 24,
                    );
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color dotColor;
    Color borderColor;
    String label;

    final statusUpper = status.toUpperCase();

    if (statusUpper == 'PENDING') {
      // Blue for pending
      bgColor = const Color(0xFFE3F2FD);
      dotColor = const Color(0xFF2196F3);
      borderColor = const Color(0xFF2196F3);
      label = 'pending'.tr;
    } else if (statusUpper == 'CONFIRMED' || statusUpper == 'UPCOMING') {
      // Orange/Yellow for confirmed (upcoming)
      bgColor = const Color(0xFFFFF3E0);
      dotColor = const Color(0xFFFF9800);
      borderColor = const Color(0xFFFF9800);
      label = statusUpper == 'CONFIRMED' ? 'confirmed'.tr : 'upcoming'.tr;
    } else if (statusUpper == 'COMPLETE' ||
        statusUpper == 'COMPLETED' ||
        statusUpper == 'FINISHED') {
      // Green for completed
      bgColor = const Color(0xFFE8F5E9);
      dotColor = const Color(0xFF4CAF50);
      borderColor = const Color(0xFF4CAF50);
      label = (statusUpper == 'FINISHED') ? 'finished'.tr : 'completed'.tr;
    } else if (statusUpper == 'CANCELLED') {
      // Red for cancelled
      bgColor = const Color(0xFFFFEBEE);
      dotColor = const Color(0xFFEF5350);
      borderColor = const Color(0xFFEF5350);
      label = 'cancelled'.tr;
    } else if (statusUpper == 'ARRIVED') {
      // Blue/Green or specific color for arrived? using Purple for 'Arrived'
      bgColor = const Color(0xFFF3E5F5);
      dotColor = const Color(0xFF9C27B0);
      borderColor = const Color(0xFF9C27B0);
      label = 'arrived'.tr;
    } else if (statusUpper == 'IN_PROGRESS' || statusUpper == 'INPROGRESS') {
      // Light Blue for In Progress
      bgColor = const Color(0xFFE1F5FE);
      dotColor = const Color(0xFF039BE5);
      borderColor = const Color(0xFF039BE5);
      label = 'in_progress'.tr;
    } else {
      // Default gray for other statuses
      bgColor = const Color(0xFFF5F5F5);
      dotColor = const Color(0xFF9E9E9E);
      borderColor = const Color(0xFF9E9E9E);
      if (status.isNotEmpty) {
        label = status; // Fallback to raw string if unknown
      } else {
        label = status;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: globalTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: dotColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null) return "";
    try {
      DateTime dt;
      try {
        dt = DateFormat("HH:mm:ss").parse(time);
      } catch (e) {
        dt = DateFormat("HH:mm").parse(time);
      }

      final hour = dt.hour;
      final minute = dt.minute;
      final period = hour < 12 ? 'am'.tr : 'pm'.tr;
      final displayHour = hour > 12
          ? hour - 12
          : hour == 0
          ? 12
          : hour;

      return "$displayHour:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      return time;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final dt = DateTime.parse(dateStr);
      // Format: DayName, MonthName DayNumber (e.g., Tue, Feb 20)
      // We manually construct this to ensure localization
      final dayName = DateFormat('E').format(dt).toLowerCase(); // e.g. tue
      final monthName = DateFormat('MMM').format(dt).toLowerCase(); // e.g. feb
      final dayNum = dt.day;

      return "${dayName.tr}, ${monthName.tr} $dayNum";
    } catch (e) {
      return dateStr;
    }
  }
}
