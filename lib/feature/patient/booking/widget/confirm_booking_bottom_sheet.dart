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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'confirm_booking'.tr,
                  style: globalTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xff636F85)),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
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
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 64,
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
                                    fontSize: 18,
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
                                fontSize: 14,
                                color: const Color(0xff636F85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFF8F9FA),
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'payment'.tr,
            //         style: globalTextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w700,
            //         ),
            //       ),
            //       const Divider(height: 24),
            //       Row(
            //         children: [
            //           Icon(
            //             Icons.radio_button_checked,
            //             color: AppColors.primaryColor,
            //           ),
            //           const SizedBox(width: 12),
            //           Text(
            //             'wallet'.tr,
            //             style: globalTextStyle(
            //               fontSize: 14,
            //               fontWeight: FontWeight.w400,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 24),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: bookingController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'confirm'.tr,
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: globalTextStyle(
              fontSize: 14,
              color: const Color(0xff636F85),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: globalTextStyle(
              fontSize: 14,
              fontWeight: isBold || isAmount
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: const Color(0xff1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
