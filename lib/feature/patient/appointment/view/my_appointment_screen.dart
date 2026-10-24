import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/controller/appointment_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/model/appointment_history_model.dart';
import 'package:nabeelaljirbi_app/feature/patient/appointment/widget/review_bottom_sheet.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/view/patient_help_center_screen.dart';

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
        leading: IconButton(
          icon: SvgPicture.asset(
            IconsPath.backArrow,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.patientNavBar);
            }
          },
        ),
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
                      .where((apt) {
                        final s = apt.status?.toUpperCase() ?? '';
                        return s == 'CANCELLED' || s == 'REJECTED' || s == 'NOT_SHOW';
                      })
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
                      if (status == 'COMPLETE' ||
                          status == 'COMPLETED' ||
                          status == 'CANCELLED' ||
                          status == 'REJECTED' ||
                          status == 'NOT_SHOW') {
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
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
                    const SizedBox(width: 8),
                    _buildComplaintButton(context, apt),
                  ],
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
            if (apt.clinic?.location != null && apt.clinic!.location!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Color(0xFF636F85),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${apt.clinic?.clinicName != null ? '${apt.clinic!.clinicName} - ' : ''}${apt.clinic!.location}',
                      style: globalTextStyle(
                        fontSize: 12,
                        color: const Color(0xff636F85),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (apt.approximateEstimatedTime != null &&
                apt.approximateEstimatedTime!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD0EBFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${'approx_est_time'.tr}: ${_formatTime(apt.approximateEstimatedTime)} (${'estimate'.tr})',
                      style: globalTextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                              _showCancelConfirmationDialog(
                                context,
                                apt.id!,
                                isConfirmed: false,
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
                                        controller.markAppointmentArrived(apt.id!);
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Builder(builder: (context) {
                  final hoursUntil = _calculateHoursUntilAppointment(apt);
                  final canCancel = hoursUntil >= 12.0;

                  return Obx(() {
                    final isCancelling =
                        controller.cancellingAppointmentId.value == apt.id;
                    return OutlinedButton(
                      onPressed: isCancelling
                          ? null
                          : () {
                              if (!canCancel) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      'cancellation_locked_title'.tr,
                                      style: globalTextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xff2D2D2D),
                                      ),
                                    ),
                                    content: Text(
                                      'cancellation_locked_desc'.tr,
                                      style: globalTextStyle(
                                        fontSize: 14,
                                        color: const Color(0xff636F85),
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryColor,
                                        ),
                                        child: Text(
                                          'ok'.tr,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              if (apt.id != null) {
                                _showCancelConfirmationDialog(
                                  context,
                                  apt.id!,
                                  isConfirmed: true,
                                );
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: canCancel
                              ? Colors.red.shade300
                              : const Color(0xFFE5E9F2),
                        ),
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
                              canCancel
                                  ? 'cancel_appointment'.tr
                                  : '${'cancel_appointment'.tr} (<12h ${'locked'.tr.isNotEmpty ? 'locked'.tr : 'Locked'})',
                              style: globalTextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: canCancel
                                    ? Colors.red.shade700
                                    : const Color(0xffA0AEC0),
                              ),
                            ),
                    );
                  });
                }),
              ),
            ],
            if (apt.bookedFor == 'FAMILY' &&
                apt.familyMemberName?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _buildAppointmentInfo(
                'booked_for_family'.tr,
                '${apt.familyMemberName}${apt.familyMemberRelation?.isNotEmpty == true ? ' (${apt.familyMemberRelation})' : ''}',
                Icons.family_restroom,
              ),
            ],
            if (apt.noShowReason?.isNotEmpty == true ||
                apt.rejectionReason?.isNotEmpty == true ||
                apt.cancellationReason?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              _buildAppointmentInfo(
                apt.noShowReason?.isNotEmpty == true
                    ? 'no_show_reason'.tr
                    : apt.rejectionReason?.isNotEmpty == true
                        ? 'rejection_reason'.tr
                        : 'cancellation_reason'.tr,
                apt.noShowReason?.isNotEmpty == true
                    ? apt.noShowReason!
                    : apt.rejectionReason?.isNotEmpty == true
                        ? apt.rejectionReason!
                        : apt.cancellationReason!,
                Icons.info_outline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentInfo(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF636F85)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $value',
            style: globalTextStyle(fontSize: 12, color: const Color(0xff636F85)),
          ),
        ),
      ],
    );
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    String appointmentId, {
    required bool isConfirmed,
  }) {
    final reasonController = TextEditingController();
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isConfirmed
                  ? 'cancel_refund_notice'.tr
                  : 'are_you_sure_cancel'.tr,
              style: globalTextStyle(
                fontSize: 14,
                color: const Color(0xff636F85),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'enter_reason'.tr,
                labelText: '${'cancellation_reason'.tr} (${'optional'.tr})',
                labelStyle: globalTextStyle(
                  fontSize: 12,
                  color: const Color(0xff636F85),
                ),
                hintStyle: globalTextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xffE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
              ),
            ),
          ],
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
              final reason = reasonController.text.trim();
              controller.cancelAppointment(
                appointmentId,
                reason: reason.isNotEmpty ? reason : null,
              );
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: TextButton(
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
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
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
                            ),
                          );
                        },
                      ),
                    _buildComplaintButton(context, apt),
                  ],
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
          if (apt.clinic?.location != null && apt.clinic!.location!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Color(0xFF636F85),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${apt.clinic?.clinicName != null ? '${apt.clinic!.clinicName} - ' : ''}${apt.clinic!.location}',
                    style: globalTextStyle(
                      fontSize: 12,
                      color: const Color(0xff636F85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
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
    } else if (statusUpper == 'REJECTED') {
      // Dark Red for rejected
      bgColor = const Color(0xFFFFEBEE);
      dotColor = const Color(0xFFD32F2F);
      borderColor = const Color(0xFFD32F2F);
      label = 'rejected'.tr;
    } else if (statusUpper == 'NOT_SHOW' || statusUpper == 'NO_SHOW') {
      // Orange for no show
      bgColor = const Color(0xFFFFF3E0);
      dotColor = const Color(0xFFF57C00);
      borderColor = const Color(0xFFF57C00);
      label = 'no_show'.tr;
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

  double _calculateHoursUntilAppointment(Appointment apt) {
    if (apt.consultDate == null) return 0;
    try {
      final parsedDate = DateTime.parse(apt.consultDate!);
      int hour = 0;
      int minute = 0;
      if (apt.startTime != null && apt.startTime!.contains(':')) {
        final parts = apt.startTime!.split(':');
        hour = int.tryParse(parts[0]) ?? 0;
        minute = int.tryParse(parts[1]) ?? 0;
      }
      final appointmentMoment = DateTime.utc(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        hour,
        minute,
      );
      final nowUtc = DateTime.now().toUtc();
      return appointmentMoment.difference(nowUtc).inMinutes / 60.0;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildComplaintButton(BuildContext context, Appointment apt) {
    return InkWell(
      onTap: () => _showComplaintBottomSheet(context, apt),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD1D1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flag_outlined,
              size: 13,
              color: Color(0xFFD32F2F),
            ),
            const SizedBox(width: 4),
            Text(
              'complaint'.tr,
              style: globalTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplaintBottomSheet(BuildContext context, Appointment apt) {
    final doctorName = apt.doctor?.user?.fullName ?? 'doctor'.tr;
    final clinicName = apt.clinic?.clinicName ?? '';
    final reasons = [
      'complaint_long_wait',
      'complaint_doctor_absent',
      'complaint_service_quality',
      'complaint_billing_issue',
      'complaint_other',
    ];
    final selectedReason = 'complaint_long_wait'.obs;
    final textController = TextEditingController();
    final isSubmittingComplaint = false.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.flag,
                        color: Color(0xFFD32F2F),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'submit_complaint'.tr,
                        style: globalTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${'consultation_with'.tr} $doctorName ${clinicName.isNotEmpty ? '($clinicName)' : ''}',
                style: globalTextStyle(
                  fontSize: 13,
                  color: const Color(0xff636F85),
                ),
              ),
              const Divider(height: 24),
              Text(
                'complaint_reason'.tr,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reasons.map((reason) {
                      final isSelected = selectedReason.value == reason;
                      return ChoiceChip(
                        label: Text(reason.tr),
                        selected: isSelected,
                        selectedColor: AppColors.primaryColor,
                        labelStyle: globalTextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        onSelected: (val) {
                          if (val) selectedReason.value = reason;
                        },
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 16),
              Text(
                'complaint_desc'.tr,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'enter_complaint_details'.tr,
                  hintStyle: globalTextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: isSubmittingComplaint.value
                        ? null
                        : () async {
                            final desc = textController.text.trim();
                            if (desc.isEmpty) {
                              Get.snackbar(
                                'error'.tr,
                                'enter_complaint_details'.tr,
                              );
                              return;
                            }

                            isSubmittingComplaint.value = true;
                            try {
                              final token = SharedPrefHelper.getAccessToken();
                              final url = '${Urls.baseUrl}/admin/complaints';

                              final response = await http.post(
                                Uri.parse(url),
                                headers: {
                                  'Authorization': token ?? '',
                                  'Content-Type': 'application/json',
                                },
                                body: jsonEncode({
                                  'targetType': 'BOOKING',
                                  'targetId': apt.id,
                                  'bookingId': apt.id,
                                  'subject': selectedReason.value.tr,
                                  'description': desc,
                                }),
                              );

                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                Get.back();
                                final resBody = jsonDecode(response.body);
                                final refId = resBody['data']
                                        ?['complaintNumber'] ??
                                    'CMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                                Get.dialog(
                                  AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'complaint_submitted'.tr,
                                          style: globalTextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      '${'complaint_submitted_desc'.tr} $refId',
                                      style: globalTextStyle(
                                        fontSize: 13,
                                        color: const Color(0xFF636F85),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text('close'.tr),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                          Get.to(
                                            () =>
                                                const PatientHelpCenterScreen(),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                        ),
                                        child: Text(
                                          'contact_support'.tr,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                final resBody = jsonDecode(response.body);
                                Get.snackbar(
                                  'error'.tr,
                                  resBody['message'] ??
                                      'failed_to_submit_complaint'.tr,
                                );
                              }
                            } catch (e) {
                              Get.snackbar(
                                'error'.tr,
                                '${'error_occurred'.tr}: $e',
                              );
                            } finally {
                              isSubmittingComplaint.value = false;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmittingComplaint.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'submit_complaint'.tr,
                            style: globalTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
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
