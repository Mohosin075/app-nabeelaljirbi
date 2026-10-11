import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/patient/doctor_details/controller/doctor_details_controller.dart';
import 'package:nabeelaljirbi_app/feature/patient/booking/controller/booking_controller.dart';

class ConfirmBookingBottomSheet extends StatelessWidget {
  ConfirmBookingBottomSheet({super.key});

  final DoctorDetailsController doctorController =
      Get.find<DoctorDetailsController>();
  final BookingController bookingController = Get.find<BookingController>();

  @override
  Widget build(BuildContext context) {
    if (doctorController.doctorDetails.value == null) {
      return const SizedBox.shrink();
    }
    final doctor = doctorController.doctorDetails.value!;
    final selectedDate =
        bookingController.dates[bookingController.selectedDateIndex.value];

    String selectedTime = 'not_selected'.tr;
    if (bookingController.selectedSlotIndex.value != -1) {
      final slot = bookingController
          .availableSlots[bookingController.selectedSlotIndex.value];
      selectedTime = bookingController.formatSlotTime(slot);
    }

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E9F2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'confirm_booking'.tr,
                  style: globalTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff636F85)),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor info card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  doctor.profileImage ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          doctor.name ?? '',
                                          style: globalTextStyle(
                                            fontSize: 16,
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
                                    Text(
                                      doctor.specialty ?? '',
                                      style: globalTextStyle(
                                        fontSize: 13,
                                        color: const Color(0xff636F85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          _buildInfoRow(
                            'date_time'.tr,
                            '${(selectedDate['day'] as String).toLowerCase().tr}, ${selectedDate['date']} - $selectedTime',
                            isBold: true,
                          ),
                          _buildInfoRow(
                            'session_fee'.tr,
                            '${doctor.consultFee} ${CurrencyUtil.getUserCurrencySymbol()}',
                            isAmount: true,
                          ),
                          const Divider(),
                          Obx(() {
                            if (bookingController.isServiceFeeLoading.value) {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                            return _buildInfoRow(
                              'service_fee'.tr,
                              '${bookingController.serviceFee.value} ${CurrencyUtil.getUserCurrencySymbol()}',
                              isAmount: true,
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Family / Dependent Booking Option
                    Text(
                      '${'book_for_myself'.tr} / ${'book_for_family'.tr}',
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Center(
                                child: Text(
                                  'book_for_myself'.tr,
                                  style: globalTextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        bookingController.bookedFor.value == 'SELF'
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                    color: bookingController.bookedFor.value == 'SELF'
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              selected:
                                  bookingController.bookedFor.value == 'SELF',
                              selectedColor: AppColors.primaryColor,
                              backgroundColor: const Color(0xFFF1F3F5),
                              showCheckmark: false,
                              onSelected: (val) {
                                if (val) bookingController.bookedFor.value = 'SELF';
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Center(
                                child: Text(
                                  'book_for_family'.tr,
                                  style: globalTextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        bookingController.bookedFor.value == 'FAMILY'
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                    color: bookingController.bookedFor.value ==
                                            'FAMILY'
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              selected:
                                  bookingController.bookedFor.value == 'FAMILY',
                              selectedColor: AppColors.primaryColor,
                              backgroundColor: const Color(0xFFF1F3F5),
                              showCheckmark: false,
                              onSelected: (val) {
                                if (val) bookingController.bookedFor.value = 'FAMILY';
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dependent Details Input
                    Obx(() {
                      if (bookingController.bookedFor.value != 'FAMILY') {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'family_member_name'.tr,
                              style: globalTextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller:
                                  bookingController.familyMemberNameController,
                              decoration: InputDecoration(
                                hintText: 'family_member_name'.tr,
                                hintStyle: globalTextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFCED4DA)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'relationship'.tr,
                              style: globalTextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: bookingController.familyRelations
                                  .map((rel) => ChoiceChip(
                                        label: Text(
                                          rel.toLowerCase().tr,
                                          style: globalTextStyle(
                                            fontSize: 12,
                                            color: bookingController
                                                        .selectedFamilyRelation
                                                        .value ==
                                                    rel
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        selected: bookingController
                                                .selectedFamilyRelation.value ==
                                            rel,
                                        selectedColor: AppColors.primaryColor,
                                        backgroundColor: Colors.white,
                                        showCheckmark: false,
                                        onSelected: (val) {
                                          if (val) {
                                            bookingController
                                                .selectedFamilyRelation
                                                .value = rel;
                                          }
                                        },
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Pre-send Booking Policy Notice (Point 1 of 2 Policy displays)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9DB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEC99)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: Color(0xFFF08C00),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'booking_policy_title'.tr,
                                style: globalTextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFD9480F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'booking_policy_notice'.tr,
                            style: globalTextStyle(
                              fontSize: 11.5,
                              color: const Color(0xFF495057),
                              lineHeight: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: bookingController.isLoading.value
                      ? null
                      : () {
                          bookingController.bookAppointment();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: bookingController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'send_booking_request'.tr,
                          style: globalTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    bool isAmount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: globalTextStyle(
              fontSize: 13,
              color: const Color(0xff636F85),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: globalTextStyle(
              fontSize: 13,
              fontWeight:
                  isBold || isAmount ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xff1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
