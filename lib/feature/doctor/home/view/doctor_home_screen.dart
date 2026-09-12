import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/doctor/appointment/model/doctor_appointment_model.dart';
import 'package:nabeelaljirbi_app/feature/doctor/home/controller/doctor_home_screen_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/nav_bar/controller/doctor_nav_bar_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorHomeScreenController());
    final navController = Get.find<DoctorNavBarController>();
    final profileController = Get.put(DoctorProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.getHomeData(),
          color: AppColors.primaryColor,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, profileController),
                const SizedBox(height: 10),
                Divider(
                  color: Color(0xffE5E9F2).withValues(alpha: 0.7),
                  thickness: 8,
                ),
                const SizedBox(height: 16),
                _buildStatistics(controller),
                const SizedBox(height: 16),
                Divider(
                  color: Color(0xffE5E9F2).withValues(alpha: 0.7),
                  thickness: 8,
                ),
                const SizedBox(height: 16),
                _buildSectionHeader(navController),
                const SizedBox(height: 16),
                _buildTabFilters(controller),
                const SizedBox(height: 16),
                _buildAppointmentList(controller),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DoctorProfileController profileController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    profileController.profileImage.value.isNotEmpty
                        ? profileController.profileImage.value
                        : 'https://img.freepik.com/free-photo/portrait-smiling-handsome-male-doctor-man_171337-1491.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'welcome'.tr}, ${profileController.name.value}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: globalTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(IconsPath.star, width: 12, height: 12),
                        const SizedBox(width: 4),
                        Text(
                          profileController.doctorProfile.value?.weightedRating
                                  ?.toStringAsFixed(1) ??
                              '0.0',
                          style: globalTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff2D2D2D),
                          ),
                        ),
                        Text(
                          '  (${profileController.doctorProfile.value?.reviewCount ?? 0})',
                          style: globalTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.doctorNotification),
            child: SvgPicture.asset(
              IconsPath.notification,
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(DoctorHomeScreenController controller) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                controller.totalBook.value.toString(),
                'total_book'.tr,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                controller.todayCount.value.toString(),
                'today'.tr,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                controller.upcomingCount.value.toString(),
                'upcoming'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String count, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffE5E9F2), width: 1),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: globalTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0Xff2D2D2D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: globalTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xff636F85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(DoctorNavBarController navController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'todays_appointments'.tr,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0Xff2D2D2D),
            ),
          ),
          GestureDetector(
            onTap: () {
              navController.changeTab(1);
            },
            child: Text(
              'view_all'.tr,
              style: globalTextStyle(
                color: Color(0xff636F85),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabFilters(DoctorHomeScreenController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        final pendingCount = controller.appointments
            .where((a) => a.status?.toUpperCase() == 'PENDING')
            .length;
        final upcomingCount = controller.appointments
            .where((a) =>
                a.status?.toUpperCase() == 'CONFIRMED' ||
                a.status?.toUpperCase() == 'INPROGRESS')
            .length;
        final arrivedCount = controller.appointments
            .where((a) => a.status?.toUpperCase() == 'ARRIVED')
            .length;
        final completedCount = controller.appointments
            .where((a) => a.status?.toUpperCase() == 'COMPLETE')
            .length;

        return Row(
          children: [
            Expanded(
              child: _buildTabButton(
                '${'pending'.tr} ($pendingCount)',
                0,
                controller.selectedTab.value == 0,
                () => controller.selectTab(0),
              ),
            ),
            Expanded(
              child: _buildTabButton(
                '${'upcoming'.tr} ($upcomingCount)',
                1,
                controller.selectedTab.value == 1,
                () => controller.selectTab(1),
              ),
            ),
            Expanded(
              child: _buildTabButton(
                '${'arrived'.tr} ($arrivedCount)',
                2,
                controller.selectedTab.value == 2,
                () => controller.selectTab(2),
              ),
            ),
            Expanded(
              child: _buildTabButton(
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

  Widget _buildTabButton(
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

  Widget _buildAppointmentList(DoctorHomeScreenController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }
      final appointments = controller.filteredAppointments;
      if (appointments.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'no_appointments'.tr,
              style: globalTextStyle(
                fontSize: 14,
                color: const Color(0xff636F85),
              ),
            ),
          ),
        );
      }
      return Column(
        children: appointments
            .map((apt) => _buildAppointmentCard(apt, controller))
            .toList(),
      );
    });
  }

  Widget _buildAppointmentCard(
    Appointment apt,
    DoctorHomeScreenController controller,
  ) {
    return Builder(
      builder: (context) {
        Color statusColor;
        final statusValue = apt.status?.toUpperCase() ?? 'PENDING';

        String statusDisplayLabel = "";
        switch (statusValue) {
          case 'COMPLETE':
            statusColor = const Color(0xFF4CAF50); // Green
            statusDisplayLabel = 'completed'.tr;
            break;
          case 'ARRIVED':
            statusColor = const Color(0xFF9C27B0); // Purple
            statusDisplayLabel = 'arrived'.tr;
            break;
          case 'CONFIRMED':
            statusColor = const Color(0xFFFF9800); // Orange
            statusDisplayLabel = 'upcoming'.tr;
            break;
          case 'INPROGRESS':
          case 'PENDING':
            statusColor = const Color(0xffFAAD14);
            statusDisplayLabel = statusValue.toLowerCase().tr;
            break;
          default:
            statusColor = Colors.grey;
            statusDisplayLabel = statusValue.toLowerCase().tr;
        }

        final patientUser = apt.patient?.user;
        final patientName = patientUser?.fullName ?? 'N/A';
        final patientImage = patientUser?.profileImage ?? '';
        final timeRange =
            "${_formatTime(apt.startTime)} - ${_formatTime(apt.endTime)}";
        final dateFormatted = _formatDate(apt.consultDate);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffF9F9FB),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
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
                        color: const Color(0xffF9F9FB),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        patientImage,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey[200],
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
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
                              color: const Color(0xff2D2D2D),
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
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(String? time) {
    if (time == null) return "";
    try {
      final cleanTime = time.split('.').first;
      final dt = DateFormat("HH:mm").parse(cleanTime);
      return DateFormat("h a").format(dt);
    } catch (e) {
      return time;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat("EEEE, MMM dd").format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    String bookingId,
    DoctorHomeScreenController controller,
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
    DoctorHomeScreenController controller,
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
