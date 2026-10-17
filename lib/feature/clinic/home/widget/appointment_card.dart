import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import '../model/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final Function? onUpdateStatus;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onUpdateStatus,
  });

  void _invokeUpdateStatus(String id, String status, {String? reason}) {
    if (onUpdateStatus == null) return;
    try {
      (onUpdateStatus as dynamic)(id, status, reason: reason);
    } catch (_) {
      try {
        (onUpdateStatus as dynamic)(id, status);
      } catch (e) {
        debugPrint('Error invoking status update: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Status badge & Queue Number / Estimated Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(appointment.status),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF137CCF).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${'queue_label'.tr} #${appointment.queueNo}',
                      style: globalTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF137CCF),
                      ),
                    ),
                  ),
                  if (appointment.approximateEstimatedTime != null &&
                      appointment.approximateEstimatedTime!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD97706).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '~${appointment.approximateEstimatedTime}',
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

          // Patient Information Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF1F5F9),
                child: appointment.patientImage != null &&
                        appointment.patientImage!.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: appointment.patientImage!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      )
                    : const Icon(Icons.person, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: globalTextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if ((appointment.bookedFor == 'FAMILY' ||
                            appointment.bookedFor == 'FAMILY_MEMBER') &&
                        appointment.familyMemberName != null) ...[
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
                            color:
                                const Color(0xFF7C3AED).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '${'booked_for_family'.tr}: ${appointment.familyMemberName} (${appointment.familyMemberRelation ?? ''})',
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
                          Icons.access_time_rounded,
                          size: 15,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${appointment.time}  •  ${appointment.date}',
                          style: globalTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.doctorName,
                      style: globalTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                if (appointment.clinicName != null &&
                    appointment.clinicName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${appointment.clinicName}${appointment.clinicLocation != null ? ' - ${appointment.clinicLocation}' : ''}',
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
                ],
              ],
            ),
          ),

          // Reason display for No Show, Cancelled, Rejected
          if (_hasReason()) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: appointment.status == AppointmentStatus.notShown
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: appointment.status == AppointmentStatus.notShown
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
                    color: appointment.status == AppointmentStatus.notShown
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
                              color: appointment.status ==
                                      AppointmentStatus.notShown
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF991B1B),
                            ),
                          ),
                          TextSpan(
                            text: appointment.cancellationReason ??
                                appointment.rejectionReason ??
                                'N/A',
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: appointment.status ==
                                      AppointmentStatus.notShown
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

          // Actions according to core lifecycle
          if (onUpdateStatus != null) ...[
            const SizedBox(height: 14),
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  bool _hasReason() {
    return (appointment.status == AppointmentStatus.notShown ||
            appointment.status == AppointmentStatus.cancelled ||
            appointment.status == AppointmentStatus.rejected) &&
        ((appointment.cancellationReason != null &&
                appointment.cancellationReason!.isNotEmpty) ||
            (appointment.rejectionReason != null &&
                appointment.rejectionReason!.isNotEmpty));
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _promptReasonDialog(
                context,
                title: 'reject_appointment_title'.tr,
                actionLabel: 'yes_reject'.tr,
                actionColor: const Color(0xFFEF4444),
                onConfirm: (reason) =>
                    _invokeUpdateStatus(appointment.id, 'REJECTED', reason: reason),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(
                'reject'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _confirmDialog(
                context,
                title: 'confirm_appointment_title'.tr,
                message: 'confirm_appointment_message'.tr,
                actionLabel: 'yes_confirm'.tr,
                actionColor: const Color(0xFF137CCF),
                onConfirm: () =>
                    _invokeUpdateStatus(appointment.id, 'CONFIRMED'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137CCF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(
                'confirm'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );

      case AppointmentStatus.confirmed:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _promptReasonDialog(
                context,
                title: 'cancel_appointment_title'.tr,
                actionLabel: 'yes_cancel'.tr,
                actionColor: const Color(0xFFEF4444),
                onConfirm: (reason) =>
                    _invokeUpdateStatus(appointment.id, 'CANCELLED', reason: reason),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'cancel'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () => _promptReasonDialog(
                context,
                title: 'no_show_appointment_title'.tr,
                actionLabel: 'yes_mark_no_show'.tr,
                actionColor: const Color(0xFFD97706),
                showNotice: true,
                onConfirm: (reason) =>
                    _invokeUpdateStatus(appointment.id, 'NOT_SHOW', reason: reason),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD97706)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'no_show'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD97706),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmDialog(
                context,
                title: 'mark_arrived'.tr,
                message: 'update_status_arrived_message'.tr,
                actionLabel: 'yes_update'.tr,
                actionColor: const Color(0xFF7C3AED),
                onConfirm: () =>
                    _invokeUpdateStatus(appointment.id, 'ARRIVED'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'mark_arrived'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmDialog(
                context,
                title: 'start_consultation'.tr,
                message: 'start_consultation_message'.tr,
                actionLabel: 'yes_start'.tr,
                actionColor: const Color(0xFF137CCF),
                onConfirm: () =>
                    _invokeUpdateStatus(appointment.id, 'INPROGRESS'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137CCF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'start_consultation'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );

      case AppointmentStatus.arrived:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _promptReasonDialog(
                context,
                title: 'no_show_appointment_title'.tr,
                actionLabel: 'yes_mark_no_show'.tr,
                actionColor: const Color(0xFFD97706),
                showNotice: true,
                onConfirm: (reason) =>
                    _invokeUpdateStatus(appointment.id, 'NOT_SHOW', reason: reason),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD97706)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'no_show'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD97706),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _confirmDialog(
                context,
                title: 'start_consultation'.tr,
                message: 'start_consultation_message'.tr,
                actionLabel: 'yes_start'.tr,
                actionColor: const Color(0xFF137CCF),
                onConfirm: () =>
                    _invokeUpdateStatus(appointment.id, 'INPROGRESS'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137CCF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'start_consultation'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            // One-tap complete
            ElevatedButton(
              onPressed: () =>
                  _invokeUpdateStatus(appointment.id, 'COMPLETE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'complete'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );

      case AppointmentStatus.inProgress:
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => _promptReasonDialog(
                context,
                title: 'cancel_appointment_title'.tr,
                actionLabel: 'yes_cancel'.tr,
                actionColor: const Color(0xFFEF4444),
                onConfirm: (reason) =>
                    _invokeUpdateStatus(appointment.id, 'CANCELLED', reason: reason),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'cancel'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () => _promptReasonDialog(
                context,
                title: 'no_show_appointment_title'.tr,
                actionLabel: 'yes_mark_no_show'.tr,
                actionColor: const Color(0xFFD97706),
                showNotice: true,
                onConfirm: (reason) =>
                    _invokeUpdateStatus(appointment.id, 'NOT_SHOW', reason: reason),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD97706)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'no_show'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD97706),
                ),
              ),
            ),
            // One-tap complete
            ElevatedButton(
              onPressed: () =>
                  _invokeUpdateStatus(appointment.id, 'COMPLETE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'complete'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          message,
          style: globalTextStyle(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'no'.tr,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              actionLabel,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _promptReasonDialog(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required Color actionColor,
    bool showNotice = false,
    required Function(String reason) onConfirm,
  }) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showNotice)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'reason_stays_visible_to_patient'.tr,
                        style: globalTextStyle(
                          fontSize: 12,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            TextField(
              controller: textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'enter_reason'.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = textController.text.trim();
              if (reason.isEmpty) {
                Get.snackbar('error'.tr, 'please_enter_reason'.tr);
                return;
              }
              Get.back();
              onConfirm(reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              actionLabel,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color color;
    String text;
    Color bgColor;

    switch (status) {
      case AppointmentStatus.pending:
        color = const Color(0xFF2563EB);
        text = 'pending'.tr;
        bgColor = const Color(0xFFEFF6FF);
        break;
      case AppointmentStatus.confirmed:
        color = const Color(0xFF0284C7);
        text = 'confirmed'.tr;
        bgColor = const Color(0xFFE0F2FE);
        break;
      case AppointmentStatus.arrived:
        color = const Color(0xFF7C3AED);
        text = 'arrived'.tr;
        bgColor = const Color(0xFFF5F3FF);
        break;
      case AppointmentStatus.inProgress:
        color = const Color(0xFF0D9488);
        text = 'in_progress'.tr;
        bgColor = const Color(0xFFCCFBF1);
        break;
      case AppointmentStatus.notShown:
        color = const Color(0xFFD97706);
        text = 'no_show'.tr;
        bgColor = const Color(0xFFFEF3C7);
        break;
      case AppointmentStatus.notUpdated:
        color = const Color(0xFF64748B);
        text = 'unresolved'.tr;
        bgColor = const Color(0xFFF1F5F9);
        break;
      case AppointmentStatus.completed:
        color = const Color(0xFF10B981);
        text = 'completed'.tr;
        bgColor = const Color(0xFFD1FAE5);
        break;
      case AppointmentStatus.rejected:
        color = const Color(0xFFDC2626);
        text = 'rejected'.tr;
        bgColor = const Color(0xFFFEE2E2);
        break;
      case AppointmentStatus.cancelled:
        color = const Color(0xFFEF4444);
        text = 'cancelled'.tr;
        bgColor = const Color(0xFFFEE2E2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 3.5, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: globalTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
