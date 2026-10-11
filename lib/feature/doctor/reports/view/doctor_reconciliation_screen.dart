import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/doctor/reports/controller/doctor_reconciliation_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/reports/model/doctor_reconciliation_model.dart';

class DoctorReconciliationScreen extends StatelessWidget {
  const DoctorReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorReconciliationController());

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: Text(
          'reconciliation_reports'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xff1E293B),
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
          Obx(() {
            if (controller.activeFilterCount == 0) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: controller.resetFilters,
              icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xffDC2626)),
              label: Text(
                'reset_filters'.tr,
                style: globalTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xffDC2626),
                ),
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // Full-screen spinner only on the very first initial load before any data is received
          if (controller.isInitialLoading.value &&
              controller.reconciliationData.value == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchReports(isFilterChange: false),
            color: AppColors.primaryColor,
            child: Stack(
              children: [
                CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNoticeBanner(),
                            const SizedBox(height: 12),
                            _buildSearchAndFilterHeader(context, controller),
                            const SizedBox(height: 10),
                            _buildPeriodSegmentBar(context, controller),
                            _buildActiveFilterChips(controller),
                            const SizedBox(height: 12),
                            // Thin animated progress bar while updating in-place
                            Obx(() {
                              if (controller.isFiltering.value) {
                                return const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: LinearProgressIndicator(
                                    minHeight: 2.5,
                                    color: AppColors.primaryColor,
                                    backgroundColor: Color(0xffE2E8F0),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            _buildSummaryCards(controller),
                            const SizedBox(height: 16),
                            if ((controller.reconciliationData.value?.clinicBreakdown ?? []).length > 1) ...[
                              _buildClinicBreakdown(controller),
                              const SizedBox(height: 16),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'appointments_list'.tr,
                                  style: globalTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xff1E293B),
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    '${controller.reconciliationData.value?.meta?.total ?? controller.appointments.length} ${'records'.tr}',
                                    style: globalTextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Obx(() {
                      if (controller.appointments.isEmpty && !controller.isFiltering.value) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 54,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'no_reconciliation_records'.tr,
                                    style: globalTextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = controller.appointments[index];
                              return AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: controller.isFiltering.value ? 0.6 : 1.0,
                                child: _buildAppointmentCard(item),
                              );
                            },
                            childCount: controller.appointments.length,
                          ),
                        ),
                      );
                    }),
                    if (controller.isMoreLoading.value)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 30),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xff1E40AF),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'reconciliation_notice'.tr,
              style: globalTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xff1E3A8A),
                lineHeight: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterHeader(
    BuildContext context,
    DoctorReconciliationController controller,
  ) {
    return Row(
      children: [
        // Search Input
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: globalTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xff1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'search_patient'.tr,
                hintStyle: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Color(0xff94A3B8),
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xff94A3B8)),
                    onPressed: controller.clearSearch,
                  );
                }),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Filter Button with Badge
        Obx(() {
          final filterCount = controller.secondaryFilterCount;
          final hasFilters = filterCount > 0;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showFilterBottomSheet(context, controller),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: hasFilters ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasFilters ? AppColors.primaryColor : const Color(0xffE2E8F0),
                  ),
                  boxShadow: hasFilters
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: hasFilters ? Colors.white : const Color(0xff475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'filters'.tr,
                      style: globalTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: hasFilters ? Colors.white : const Color(0xff475569),
                      ),
                    ),
                    if (hasFilters) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$filterCount',
                          style: globalTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPeriodSegmentBar(
    BuildContext context,
    DoctorReconciliationController controller,
  ) {
    return Obx(() {
      final period = controller.selectedPeriod.value;
      final selectedDate = controller.selectedDate.value;
      final customStart = controller.customStartDate.value;
      final customEnd = controller.customEndDate.value;

      String customLabel = 'custom_range'.tr;
      if (selectedDate != null) {
        customLabel = DateFormat('MMM dd').format(selectedDate);
      } else if (customStart != null && customEnd != null) {
        customLabel =
            '${DateFormat('MM/dd').format(customStart)} - ${DateFormat('MM/dd').format(customEnd)}';
      }

      final isCustomActive = period == 'custom' || selectedDate != null;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildPeriodPill(
              label: 'daily'.tr,
              isSelected: period == 'daily' && selectedDate == null,
              onTap: () => controller.setPeriod('daily'),
            ),
            const SizedBox(width: 8),
            _buildPeriodPill(
              label: 'weekly'.tr,
              isSelected: period == 'weekly',
              onTap: () => controller.setPeriod('weekly'),
            ),
            const SizedBox(width: 8),
            _buildPeriodPill(
              label: 'monthly'.tr,
              isSelected: period == 'monthly',
              onTap: () => controller.setPeriod('monthly'),
            ),
            const SizedBox(width: 8),
            _buildPeriodPill(
              label: 'last_month'.tr,
              isSelected: period == 'last_month',
              onTap: () => controller.setPeriod('last_month'),
            ),
            const SizedBox(width: 8),
            _buildPeriodPill(
              label: customLabel,
              isSelected: isCustomActive,
              icon: Icons.calendar_today_rounded,
              onTap: () => _pickCustomRange(context, controller),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPeriodPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xffE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xff64748B),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: globalTextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xff475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips(DoctorReconciliationController controller) {
    return Obx(() {
      if (controller.secondaryFilterCount == 0) return const SizedBox.shrink();

      final clinicId = controller.selectedClinicId.value;
      final shift = controller.selectedShift.value;
      final status = controller.selectedStatus.value;

      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (clinicId != 'all')
                _buildActiveTag(
                  label: '${'clinic'.tr}: ${controller.getClinicName(clinicId)}',
                  icon: Icons.local_hospital_outlined,
                  onRemove: () => controller.setClinic('all'),
                ),
              if (shift != 'all')
                _buildActiveTag(
                  label: shift == 'morning'
                      ? 'morning_shift'.tr
                      : 'evening_shift'.tr,
                  icon: shift == 'morning'
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_outlined,
                  onRemove: () => controller.setShift('all'),
                ),
              if (status != 'ALL')
                _buildActiveTag(
                  label: _getStatusLabel(status),
                  icon: Icons.filter_alt_outlined,
                  onRemove: () => controller.setStatus('ALL'),
                ),
              TextButton(
                onPressed: controller.resetSecondaryFilters,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'clear_all'.tr,
                  style: globalTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffDC2626),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActiveTag({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.only(left: 8, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xffEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xff1D4ED8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: globalTextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xff1E40AF),
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(
                Icons.close_rounded,
                size: 13,
                color: Color(0xff1E40AF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETE':
        return 'completed'.tr;
      case 'CONFIRMED':
        return 'confirmed'.tr;
      case 'CANCELLED':
        return 'cancelled'.tr;
      case 'NOT_SHOW':
        return 'no_show'.tr;
      default:
        return status;
    }
  }

  Future<void> _pickCustomRange(
    BuildContext context,
    DoctorReconciliationController controller,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      initialDateRange: controller.customStartDate.value != null &&
              controller.customEndDate.value != null
          ? DateTimeRange(
              start: controller.customStartDate.value!,
              end: controller.customEndDate.value!,
            )
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 7)),
              end: DateTime.now(),
            ),
    );

    if (picked != null) {
      controller.setCustomRange(picked.start, picked.end);
    }
  }

  void _showFilterBottomSheet(
    BuildContext context,
    DoctorReconciliationController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(ctx).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: Color(0xff1E293B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'filter_reports'.tr,
                        style: globalTextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff1E293B),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(() {
                        if (controller.secondaryFilterCount == 0) {
                          return const SizedBox.shrink();
                        }
                        return TextButton(
                          onPressed: () {
                            controller.resetSecondaryFilters();
                          },
                          child: Text(
                            'clear_all'.tr,
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xffDC2626),
                            ),
                          ),
                        );
                      }),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xff64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Color(0xffF1F5F9), height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clinic Filter Section
                      if (controller.availableClinics.isNotEmpty) ...[
                        Text(
                          'select_clinic'.tr,
                          style: globalTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final selected = controller.selectedClinicId.value;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildModalFilterChip(
                                label: 'all_clinics'.tr,
                                isSelected: selected == 'all',
                                onTap: () => controller.setClinic('all'),
                              ),
                              ...controller.availableClinics.map((clinic) {
                                return _buildModalFilterChip(
                                  label: clinic.clinicName ?? 'Clinic',
                                  isSelected: selected == clinic.id,
                                  onTap: () => controller.setClinic(clinic.id),
                                );
                              }),
                            ],
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                      // Shift Filter Section
                      Text(
                        'time_shift'.tr,
                        style: globalTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final shift = controller.selectedShift.value;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildModalFilterChip(
                              label: 'all_shifts'.tr,
                              isSelected: shift == 'all',
                              icon: Icons.schedule_rounded,
                              onTap: () => controller.setShift('all'),
                            ),
                            _buildModalFilterChip(
                              label: 'morning_shift'.tr,
                              isSelected: shift == 'morning',
                              icon: Icons.wb_sunny_outlined,
                              onTap: () => controller.setShift('morning'),
                            ),
                            _buildModalFilterChip(
                              label: 'evening_shift'.tr,
                              isSelected: shift == 'evening',
                              icon: Icons.nightlight_outlined,
                              onTap: () => controller.setShift('evening'),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      // Status Filter Section
                      Text(
                        'appointment_status'.tr,
                        style: globalTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        final status = controller.selectedStatus.value;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildModalFilterChip(
                              label: 'all'.tr,
                              isSelected: status == 'ALL',
                              onTap: () => controller.setStatus('ALL'),
                            ),
                            _buildModalFilterChip(
                              label: 'completed'.tr,
                              isSelected: status == 'COMPLETE',
                              onTap: () => controller.setStatus('COMPLETE'),
                            ),
                            _buildModalFilterChip(
                              label: 'confirmed'.tr,
                              isSelected: status == 'CONFIRMED',
                              onTap: () => controller.setStatus('CONFIRMED'),
                            ),
                            _buildModalFilterChip(
                              label: 'cancelled'.tr,
                              isSelected: status == 'CANCELLED',
                              onTap: () => controller.setStatus('CANCELLED'),
                            ),
                            _buildModalFilterChip(
                              label: 'no_show'.tr,
                              isSelected: status == 'NOT_SHOW',
                              onTap: () => controller.setStatus('NOT_SHOW'),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'apply_filters'.tr,
                    style: globalTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : const Color(0xffE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xff64748B),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: globalTextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xff334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DoctorReconciliationController controller) {
    return Obx(() {
      final summary = controller.reconciliationData.value?.summary;
      final earned = summary?.totalEarnedAmount ?? 0.0;
      final potential = summary?.totalPotentialAmount ?? 0.0;
      final completed = summary?.completedAppointments ?? 0;
      final confirmed = summary?.confirmedAppointments ?? 0;
      final cancelled = summary?.cancelledAppointments ?? 0;
      final noShow = summary?.noShowAppointments ?? 0;
      final feeRate = summary?.consultFeePerSession ?? 0.0;
      final currency = CurrencyUtil.getUserCurrencySymbol();

      return Column(
        children: [
          // Primary Revenue Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff0F766E), Color(0xff0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff0F766E).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'earned_amount'.tr,
                      style: globalTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$completed ${'completed'.tr}',
                        style: globalTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${earned.toStringAsFixed(1)} $currency',
                  style: globalTextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${'potential_amount'.tr}: ${potential.toStringAsFixed(1)} $currency',
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      '${'consult_fee_rate'.tr}: ${feeRate.toStringAsFixed(0)} $currency',
                      style: globalTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Sub Stats Row
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  title: 'completed'.tr,
                  count: completed.toString(),
                  icon: Icons.check_circle_outline,
                  color: const Color(0xff16A34A),
                  bgColor: const Color(0xffDCFCE7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  title: 'upcoming'.tr,
                  count: confirmed.toString(),
                  icon: Icons.schedule_outlined,
                  color: const Color(0xff2563EB),
                  bgColor: const Color(0xffDBEAFE),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniStat(
                  title: 'cancelled_no_show'.tr,
                  count: '${cancelled + noShow}',
                  icon: Icons.cancel_outlined,
                  color: const Color(0xffDC2626),
                  bgColor: const Color(0xffFEE2E2),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildMiniStat({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: globalTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: globalTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xff1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicBreakdown(DoctorReconciliationController controller) {
    return Obx(() {
      final list = controller.reconciliationData.value?.clinicBreakdown ?? [];
      final currency = CurrencyUtil.getUserCurrencySymbol();

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'breakdown_by_clinic'.tr,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xff1E293B),
              ),
            ),
            const SizedBox(height: 10),
            ...list.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.local_hospital_outlined,
                        size: 18,
                        color: Color(0xff1E88E5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.clinicName,
                            style: globalTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff1E293B),
                            ),
                          ),
                          Text(
                            '${item.completedCount} ${'completed'.tr} / ${item.totalCount} ${'total'.tr}',
                            style: globalTextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xff64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.totalAmount.toStringAsFixed(1)} $currency',
                      style: globalTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff0F766E),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildAppointmentCard(ReconciliationAppointment item) {
    final currency = CurrencyUtil.getUserCurrencySymbol();
    final dateStr = item.consultDate != null
        ? DateFormat('EEE, MMM dd, yyyy').format(item.consultDate!)
        : '';
    final timeStr = item.startTime != null ? '${item.startTime} - ${item.endTime}' : '';

    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (item.status.toUpperCase()) {
      case 'COMPLETE':
        statusColor = const Color(0xff16A34A);
        statusBgColor = const Color(0xffDCFCE7);
        statusText = 'completed'.tr;
        break;
      case 'CONFIRMED':
      case 'ARRIVED':
      case 'INPROGRESS':
        statusColor = const Color(0xff2563EB);
        statusBgColor = const Color(0xffDBEAFE);
        statusText = 'confirmed'.tr;
        break;
      case 'CANCELLED':
        statusColor = const Color(0xffDC2626);
        statusBgColor = const Color(0xffFEE2E2);
        statusText = 'cancelled'.tr;
        break;
      case 'NOT_SHOW':
        statusColor = const Color(0xffD97706);
        statusBgColor = const Color(0xffFEF3C7);
        statusText = 'no_show'.tr;
        break;
      default:
        statusColor = const Color(0xff64748B);
        statusBgColor = const Color(0xffF1F5F9);
        statusText = item.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Queue Number Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${item.serialNumber}',
                  style: globalTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff334155),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.patient?.fullName ?? 'Patient',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: globalTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xffF1F5F9), height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Clinic & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_hospital_outlined,
                          size: 14,
                          color: Color(0xff64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.clinic?.clinicName ?? '',
                            style: globalTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff475569),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: Color(0xff64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$dateStr | $timeStr',
                          style: globalTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Fee Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.consultFee.toStringAsFixed(0)} $currency',
                    style: globalTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: item.status.toUpperCase() == 'COMPLETE'
                          ? const Color(0xff0F766E)
                          : const Color(0xff334155),
                    ),
                  ),
                  Text(
                    item.status.toUpperCase() == 'COMPLETE' ? 'settled'.tr : 'consultation_fee'.tr,
                    style: globalTextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
