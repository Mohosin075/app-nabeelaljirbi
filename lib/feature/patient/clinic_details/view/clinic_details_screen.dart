import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/patient/clinic_details/controller/clinic_details_controller.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/feature/patient/clinic_details/widget/doctor_search_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class ClinicDetailsScreen extends StatelessWidget {
  ClinicDetailsScreen({super.key}) {
    final id = Get.arguments?.toString();
    if (id != null && id != controller.currentClinicId.value) {
      controller.currentClinicId.value = id;
      controller.searchController.clear();
      controller.errorMessage.value = "";
      controller.fetchClinicDetails(id);
      controller.fetchClinicDoctors(id);
    }
  }

  final ClinicDetailsController controller = Get.put(ClinicDetailsController());

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
          'clinic_details'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert, color: Colors.grey),
        //     onPressed: () {},
        //   ),
        // ],
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.clinicDetails.value == null) {
          return Center(child: Text('no_data_found'.tr));
        }

        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const Divider(
                  color: Color(0xFFF5F5F5),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 16),
                _buildStats(),
                const SizedBox(height: 24),
                _buildGallery(),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 16),
                _buildTabContent(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    final data = controller.clinicDetails.value!;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: data.logo != null
                    ? Image.network(
                        data.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            SvgPicture.asset(IconsPath.clinicIcon),
                      )
                    : SvgPicture.asset(IconsPath.clinicIcon),
              ),
            ),
            if (data.views != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        size: 10,
                        color: Color(0xFF636F85),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data.views}',
                        style: globalTextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  data.clinicName ?? '',
                  textAlign: TextAlign.center,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff1A1A1A),
                  ),
                ),
              ),
              if (data.platformSubscriptionActive == true) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, size: 18, color: Colors.blue),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final data = controller.clinicDetails.value!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              data.specialistCount?.toString() ?? '0',
              'specialties'.tr,
              IconsPath.stethoscope,
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE5E9F2)),
          Expanded(
            child: _buildStatItem(
              data.doctorCount?.toString() ?? '0',
              'doctor'.tr,
              IconsPath.doctorRole,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label, String iconPath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            Color(0xff636F85),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: globalTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xff1A1A1A),
              ),
            ),
            Text(
              label,
              style: globalTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xff636F85),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGallery() {
    final gallery = controller.clinicDetails.value?.galleries;
    if (gallery == null || gallery.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: gallery.length,
        itemBuilder: (context, index) {
          final item = gallery[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF8F9FA),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: SvgPicture.asset(
                    IconsPath.clinicIcon,
                    width: 32,
                    height: 32,
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['info'.tr, 'specialties'.tr, 'doctors'.tr, 'insurance'.tr];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Obx(
        () => Row(
          children: List.generate(tabs.length, (index) {
            bool isSelected = controller.selectedTabIndex.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primaryColor
                            : const Color(0xff636F85),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (controller.selectedTabIndex.value) {
      case 0:
        return _buildInfoTab();
      case 1:
        return _buildSpecialtiesTab();
      case 2:
        return _buildDoctorsTab(context);
      case 3:
        return _buildInsuranceTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoTab() {
    final data = controller.clinicDetails.value!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'about_clinic'.tr,
            style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            data.about ?? '',
            style: globalTextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          Text(
            'contact'.tr,
            style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E9F2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          data.latitude ?? 0.0,
                          data.longitude ?? 0.0,
                        ),
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.nabeelaljirbi_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                // data.latitude ?? 0.0,
                                // data.longitude ?? 0.0,
                                26.1413108,
                                91.666461,
                              ),
                              width: 80,
                              height: 80,
                              child: Icon(
                                Icons.location_on,
                                size: 40,
                                color: AppColors.primaryColor,
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // "Open in Maps" button at top right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final lat = data.latitude ?? 0.0;
                          final lng = data.longitude ?? 0.0;
                          final uri = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                          );
                          try {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            debugPrint('Error opening Google Maps: $e');
                            Get.snackbar(
                              'error'.tr,
                              'could_not_open_maps'.tr,
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.1,
                              ),
                              colorText: Colors.red,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 16,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'open_in_maps'.tr,
                                style: globalTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          if (data.address != null)
            _buildContactItem(IconsPath.location, data.address!),
          const SizedBox(height: 12),
          if (data.phoneNumber != null)
            _buildContactItem(
              IconsPath.whatsapp,
              data.phoneNumber!,
              whatsapp: true,
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    String iconPath,
    String text, {
    bool whatsapp = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: whatsapp
              ? null
              : const ColorFilter.mode(Color(0xff636F85), BlendMode.srcIn),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: whatsapp
              ? GestureDetector(
                  onTap: () async {
                    final phoneNumber = text.replaceAll(RegExp(r'[^\d+]'), '');
                    final uri = Uri.parse('tel:$phoneNumber');
                    try {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      debugPrint('Error launching dialer: $e');
                      Get.snackbar(
                        'error'.tr,
                        'could_not_launch_dialer'.tr,
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        colorText: Colors.red,
                      );
                    }
                  },
                  child: Text(
                    text,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(
                  text,
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff636F85),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesTab() {
    final specialists = controller.clinicDetails.value?.specialists;
    if (specialists == null || specialists.isEmpty) {
      return Center(child: Text('no_data_found'.tr));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'specialties'.tr,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xff2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: specialists.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 32, color: Color(0xFFF5F5F5)),
            itemBuilder: (context, index) {
              final s = specialists[index];
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: s.image != null
                          ? Image.network(
                              s.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  SvgPicture.asset(IconsPath.clinicIcon),
                            )
                          : SvgPicture.asset(IconsPath.clinicIcon),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    s.specialistDetails ?? 'not_available'.tr,
                    style: globalTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff636F85),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'doctor'.tr,
                style: globalTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DoctorSearchBottomSheet(),
                  );
                  controller.performSearch();
                },
                child: SvgPicture.asset(
                  IconsPath.filter,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xff636F85),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 16),
          // Obx(
          //   () => Text(
          //     '${'results'.tr} (${controller.clinicDoctors.length})',
          //     style: globalTextStyle(
          //       fontSize: 18,
          //       fontWeight: FontWeight.w700,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.searchController,
            onChanged: (value) => controller.performSearch(),
            decoration: InputDecoration(
              hintText: 'search_doctor'.tr,
              hintStyle: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xff636F85),
              ),
              prefixIcon: const Icon(Icons.search, color: Color(0xff636F85)),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E9F2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E9F2)),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isDoctorsLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }
            if (controller.clinicDoctors.isEmpty) {
              return Center(child: Text('no_doctors_available'.tr));
            }
            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: controller.clinicDoctors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final doctor = controller.clinicDoctors[index];
                return GestureDetector(
                  onTap: () {
                    // Navigation logic if details are needed, for now just pass id if navigating
                    Get.toNamed(
                      AppRoutes.doctorDetails,
                      arguments: doctor.doctorId,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
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
                            errorBuilder: (context, error, stackTrace) =>
                                SvgPicture.asset(
                                  IconsPath.doctorIcon,
                                  width: 80,
                                  height: 80,
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
                                  Row(
                                    children: [
                                      Text(
                                        doctor.name ?? 'unknown'.tr,
                                        style: globalTextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${doctor.consultFee ?? 0}',
                                          style: globalTextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xff2d2d2d),
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              ' ${CurrencyUtil.getUserCurrencySymbol()}',
                                          style: globalTextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xff636F85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                (doctor.specialty ?? '').tr,
                                style: globalTextStyle(
                                  fontSize: 13,
                                  color: const Color(0xff636F85),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${doctor.experience ?? 0} ${'year_exp'.tr}',
                                    style: globalTextStyle(
                                      fontSize: 12,
                                      color: const Color(0xff2d2d2d),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        IconsPath.star,
                                        width: 14,
                                        height: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${doctor.rating ?? 0.0}',
                                              style: globalTextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xff2d2d2d),
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  ' (${doctor.reviewCount ?? 0})',
                                              style: globalTextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xff636F85),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInsuranceTab() {
    final insurance = controller.clinicDetails.value?.insurances;
    if (insurance == null || insurance.isEmpty) {
      return Center(child: Text("no_insurance_data".tr));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'insurance'.tr,
            style: globalTextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: insurance.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 32, color: Color(0xFFF5F5F5)),
            itemBuilder: (context, index) {
              final i = insurance[index];
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: i.image != null
                        ? Image.network(i.image!)
                        : SvgPicture.asset(IconsPath.appIcon),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    i.insuranceDetails ?? 'not_available'.tr,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff1A1A1A),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
