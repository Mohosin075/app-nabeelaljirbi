import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import '../controller/clinic_home_controller.dart';
import '../controller/notification_controller.dart';
import '../widget/clinic_stats_card.dart';
import '../widget/appointment_card.dart';
import 'clinic_notification_screen.dart';

class ClinicHomeScreen extends StatefulWidget {
  const ClinicHomeScreen({super.key});

  @override
  State<ClinicHomeScreen> createState() => _ClinicHomeScreenState();
}

class _ClinicHomeScreenState extends State<ClinicHomeScreen> {
  final controller = Get.put(ClinicHomeController());
  final profileController = Get.put(ClinicProfileController());

  // @override
  // void initState() {
  //   super.initState();
  //   // Check premium status after profile is loaded
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _checkPremiumStatus();
  //   });
  // }

  // void _checkPremiumStatus() async {
  //   // Check if profile is already loaded
  //   if (profileController.clinicProfile.value != null) {
  //     // Profile already loaded, check immediately
  //     if (!profileController.isPremiumUser) {
  //       profileController.checkPremiumAccess();
  //     }
  //   } else {
  //     // Profile not loaded yet, wait for it
  //     // Use ever to listen for profile changes
  //     final worker = ever(profileController.clinicProfile, (profile) {
  //       if (profile != null && !profileController.isPremiumUser) {
  //         profileController.checkPremiumAccess();
  //       }
  //     });

  //     // Dispose the worker after first check
  //     Future.delayed(const Duration(seconds: 3), () {
  //       worker.dispose();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(profileController),
                const SizedBox(height: 24),
                _buildStats(controller),
                const SizedBox(height: 32),
                _buildTodayAppointmentsHeader(),
                const SizedBox(height: 16),
                _buildTabs(controller),
                const SizedBox(height: 20),
                _buildDoctorFilter(controller),
                const SizedBox(height: 16),
                _buildAppointmentList(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ClinicProfileController controller) {
    final notificationController = Get.put(NotificationController());
    return Obx(() {
      final profile = controller.clinicProfile.value;
      final clinic = profile?.clinic;
      final name = clinic?.managerName ?? 'User';
      final logo = clinic?.logo;
      final rating = clinic?.averageRating ?? 0.0;
      final reviews = clinic?.reviewCount ?? 0;

      final welcomeText = 'welcome_user'.tr;
      final parts = welcomeText.split('@name');
      final prefix = parts.isNotEmpty ? parts[0] : '';
      final suffix = parts.length > 1 ? parts[1] : '';

      return Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFF1F5F9),
            backgroundImage: (logo != null && logo.isNotEmpty)
                ? NetworkImage(logo)
                : null,
            child: (logo == null || logo.isEmpty)
                ? const Icon(Icons.person, color: Color(0xFF64748B))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: prefix,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      lineHeight: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: '\n$name',
                        style: globalTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                          lineHeight: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: suffix,
                        style: globalTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                          lineHeight: 1.2,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($reviews)',
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () => Get.to(() => ClinicNotificationScreen()),
                icon: SvgPicture.asset(
                  IconsPath.notification,
                  width: 24,
                  height: 24,
                ),
              ),
              if (notificationController.hasUnread)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF137CCF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStats(ClinicHomeController controller) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClinicStatsCard(
            label: 'doctors'.tr,
            value: controller.stats.value.doctorCount.toString(),
          ),
          ClinicStatsCard(
            label: 'today'.tr,
            value: controller.stats.value.todayAppointment.toString(),
          ),
          ClinicStatsCard(
            label: 'upcoming'.tr,
            value: controller.stats.value.pendingAppointment.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointmentsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "todays_appointments".tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        Text(
          "view_all".tr,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(ClinicHomeController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(
          () => Row(
            children: controller.tabs.map((tab) {
              final isSelected = controller.selectedTab.value == tab;
              return GestureDetector(
                onTap: () => controller.changeTab(tab),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF137CCF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      tab.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorFilter(ClinicHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "filter_by_doctor".tr,
          style: globalTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedDoctor.value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF64748B),
                ),
                onChanged: controller.changeDoctor,
                items: controller.doctorNames.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentList(ClinicHomeController controller) {
    return Obx(() {
      if (controller.isLoadingAppointments.value &&
          controller.allAppointments.isEmpty) {
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
              'no_appointments_found'.tr,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentCard(
            appointment: appointments[index],
            onUpdateStatus: controller.updateAppointmentStatus,
          );
        },
      );
    });
  }
}
