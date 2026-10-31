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
            const SizedBox(height: 8),
            Divider(
              color: const Color(0xffE5E9F2).withValues(alpha: 0.7),
              thickness: 6,
            ),
            const SizedBox(height: 12),
            _buildTabs(controller),
            const SizedBox(height: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (Navigator.of(context).canPop())
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (Navigator.of(context).canPop()) const SizedBox(width: 8),
              Obx(() {
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
            ],
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
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() {
        final pendingCount = controller.allAppointments
            .where((apt) => apt.status?.toUpperCase() == 'PENDING')
            .length;
        final confirmedCount = controller.allAppointments
            .where((apt) => apt.status?.toUpperCase() == 'CONFIRMED')
            .length;
        final arrivedCount = controller.allAppointments
            .where((apt) => apt.status?.toUpperCase() == 'ARRIVED')
            .length;
        final inProgressCount = controller.allAppointments
            .where((apt) => apt.status?.toUpperCase() == 'INPROGRESS')
            .length;
        final completedCount = controller.allAppointments
            .where(
              (apt) =>
                  apt.status?.toUpperCase() == 'COMPLETE' ||
                  apt.status?.toUpperCase() == 'COMPLETED',
            )
            .length;
        final noShowCount = controller.allAppointments
            .where(
              (apt) =>
                  apt.status?.toUpperCase() == 'NOT_SHOW' ||
                  apt.status?.toUpperCase() == 'NOTSHOWN' ||
                  apt.status?.toUpperCase() == 'NOT_SHOWN' ||
                  apt.status?.toUpperCase() == 'NO_SHOW',
            )
            .length;
        final cancelledCount = controller.allAppointments
            .where(
              (apt) =>
                  apt.status?.toUpperCase() == 'CANCELLED' ||
                  apt.status?.toUpperCase() == 'REJECTED',
            )
            .length;

        final tabsData = [
          {'label': 'pending'.tr, 'count': pendingCount, 'index': 0},
          {'label': 'confirmed'.tr, 'count': confirmedCount, 'index': 1},
          {'label': 'arrived'.tr, 'count': arrivedCount, 'index': 2},
          {'label': 'in_progress'.tr, 'count': inProgressCount, 'index': 3},
          {'label': 'completed'.tr, 'count': completedCount, 'index': 4},
          {'label': 'no_show'.tr, 'count': noShowCount, 'index': 5},
          {'label': 'cancelled'.tr, 'count': cancelledCount, 'index': 6},
        ];

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tabsData.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final tab = tabsData[index];
            final tabIndex = tab['index'] as int;
            final isSelected = controller.selectedTab.value == tabIndex;
            return GestureDetector(
              onTap: () => controller.selectTab(tabIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xff137CCF)
                      : const Color(0xffEDEEF4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tab['label']} (${tab['count']})',
                  style: globalTextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xff636F85),
                  ),
                ),
              ),
            );
          },
        );
      }),
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
                    height: MediaQuery.of(Get.context!).size.height * 0.5,
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
    String statusDisplayLabel;

    switch (statusValue) {
      case 'PENDING':
        statusColor = const Color(0xFF2563EB);
        statusBgColor = const Color(0xFFEFF6FF);
        statusDisplayLabel = 'pending'.tr;
        break;
      case 'CONFIRMED':
        statusColor = const Color(0xFF0284C7);
        statusBgColor = const Color(0xFFE0F2FE);
        statusDisplayLabel = 'confirmed'.tr;
        break;
      case 'ARRIVED':
        statusColor = const Color(0xFF7C3AED);
        statusBgColor = const Color(0xFFF5F3FF);
        statusDisplayLabel = 'arrived'.tr;
        break;
      case 'INPROGRESS':
        statusColor = const Color(0xFF0D9488);
        statusBgColor = const Color(0xFFCCFBF1);
        statusDisplayLabel = 'in_progress'.tr;
        break;
      case 'COMPLETE':
      case 'COMPLETED':
        statusColor = const Color(0xFF10B981);
        statusBgColor = const Color(0xFFD1FAE5);
        statusDisplayLabel = 'completed'.tr;
        break;
      case 'NOT_SHOW':
      case 'NOTSHOWN':
      case 'NOT_SHOWN':
      case 'NO_SHOW':
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        statusDisplayLabel = 'no_show'.tr;
        break;
      case 'CANCELLED':
        statusColor = const Color(0xFFEF4444);
        statusBgColor = const Color(0xFFFEE2E2);
        statusDisplayLabel = apt.absenceType == 'DOCTOR_ABSENT'
            ? (Get.locale?.languageCode == 'ar'
                  ? 'غياب الطبيب'
                  : 'Doctor absent')
            : 'cancelled'.tr;
        break;
      case 'REJECTED':
        statusColor = const Color(0xFFDC2626);
        statusBgColor = const Color(0xFFFEE2E2);
        statusDisplayLabel = 'rejected'.tr;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey[200]!;
        statusDisplayLabel = statusValue;
    }

    final patientUser = apt.patient?.user;
    final patientName = patientUser?.fullName ?? 'unknown'.tr;
    final patientImage = patientUser?.profileImage ?? '';
    final timeRange =
        "${_formatTime(apt.startTime)} - ${_formatTime(apt.endTime)}";
    final dateFormatted = _formatDate(apt.consultDate);

    final hasReason =
        (statusValue == 'NOT_SHOW' ||
            statusValue == 'NOTSHOWN' ||
            statusValue == 'CANCELLED' ||
            statusValue == 'REJECTED') &&
        ((apt.cancellationReason != null &&
                apt.cancellationReason!.isNotEmpty) ||
            (apt.rejectionReason != null && apt.rejectionReason!.isNotEmpty));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Header Row: Status Badge and Queue Number / Estimated Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3.5, backgroundColor: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusDisplayLabel,
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF0F7FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xff137CCF).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${'queue_label'.tr} #${apt.serialNumber ?? 0}',
                      style: globalTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff137CCF),
                      ),
                    ),
                  ),
                  if (apt.approximateEstimatedTime != null &&
                      apt.approximateEstimatedTime!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD97706).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '~${apt.approximateEstimatedTime}',
                        style: globalTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

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
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff1E293B),
                      ),
                    ),
                    if ((apt.bookedFor == 'FAMILY' ||
                            apt.bookedFor == 'FAMILY_MEMBER') &&
                        apt.familyMemberName != null) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(
                              0xFF7C3AED,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '${'booked_for_family'.tr}: ${apt.familyMemberName} (${apt.familyMemberRelation ?? ''})',
                          style: globalTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6D28D9),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          color: Color(0xff636F85),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$timeRange  •  $dateFormatted',
                          style: globalTextStyle(
                            fontSize: 13,
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

          if (apt.clinic != null && apt.clinic!.clinicName != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 60),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${apt.clinic!.clinicName}${apt.clinic!.location != null ? ' - ${apt.clinic!.location}' : ''}',
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Reason display for No Show, Cancelled, Rejected
          if (hasReason) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusValue.contains('SHOW')
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusValue.contains('SHOW')
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: statusValue.contains('SHOW')
                        ? const Color(0xFFD97706)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${'reason_label'.tr}: ',
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusValue.contains('SHOW')
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF991B1B),
                            ),
                          ),
                          TextSpan(
                            text:
                                apt.cancellationReason ??
                                apt.rejectionReason ??
                                '',
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: statusValue.contains('SHOW')
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Booking status is managed by the clinic. Doctor views are read-only.
          const SizedBox(height: 14),
          Text(
            'booking_status_managed_by_clinic'.tr,
            style: globalTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),

          // Rating display if Complete
          if ((statusValue == 'COMPLETE' || statusValue == 'COMPLETED') &&
              apt.doctorRatings != null &&
              apt.doctorRatings!.isNotEmpty) ...[
            const Divider(color: Color(0xffE2E8F0), thickness: 1),
            Row(
              children: [
                Text(
                  'review'.tr,
                  style: globalTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff2D2D2D),
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    apt.doctorRatings!.first.rating ?? 0,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SvgPicture.asset(
                        IconsPath.star,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
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
        ],
      ),
    );
  }

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
      final dayName = DateFormat('E').format(dt).toLowerCase();
      final monthName = DateFormat('MMM').format(dt).toLowerCase();
      final dayNum = dt.day;

      return "${dayName.tr}, ${monthName.tr} $dayNum";
    } catch (e) {
      return dateStr;
    }
  }
}
