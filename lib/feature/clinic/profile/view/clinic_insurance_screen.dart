import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_insurance_controller.dart';

class ClinicInsuranceScreen extends StatelessWidget {
  const ClinicInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClinicInsuranceController());

    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: Text(
          'insurance'.tr,
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
            () => IconButton(
              onPressed: () => controller.toggleEdit(),
              icon: Icon(
                controller.isEditing.value ? Icons.check_circle : Icons.edit,
                color: controller.isEditing.value
                    ? AppColors.primaryColor
                    : const Color(0xff64748B),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _addInsuranceBottomSheet(context, controller),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.fetchInsurances(isRefresh: true),
          color: AppColors.primaryColor,
          child: Obx(() {
            if (controller.isLoading.value && controller.insurances.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            if (controller.insurances.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            IconsPath.insurance,
                            width: 64,
                            height: 64,
                            colorFilter: const ColorFilter.mode(
                              Color(0xffCBD5E1),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'no_insurance_found'.tr,
                            style: globalTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount:
                  controller.insurances.length +
                  (controller.hasMoreData.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.insurances.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final insurance = controller.insurances[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffE5E9F2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xffF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          image: insurance.insurance?.image != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    insurance.insurance!.image!,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: insurance.insurance?.image == null
                            ? SvgPicture.asset(
                                IconsPath.insurance,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xff137CCF),
                                  BlendMode.srcIn,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          insurance.insurance?.name ?? 'na'.tr,
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff2D2D2D),
                          ),
                        ),
                      ),
                      Obx(() {
                        if (controller.isEditing.value) {
                          return IconButton(
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: Text(
                                    'delete_insurance'.tr,
                                    style: globalTextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xff1A1A1A),
                                    ),
                                  ),
                                  content: Text(
                                    'delete_insurance_confirmation'.tr,
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
                                          color: const Color(0xff636F85),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.deleteInsurance(
                                          insurance.id ?? '',
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
            );
          }),
        ),
      ),
    );
  }

  void _addInsuranceBottomSheet(
    BuildContext context,
    ClinicInsuranceController controller,
  ) {
    controller.fetchAllInsurances();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'select_insurance'.tr,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff2D2D2D),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Color(0xff64748B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingAll.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (controller.allInsurances.isEmpty) {
                  return Center(
                    child: Text(
                      'no_insurance_found'.tr,
                      style: globalTextStyle(color: const Color(0xff64748B)),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.allInsurances.length,
                  itemBuilder: (context, index) {
                    final item = controller.allInsurances[index];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xffE5E9F2)),
                        ),
                        child: ListTile(
                          onTap: controller.addingInsuranceId.value.isNotEmpty
                              ? null
                              : () => controller.addInsuranceById(item.id!),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xffF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              image: item.image != null
                                  ? DecorationImage(
                                      image: NetworkImage(item.image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: item.image == null
                                ? const Icon(
                                    Icons.business,
                                    color: AppColors.primaryColor,
                                  )
                                : null,
                          ),
                          title: Text(
                            item.name ?? 'na'.tr,
                            style: globalTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff2D2D2D),
                            ),
                          ),
                          trailing:
                              controller.addingInsuranceId.value == item.id
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.primaryColor,
                                ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
