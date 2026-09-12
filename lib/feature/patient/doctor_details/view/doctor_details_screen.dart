import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/controller/doctor_details_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/widget/doctor_timings_bottom_sheet.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/model/doctor_details_model.dart';
import 'package:intl/intl.dart';

class DoctorDetailsScreen extends StatelessWidget {
  DoctorDetailsScreen({super.key});

  final DoctorDetailsController controller = Get.put(DoctorDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          onPressed: () => Get.back(),
        ),
        title: Text(
          'doctor_details'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert, color: Color(0xff636F85)),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        if (controller.doctorDetails.value == null) {
          return Center(child: Text('no_data_found'.tr));
        }

        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  color: Color(0xFFF5F5F5),
                  thickness: 1,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildDoctorCard(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildStats(),
                ),
                const SizedBox(height: 16),
                const Divider(
                  color: Color(0xFFF5F5F5),
                  thickness: 8,
                  height: 8,
                ),
                _buildClinicSection(),
                const Divider(
                  color: Color(0xFFF5F5F5),
                  thickness: 8,
                  height: 8,
                ),
                _buildScheduleSection(context),
                const Divider(
                  color: Color(0xFFF5F5F5),
                  thickness: 8,
                  height: 8,
                ),
                _buildAboutSection(),
                if (controller.doctorDetails.value?.biography != null &&
                    controller.doctorDetails.value!.biography!.isNotEmpty)
                  const Divider(
                    color: Color(0xFFF5F5F5),
                    thickness: 8,
                    height: 8,
                  ),
                if (controller.doctorDetails.value?.biography != null &&
                    controller.doctorDetails.value!.biography!.isNotEmpty)
                  _buildBiographySection(),
                const SizedBox(height: 24),
                _buildBookButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDoctorCard() {
    final doctor = controller.doctorDetails.value!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              doctor.profileImage ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                IconsPath.doctorIcon, // Using a valid fallback icon
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      doctor.name ?? '',
                      style: globalTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty ?? '',
                  style: globalTextStyle(
                    fontSize: 14,
                    color: const Color(0xff636F85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final doctor = controller.doctorDetails.value!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            IconsPath.personalCardValue,
            doctor.experience ?? '0',
            'year_of_work'.tr,
          ),
          _buildStatItem(
            IconsPath.ratingBadge,
            doctor.rating?.toString() ?? '0.0',
            'rating'.tr,
          ),
          _buildStatItem(
            IconsPath.moneyValue,
            doctor.consultFee?.toString() ?? '0',
            'per_session'.tr,
            isCurrency: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String iconPath,
    String value,
    String label, {
    bool isCurrency = false,
  }) {
    // Add logic to format currency if needed, or simply append symbol if not present
    final displayValue =
        isCurrency && !value.contains(CurrencyUtil.getUserCurrencySymbol())
        ? '${CurrencyUtil.getUserCurrencySymbol()} $value'
        : value;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(iconPath, width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                displayValue,
                style: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isCurrency ? AppColors.primaryColor : Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: globalTextStyle(
            fontSize: 12,
            color: const Color(0xff636F85),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildClinicSection() {
    final doctor = controller.doctorDetails.value!;
    return InkWell(
      onTap: () {
        if (doctor.clinicId != null) {
          debugPrint('clinicId: ${doctor.clinicId}');
          Get.toNamed(AppRoutes.clinicDetails, arguments: doctor.clinicId);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'clinic'.tr,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xff636F85),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child:
                      doctor.clinicLogo != null && doctor.clinicLogo!.isNotEmpty
                      ? Image.network(
                          doctor.clinicLogo!,
                          errorBuilder: (context, error, stackTrace) =>
                              SvgPicture.asset(IconsPath.clinicIcon),
                        )
                      : SvgPicture.asset(IconsPath.clinicIcon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    doctor.clinicName ?? '',
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xff1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (doctor.clinicPhoto != null && doctor.clinicPhoto!.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctor.clinicPhoto!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          doctor.clinicPhoto![index].image ?? '',
                          width: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(width: 140, color: Colors.grey[200]),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    final doctor = controller.doctorDetails.value!;
    final schedules = doctor.schedule;

    if (schedules == null || schedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('no_schedule_available'.tr),
      );
    }

    // Find schedule for today
    final today = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    ScheduleDay? displaySchedule;
    bool isToday = false;

    try {
      displaySchedule = schedules.firstWhere(
        (element) => element.day?.toLowerCase() == today,
      );
      isToday = true;
    } catch (e) {
      displaySchedule = schedules.first;
    }

    String startTime = 'N/A';
    String endTime = 'N/A';

    if (displaySchedule.slots != null && displaySchedule.slots!.isNotEmpty) {
      final firstSlot = displaySchedule.slots!.first;

      startTime = _formatTime(firstSlot.startTime ?? 'N/A');
      endTime = _formatTime(firstSlot.endTime ?? 'N/A');
    }

    String dayName = displaySchedule.day ?? '';
    dayName = Get.locale?.languageCode == 'ar'
        ? dayName.toLowerCase().tr
        : dayName.toLowerCase().capitalizeFirst ?? '';

    final dayLabel = isToday
        ? '${'schedule'.tr} (${'today'.tr})'
        : '${'schedule'.tr} ($dayName)';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        IconsPath.clock,
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        startTime,
                        style: globalTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'to'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        color: const Color(0xff636F85),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        endTime,
                        style: globalTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    try {
      DateTime dateTime;
      try {
        dateTime = DateFormat("HH:mm:ss").parse(time);
      } catch (e) {
        dateTime = DateFormat("HH:mm").parse(time);
      }

      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour < 12 ? 'am'.tr : 'pm'.tr;
      final displayHour = hour > 12
          ? hour - 12
          : hour == 0
          ? 12
          : hour;
      final displayMinute = minute.toString().padLeft(2, '0');

      return "$displayHour:$displayMinute $period";
    } catch (e) {
      return time;
    }
  }

  Widget _buildAboutSection() {
    final doctor = controller.doctorDetails.value!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'about_doctor'.tr,
            style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.about ?? '',
            style: globalTextStyle(
              fontSize: 14,
              color: const Color(0xff636F85),
              lineHeight: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Get.toNamed(AppRoutes.bookAppointment),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'book_appointment'.tr,
            style: globalTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiographySection() {
    final doctor = controller.doctorDetails.value!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'biography'.tr,
            style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              doctor.biography!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
