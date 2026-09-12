import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/doctor/home/controller/doctor_notification_controller.dart';

class DoctorNotificationScreen extends StatefulWidget {
  const DoctorNotificationScreen({super.key});

  @override
  State<DoctorNotificationScreen> createState() =>
      _DoctorNotificationScreenState();
}

class _DoctorNotificationScreenState extends State<DoctorNotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  final DoctorNotificationController controller = Get.put(
    DoctorNotificationController(),
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            color: const Color(0xff2D2D2D),
          ),
        ),
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
          if (controller.notifications.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                Center(child: Text('no_notifications_found'.tr)),
              ],
            );
          }
          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount:
                controller.notifications.length +
                (controller.isPaginationLoading.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < controller.notifications.length) {
                final notification = controller.notifications[index];
                final patient = notification.bookingAppointment?.patient?.user;
                final appointment = notification.bookingAppointment;

                String description = "";
                if (notification.notificationType == "New Appointment" ||
                    notification.notificationType == "Upcoming Appointment") {
                  final patientName = patient?.fullName ?? 'a_patient'.tr;

                  if (notification.notificationType == "New Appointment") {
                    String dateStr = "";
                    if (appointment?.consultDate != null) {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final tomorrow = today.add(const Duration(days: 1));
                      final consultDate = DateTime(
                        appointment!.consultDate!.year,
                        appointment.consultDate!.month,
                        appointment.consultDate!.day,
                      );

                      if (consultDate == today) {
                        dateStr = 'today_low'.tr;
                      } else if (consultDate == tomorrow) {
                        dateStr = 'tomorrow_low'.tr;
                      } else {
                        dateStr = DateFormat(
                          'dd/MM/yyyy',
                        ).format(appointment.consultDate!);
                      }
                    }

                    String timeStr = "";
                    if (appointment?.startTime != null) {
                      try {
                        final time = DateFormat(
                          "HH:mm",
                        ).parse(appointment!.startTime!);
                        timeStr = DateFormat('hh:mm a').format(time);
                      } catch (e) {
                        timeStr = appointment!.startTime!;
                      }
                    }

                    description = 'new_appointment_desc'.trParams({
                      'name': patientName,
                      'date': dateStr,
                      'time': timeStr,
                    });
                  } else if (notification.notificationType ==
                      "Upcoming Appointment") {
                    String timeDiff = "";
                    if (appointment?.consultDate != null &&
                        appointment?.startTime != null) {
                      try {
                        final startTime = DateFormat(
                          "HH:mm",
                        ).parse(appointment!.startTime!);
                        final appointmentTime = DateTime(
                          appointment.consultDate!.year,
                          appointment.consultDate!.month,
                          appointment.consultDate!.day,
                          startTime.hour,
                          startTime.minute,
                        );
                        final diff = appointmentTime.difference(DateTime.now());
                        if (diff.inMinutes > 0 && diff.inMinutes < 60) {
                          timeDiff = 'in_minutes'.trParams({
                            'min': diff.inMinutes.toString(),
                          });
                        } else {
                          timeDiff = DateFormat(
                            'hh:mm a',
                          ).format(appointmentTime);
                        }
                      } catch (e) {
                        timeDiff =
                            notification.notificationType?.tr ??
                            'notification'.tr;
                      }
                    }

                    description = 'upcoming_appointment_desc'.trParams({
                      'name': patientName,
                      'time_diff': timeDiff,
                    });
                  }
                } else {
                  description =
                      notification.notificationType?.tr ?? 'notification'.tr;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAAD14).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: SvgPicture.asset(
                          IconsPath.notificationOutlined,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notification.notificationType ??
                                      'Notification',
                                  style: globalTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff2D2D2D),
                                  ),
                                ),
                                // if (!notification.isRead) // API doesn't seem to have isRead
                                //   Container(
                                //     width: 10,
                                //     height: 10,
                                //     decoration: const BoxDecoration(
                                //       color: Color(0xFF2196F3),
                                //       shape: BoxShape.circle,
                                //     ),
                                //   ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: globalTextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff636F85),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                notification.createdAt != null
                                    ? DateFormat(
                                        'hh:mm a, dd/MM/yyyy',
                                      ).format(notification.createdAt!)
                                    : "",
                                style: globalTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xff636F85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }
            },
          );
        }),
      ),
    );
  }
}
