import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/nav_bar/controller/patient_nav_bar_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/notification/controller/patient_notification_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/notification/model/patient_notification_model.dart';

class PatientNotificationScreen extends StatefulWidget {
  const PatientNotificationScreen({super.key});

  @override
  State<PatientNotificationScreen> createState() =>
      _PatientNotificationScreenState();
}

class _PatientNotificationScreenState extends State<PatientNotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  final PatientNotificationController controller = Get.put(
    PatientNotificationController(),
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleNotificationTap(PatientNotificationItem item) {
    if (item.bookingAppointmentId != null) {
      if (Get.isRegistered<PatientNavBarController>()) {
        final navBarCtrl = Get.find<PatientNavBarController>();
        navBarCtrl.changeTab(1);
        Get.back();
      }
    }
  }

  Color _getBadgeBackgroundColor(String? type) {
    switch (type) {
      case 'BOOKING_CONFIRMED':
      case 'CONFIRMED':
        return const Color(0xFFDEF7EC);
      case 'BOOKING_CANCELLED':
      case 'BOOKING_REJECTED':
      case 'CANCELLED':
        return const Color(0xFFFDE8E8);
      case 'REMINDER_24H':
      case 'REMINDER_3H':
        return const Color(0xFFFEF08A);
      case 'PAYMENT_RECEIVED':
      case 'REFUND_PROCESSED':
        return const Color(0xFFE1EFFE);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getBadgeTextColor(String? type) {
    switch (type) {
      case 'BOOKING_CONFIRMED':
      case 'CONFIRMED':
        return const Color(0xFF03543F);
      case 'BOOKING_CANCELLED':
      case 'BOOKING_REJECTED':
      case 'CANCELLED':
        return const Color(0xFF9B1C1C);
      case 'REMINDER_24H':
      case 'REMINDER_3H':
        return const Color(0xFF854D0E);
      case 'PAYMENT_RECEIVED':
      case 'REFUND_PROCESSED':
        return const Color(0xFF1E429F);
      default:
        return const Color(0xFF374151);
    }
  }

  String _formatNotificationDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just_now'.tr;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${'min_ago'.tr}';
    } else if (difference.inDays < 1) {
      return DateFormat('hh:mm a').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, hh:mm a').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(IconsPath.backArrow),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'notifications'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xff64748B)),
            onPressed: () => controller.refreshNotifications(),
          ),
          const SizedBox(width: 8),
        ],
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async => await controller.getNotifications(page: 1),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (controller.hasError.value && controller.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 54,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value.isNotEmpty
                          ? controller.errorMessage.value
                          : 'something_went_wrong'.tr,
                      textAlign: TextAlign.center,
                      style: globalTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => controller.refreshNotifications(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text('retry'.tr),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 36,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_notifications_found'.tr,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.notifications.length +
                (controller.isPaginationLoading.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index < controller.notifications.length) {
                final item = controller.notifications[index];
                final appointment = item.bookingAppointment;
                final doctor = appointment?.doctor;
                final clinic = appointment?.clinic;

                final displayTitle = item.title?.isNotEmpty == true
                    ? item.title!
                    : (item.notificationType ?? 'Notification');

                String displayBody = item.description?.isNotEmpty == true
                    ? item.description!
                    : '';

                if (displayBody.isEmpty && appointment != null) {
                  final docName = doctor?.user?.fullName ?? '';
                  final clinicName = clinic?.clinicName ?? '';
                  displayBody = [docName, clinicName]
                      .where((s) => s.isNotEmpty)
                      .join(' • ');
                }

                final timeText = _formatNotificationDate(item.createdAt);
                final badgeType = item.notificationType;

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _handleNotificationTap(item),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor
                                  .withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              IconsPath.notificationOutlined,
                              width: 22,
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayTitle,
                                        style: globalTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xff1E293B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (timeText.isNotEmpty)
                                      Text(
                                        timeText,
                                        style: globalTextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xff94A3B8),
                                        ),
                                      ),
                                  ],
                                ),
                                if (displayBody.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    displayBody,
                                    style: globalTextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xff475569),
                                      lineHeight: 1.4,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (badgeType != null &&
                                        badgeType.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _getBadgeBackgroundColor(badgeType),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          badgeType,
                                          style: globalTextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _getBadgeTextColor(badgeType),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (appointment?.consultDate != null) ...[
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('dd MMM yyyy').format(
                                          appointment!.consultDate!,
                                        ),
                                        style: globalTextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      if (appointment.startTime != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          appointment.startTime!,
                                          style: globalTextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xff64748B),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                    strokeWidth: 2.5,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
