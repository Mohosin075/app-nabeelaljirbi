import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/clinic/doctors/controller/clinic_doctor_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/model/doctor_details_model.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/widget/doctor_timings_bottom_sheet.dart';
import '../../home/widget/appointment_card.dart';
import '../controller/clinic_doctor_details_controller.dart';
import '../model/clinic_doctor_model.dart';

class ClinicDoctorDetailsScreen extends StatelessWidget {
  final ClinicDoctorItem doctor;

  const ClinicDoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClinicDoctorDetailsController());
    controller.setDoctor(doctor);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 14, bottom: 14),
            child: SvgPicture.asset(IconsPath.backArrow),
          ),
        ),
        title: Text(
          'doctor_details'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('remove_doctor'.tr),
                  content: Text('are_you_sure_remove_doctor'.tr),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('no'.tr),
                    ),
                    TextButton(
                      onPressed: () async {
                        Get.back(); // Close the dialog
                        if (doctor.doctorId != null) {
                          final success = await controller.removeDoctor(
                            doctor.doctorId!,
                          );
                          if (success) {
                            // Navigate back to the list screen FIRST
                            Get.back();

                            // Now refresh the list and show success message
                            final docController =
                                Get.find<ClinicDoctorController>();
                            docController.fetchDoctors(isRefresh: true);

                            Get.snackbar(
                              'success'.tr,
                              'doctor_removed_successfully'.tr,
                              backgroundColor: AppColors.primaryColor,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'error'.tr,
                              'failed_to_remove_doctor'.tr,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        } else {
                          Get.snackbar(
                            'error'.tr,
                            'could_not_remove_doctor_id_missing'.tr,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Text('yes'.tr),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: globalTextStyle(color: Colors.red),
              ),
            );
          }

          final detail = controller.doctorDetails.value;
          if (detail == null) {
            return Center(child: Text('no_details_found'.tr));
          }

          return Column(
            children: [
              _buildDoctorInfoCard(detail),
              _buildStatsRow(detail),
              _buildTabBar(controller),
              Expanded(
                child: Obx(() {
                  if (controller.selectedTabIndex.value == 0) {
                    return _buildAboutTab(controller, detail, context);
                  } else {
                    return _buildAppointmentTab(controller);
                  }
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDoctorInfoCard(DoctorDetailData detail) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: detail.profileImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      detail.profileImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person, color: Color(0xFF64748B), size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          detail.name ?? '',
                          style: globalTextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        // Assuming online status is true or can be handled if API provides it
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${CurrencyUtil.getUserCurrencySymbol()} ${detail.consultFee ?? 0}',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.specialty ?? '',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DoctorDetailData detail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            IconsPath.personalCardValue,
            detail.experience ?? 'na'.tr,
            'year_of_work'.tr,
          ),
          _buildStatItem(
            IconsPath.ratingBadge,
            '${detail.rating ?? 0}',
            'rating'.tr,
          ),
          _buildStatItem(
            IconsPath.moneyValue,
            '${CurrencyUtil.getUserCurrencySymbol()} ${detail.consultFee ?? 0}',
            'per_session'.tr,
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String icon,
    String value,
    String label, {
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isHighlighted
                    ? const Color(0xFF137CCF)
                    : const Color(0xFF64748B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isHighlighted
                    ? const Color(0xFF137CCF)
                    : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: globalTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ClinicDoctorDetailsController controller) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Obx(
        () => Row(
          children: [
            _buildTabItem('about'.tr, 0, controller),
            _buildTabItem('appointment'.tr, 1, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    String title,
    int index,
    ClinicDoctorDetailsController controller,
  ) {
    final isSelected = controller.selectedTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTabIndex(index),
        child: Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF137CCF)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF137CCF)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab(
    ClinicDoctorDetailsController controller,
    DoctorDetailData detail,
    BuildContext context,
  ) {
    final schedules = detail.schedule;
    final hasSchedule = schedules != null && schedules.isNotEmpty;

    // Find schedule for today
    final today = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    ScheduleDay? displaySchedule;
    bool isToday = false;

    if (hasSchedule) {
      try {
        displaySchedule = schedules.firstWhere(
          (element) => element.day?.toLowerCase() == today,
        );
        isToday = true;
      } catch (e) {
        displaySchedule = schedules.first;
      }
    }

    String startTime = 'na'.tr;
    String endTime = 'na'.tr;

    if (displaySchedule != null &&
        displaySchedule.slots != null &&
        displaySchedule.slots!.isNotEmpty) {
      final firstSlot = displaySchedule.slots!.first;

      startTime = _formatTime(firstSlot.startTime ?? 'na'.tr);
      endTime = _formatTime(firstSlot.endTime ?? 'na'.tr);
    }

    final dayLabel = hasSchedule
        ? (isToday
              ? 'schedule_today'.tr
              : '${'schedule'.tr} (${(displaySchedule?.day?.toLowerCase() ?? '').tr})')
        : 'working_hours'.tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule Section
          Text(
            dayLabel,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (hasSchedule)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF137CCF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset(
                          IconsPath.clock,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFFFFFF),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          startTime,
                          style: globalTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'to'.tr,
                        style: globalTextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          endTime,
                          style: globalTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            DoctorTimingsBottomSheet(schedules: schedules),
                      );
                    },
                    child: Text(
                      'view_full_timings'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF137CCF),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Text(
                'no_schedule_available'.tr,
                textAlign: TextAlign.center,
                style: globalTextStyle(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          const SizedBox(height: 24),
          // About Doctor Section
          Text(
            'about_doctor'.tr,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.about ?? 'no_bio_available'.tr,
                  maxLines: controller.isExpanded.value ? null : 4,
                  overflow: controller.isExpanded.value
                      ? null
                      : TextOverflow.ellipsis,
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    lineHeight: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                if ((detail.about ?? '').length > 100)
                  GestureDetector(
                    onTap: controller.toggleExpanded,
                    child: Text(
                      controller.isExpanded.value
                          ? 'show_less'.tr
                          : 'read_more'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF137CCF),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAppointmentTab(ClinicDoctorDetailsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'appointment'.tr,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          // Status Tabs
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: controller.appointmentTabs.map((tab) {
                    final isSelected =
                        controller.selectedAppointmentTab.value == tab;
                    final count = controller.getAppointmentCountByTab(tab);
                    return GestureDetector(
                      onTap: () => controller.changeAppointmentTab(tab),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF137CCF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${tab.tr} ($count)',
                            style: globalTextStyle(
                              fontSize: 12,
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
          ),
          const SizedBox(height: 16),
          // Appointments List
          Obx(() {
            if (controller.isLoadingAppointments.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            }

            final appointments = controller.filteredAppointments;
            if (appointments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 48,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_appointments_found'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
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
          }),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    if (time == 'na'.tr) return time;
    try {
      DateTime dateTime;
      try {
        dateTime = DateFormat("HH:mm:ss").parse(time);
      } catch (e) {
        dateTime = DateFormat("HH:mm").parse(time);
      }

      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour >= 12 ? 'pm'.tr : 'am'.tr;
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return "$hour12:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      return time;
    }
  }
}
