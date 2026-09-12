import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_specialties_controller.dart';

class ClinicSpecialtiesScreen extends StatelessWidget {
  const ClinicSpecialtiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClinicSpecialtiesController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'specialties'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff2D2D2D),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(IconsPath.backArrow),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => InkWell(
              onTap: () => controller.toggleEditSpecialties(),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  IconsPath.edit,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    controller.isEditingSpecialties.value
                        ? AppColors.primaryColor
                        : const Color(0xFF64748B),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchSpecialists(isRefresh: true);
                },
                color: AppColors.primaryColor,
                child: Obx(() {
                  if (controller.isSpecialistsLoading.value &&
                      controller.specialistsList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (controller.specialistsList.isEmpty) {
                    return Stack(
                      children: [
                        ListView(), // To allow RefreshIndicator to work even if empty
                        Center(
                          child: Text(
                            'no_specialists_found'.tr,
                            style: globalTextStyle(
                              fontSize: 16,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!controller.isSpecialistsLoading.value &&
                          controller.hasMoreSpecialists.value &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        controller.fetchSpecialists();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      itemCount:
                          controller.specialistsList.length +
                          (controller.hasMoreSpecialists.value ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                      itemBuilder: (context, index) {
                        if (index == controller.specialistsList.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          );
                        }
                        final specialistItem =
                            controller.specialistsList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  specialistItem.specialist?.image ?? '',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40,
                                      height: 40,
                                      color: const Color(0xFFF1F5F9),
                                      child: const Icon(
                                        Icons.person,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  specialistItem.specialist?.name ?? '',
                                  style: globalTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Obx(() {
                                if (controller.isEditingSpecialties.value) {
                                  return IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: Text(
                                            'delete_specialty'.tr,
                                            style: globalTextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xff1A1A1A),
                                            ),
                                          ),
                                          content: Text(
                                            'delete_specialty_confirmation'.tr,
                                            style: globalTextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xff636F85),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: Text(
                                                'cancel'.tr,
                                                style: globalTextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(
                                                    0xff636F85,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Get.back();
                                                controller.deleteSpecialist(
                                                  specialistItem.id ?? '',
                                                );
                                              },
                                              child: Text(
                                                'delete'.tr,
                                                style: globalTextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            // Add More Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showAddSpecialtySheet(context, controller),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF94A3B8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Color(0xFF1E293B), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'add_more'.tr,
                        style: globalTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddSpecialtySheet(
    BuildContext context,
    ClinicSpecialtiesController controller,
  ) {
    controller.getAllSpecialists();
    Get.bottomSheet(
      SafeArea(
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'select_specialty'.tr,
                style: globalTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff2D2D2D),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() {
                  if (controller.isAllSpecialistsLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (controller.allSpecialistList.isEmpty) {
                    return Center(
                      child: Text(
                        'no_specialists_found'.tr,
                        style: globalTextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.allSpecialistList.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                    itemBuilder: (context, index) {
                      final specialist = controller.allSpecialistList[index];
                      return ListTile(
                        onTap: () {
                          Get.back();
                          controller.addSpecialist(specialist.id!);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            specialist.image ?? '',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(
                                  Icons.category_outlined,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          specialist.name ?? '',
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
