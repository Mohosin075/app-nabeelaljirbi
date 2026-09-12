import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import '../controller/clinic_doctor_controller.dart';
import '../widget/clinic_doctor_filter_bottom_sheet.dart';
import '../widget/doctor_card.dart';

class ClinicDoctorScreen extends StatelessWidget {
  ClinicDoctorScreen({super.key});
  final controller = Get.put(ClinicDoctorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchDoctors(isRefresh: true),
                color: AppColors.primaryColor,

                child: SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTotalCount(controller),
                      const SizedBox(height: 16),
                      _buildSearchBar(context, controller),
                      const SizedBox(height: 16),
                      _buildDoctorsList(controller),
                      const SizedBox(height: 16),
                      _buildPaginationLoading(controller),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationLoading(ClinicDoctorController controller) {
    return Obx(() {
      if (controller.isPaginationLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'doctors'.tr,
            style: globalTextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCount(ClinicDoctorController controller) {
    return Obx(
      () => Text(
        'total_with_count'.tr.replaceAll(
          '@count',
          controller.totalDoctors.toString(),
        ),
        style: globalTextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2D2D2D),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    ClinicDoctorController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            IconsPath.search,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xFF94A3B8),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: controller.search,
              decoration: InputDecoration(
                hintText: 'search'.tr,
                hintStyle: globalTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ClinicDoctorFilterBottomSheet(),
              );
            },
            child: SvgPicture.asset(
              IconsPath.filter,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF64748B),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList(ClinicDoctorController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.doctors.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      final doctors = controller.filteredDoctors;

      if (doctors.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'no_doctors_found'.tr,
              style: globalTextStyle(
                fontSize: 16,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return DoctorCard(doctor: doctors[index]);
        },
      );
    });
  }
}
