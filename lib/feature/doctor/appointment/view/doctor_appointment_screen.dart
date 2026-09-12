import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/doctor/appointment/controller/doctor_appointment_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/appointment/model/doctor_appointment_model.dart';

class DoctorAppointmentScreen extends StatelessWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorAppointmentController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller),
            const SizedBox(height: 16),
            Divider(
              color: Color(0xffE5E9F2).withValues(alpha: 0.7),
              thickness: 8,
            ),
            const SizedBox(height: 16),
            _buildTabs(controller),
            const SizedBox(height: 16),
            Expanded(child: _buildAppointmentList(controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DoctorAppointmentController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Obx(() {
              final hasDate = controller.selectedDate.value != null;
              final dateStr = hasDate
                  ? DateFormat(
                      'MMM dd, yyyy',
                      Get.locale?.languageCode == 'ar' ? 'ar' : 'en_US',
                    ).format(controller.selectedDate.value!)
                  : 'my_appointment'.tr;
              return Row(
                children: [
                  Text(
                    dateStr,
                    style: globalTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff2D2D2D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasDate) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => controller.selectDate(null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
          IconButton(
            icon: Obx(
              () => Icon(
                Icons.calendar_month_outlined,
                size: 24,
                color: controller.selectedDate.value != null
                    ? const Color(0xff137CCF)
                    : const Color(0xff475569),
              ),
            ),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                controller.selectDate(picked);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(DoctorAppointmentController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Obx(() {
        final pendingCount = controller.allAppointments
            .where((apt) => apt.status?.toUpperCase() == 'PENDING')
            .length;
        final upcomingCount = controller.allAppointments
            .where(
              (apt) =>
                  apt.status?.toUpperCase() == 'CONFIRMED' ||
                  apt.status?.toUpperCase() == 'INPROGRESS',
            )
            .length;
        final arrivedCount = controller.allAppointments
            .where((apt) => apt.status?.toUpperCase() == 'ARRIVED')
            .length;
        final completedCount = controller.allAppointments
            .where((apt) => apt.status?.toUpperCase() == 'COMPLETE')
            .length;

        return Row(
          children: [
            Expanded(
              child: _buildTabItem(
                '${'pending'.tr} ($pendingCount)',
                0,
                controller.selectedTab.value == 0,
                () => controller.selectTab(0),
              ),
            ),
            Expanded(
              child: _buildTabItem(
                '${'upcoming'.tr} ($upcomingCount)',
                1,
                controller.selectedTab.value == 1,
                () => controller.selectTab(1),
              ),
            ),
            Expanded(
              child: _buildTabItem(
                '${'arrived'.tr} ($arrivedCount)',
                2,
                controller.selectedTab.value == 2,
                () => controller.selectTab(2),
              ),
            ),
            Expanded(
              child: _buildTabItem(
                '${'completed'.tr} ($completedCount)',
                3,
                controller.selectedTab.value == 3,
                () => controller.selectTab(3),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabItem(
    String label,
    int index,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff137CCF) : Color(0xffEDEEF4),
          borderRadius: isSelected
              ? BorderRadius.circular(6)
              : BorderRadius.circular(0),
        ),
        child: Text(
          label,
          style: globalTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xff636F85),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(DoctorAppointmentController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.getDoctorAppointments(),
        color: AppColors.primaryColor,

        child: controller.filteredAppointments.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(Get.context!).size.height * 0.6,
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
              )
            : ListView.builder(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount:
                    controller.filteredAppointments.length +
                    (controller.isMoreLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < controller.filteredAppointments.length) {
                    final apt = controller.filteredAppointments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildAppointmentCard(apt, controller, context),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }
                },
              ),
      );
    });
  }

  Widget _buildAppointmentCard(
    Appointment apt,
    DoctorAppointmentController controller,
    BuildContext context,
  ) {
    Color statusColor;
    Color statusBgColor;
    String statusValue = apt.status?.toUpperCase() ?? 'PENDING';
    String statusDisplayLabel = statusValue
        .toLowerCase()
        .replaceAll(' ', '_')
        .tr;

    // Mapping based on BookingStatus Enum
    // Mapping based on BookingStatus Enum
    switch (statusValue) {
      case 'PENDING':
        statusColor = const Color(0xFF2196F3); // Blue
        statusBgColor = const Color(0xFFE3F2FD);
        statusDisplayLabel = 'pending'.tr;
        break;
      case 'CONFIRMED':
        statusColor = const Color(0xFFFF9800); // Orange
        statusBgColor = const Color(0xFFFFF3E0);
        statusDisplayLabel = 'upcoming'.tr;
        break;
      case 'INPROGRESS':
        statusColor = const Color(0xFF039BE5); // Light Blue
        statusBgColor = const Color(0xFFE1F5FE);
        statusDisplayLabel = 'in_progress'.tr;
        break;
      case 'ARRIVED':
        statusColor = const Color(0xFF9C27B0); // Purple
        statusBgColor = const Color(0xFFF3E5F5);
        statusDisplayLabel = 'arrived'.tr;
        break;
      case 'COMPLETE':
        statusColor = const Color(0xFF4CAF50); // Green
        statusBgColor = const Color(0xFFE8F5E9);
        statusDisplayLabel = 'completed'.tr;
        break;
      case 'CANCELLED':
        statusColor = const Color(0xFFEF5350); // Red
        statusBgColor = const Color(0xFFFFEBEE);
        statusDisplayLabel = 'cancelled'.tr;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey[200]!;
    }

    final patientUser = apt.patient?.user;
    final patientName = patientUser?.fullName ?? 'unknown'.tr;
    final patientImage = patientUser?.profileImage ?? '';
    final timeRange =
        "${_formatTime(apt.startTime)} - ${_formatTime(apt.endTime)}";
    final dateFormatted = _formatDate(apt.consultDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffF9F9FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Status Badge and Queue Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: statusColor),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusDisplayLabel,
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffF9F9FB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xff137CCF)),
                ),
                child: Text(
                  '${'queue'.tr} #${apt.serialNumber ?? 0}',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff137CCF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Patient Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: patientImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(patientImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[200],
                ),
                child: patientImage.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          color: Color(0xff636F85),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$timeRange $dateFormatted',
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff636F85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons for INPROGRESS status
          if (statusValue == 'INPROGRESS') ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showCancelConfirmationDialog(
                        context,
                        apt.id ?? '',
                        controller,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.red, width: 1.5),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmAppointmentDialog(
                        context,
                        apt.id ?? '',
                        controller,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'confirm'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Action Button or Review
          if (statusValue == 'COMPLETE') ...[
            Column(
              children: [
                Divider(color: Color(0xffE2E8F0), thickness: 1),
                Row(
                  children: [
                    Text(
                      'review'.tr,
                      style: globalTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff2D2D2D),
                      ),
                    ),
                    const Spacer(),
                    if (apt.doctorRatings != null &&
                        apt.doctorRatings!.isNotEmpty)
                      Row(
                        children: List.generate(
                          apt.doctorRatings!.first.rating ?? 0,
                          (index) => Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: SvgPicture.asset(
                              IconsPath.star,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                Colors.amber,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Removed _showStatusUpdateDialog as it is no longer needed

  String _formatTime(String? time) {
    if (time == null) return "";
    try {
      final cleanTime = time.contains('.') ? time.split('.').first : time;
      DateTime dt;
      try {
        dt = DateFormat("HH:mm:ss").parse(cleanTime);
      } catch (e) {
        dt = DateFormat("HH:mm").parse(cleanTime);
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
      final dayName = DateFormat('E').format(dt).toLowerCase(); // e.g. tue
      final monthName = DateFormat('MMM').format(dt).toLowerCase(); // e.g. feb
      final dayNum = dt.day;

      return "${dayName.tr}, ${monthName.tr} $dayNum";
    } catch (e) {
      return dateStr;
    }
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    String bookingId,
    DoctorAppointmentController controller,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
            'cancel_appointment_confirmation'.tr,
            style: globalTextStyle(
              fontSize: 14,
              color: const Color(0xff636F85),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
                Navigator.of(context).pop();
                controller.updateAppointmentStatus(bookingId, 'CANCELLED');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'yes_cancel'.tr,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmAppointmentDialog(
    BuildContext context,
    String bookingId,
    DoctorAppointmentController controller,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'confirm_appointment'.tr,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xff2D2D2D),
            ),
          ),
          content: Text(
            'confirm_appointment_message'.tr,
            style: globalTextStyle(
              fontSize: 14,
              color: const Color(0xff636F85),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
                Navigator.of(context).pop();
                controller.updateAppointmentStatus(bookingId, 'CONFIRMED');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'yes_confirm'.tr,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
