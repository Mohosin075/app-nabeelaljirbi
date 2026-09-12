import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/patient/subscription/view/patient_subscription_screen.dart';
import 'package:nabeelaljirbi_app/feature/patient/wallet/controller/patient_wallet_controller.dart';

class PatientWalletScreen extends StatelessWidget {
  PatientWalletScreen({super.key});

  final PatientWalletController controller = Get.put(PatientWalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'my_wallet'.tr,
          style: globalTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xff1A1A1A),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: const Color(0xFF1E88E5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics:
              const AlwaysScrollableScrollPhysics(), // Ensure scroll is always enabled for refresher
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(context), // Pass context
              const SizedBox(height: 16),
              _buildReferralSection(),
              const SizedBox(height: 24),
              Text(
                'recent_transactions'.tr,
                style: globalTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5), // Blue color from design
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Obx(
            () => Text(
              '${controller.balance.value.toStringAsFixed(0)} ${CurrencyUtil.getUserCurrencySymbol()}',
              style: globalTextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'current_balance'.tr,
            style: globalTextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'balance_desc'.tr,
            style: globalTextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.to(() => PatientSubscriptionScreen());
                  // Get.snackbar(
                  //   'top_up'.tr,
                  //   'top_up_success_desc'.tr,
                  //   backgroundColor: AppColors.primaryColor,
                  //   colorText: Colors.white,
                  // );
                },
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      IconsPath.topUpIcon,
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF1E88E5),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'top_up_wallet'.tr,
                      style: globalTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E88E5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Color(0xffe4edf8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xffF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                IconsPath.chartUp, // Using placeholder icon for trend
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFFA000),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'referral_program'.tr,
                style: globalTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'referral_program_desc'.tr,
            style: globalTextStyle(
              fontSize: 12,
              color: const Color(0xff636F85),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'your_referral_code'.tr,
                      style: globalTextStyle(
                        fontSize: 10,
                        color: const Color(0xff636F85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.referralCode.value,
                        style: globalTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildIconBtn(
                      icon: IconsPath.copy,
                      onTap: controller.copyReferralCode,
                    ),
                    const SizedBox(width: 8),
                    _buildIconBtn(
                      icon: IconsPath.share,
                      onTap: controller.shareReferralCode,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          // Redesigned Stats Section
          _buildInfoCard(
            0xFFFFF8E1,
            IconsPath.refarrelBonus,
            'unclaimed_earnings'.tr,
            controller.currentEarnings,
            isCurrency: true,
            showClaimButton: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  0xFFF1F5F9,
                  IconsPath.reward,
                  'total_earned'.tr,
                  controller.totalEarned,
                  isCurrency: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  0xFFE3F2FD, // Light Blue for contrast
                  IconsPath.referral,
                  'friends_invited'.tr,
                  controller.friendsInvited,
                  isCurrency: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    int colorValue,
    String iconInfo,
    String label,
    Rx<num> value, {
    bool isCurrency = false,
    bool showClaimButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(colorValue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(iconInfo),
              if (showClaimButton)
                Obx(
                  () => value.value > 0
                      ? GestureDetector(
                          onTap: controller.isLoading.value
                              ? null
                              : controller.claimBonus,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1E88E5,
                              ), // Blue claim button
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'claim'.tr,
                              style: globalTextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              isCurrency
                  ? '${value.value} ${CurrencyUtil.getUserCurrencySymbol()}'
                  : value.value.toString(),
              style: globalTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xff1A1A1A),
              ),
            ),
          ),
          Text(
            label,
            style: globalTextStyle(
              fontSize: 12,
              color: const Color(0xff636F85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn({required String icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SvgPicture.asset(icon),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      if (controller.isHistoryLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }
      if (controller.topUpHistory.isEmpty) {
        return Center(
          child: Text(
            'no_transactions_yet'.tr,
            style: globalTextStyle(color: Colors.grey),
          ),
        );
      }
      return Column(
        children: controller.topUpHistory.map((tx) {
          // Format date if needed, or just use the raw string
          // Ideally parse tx.createdAt to a nice format
          String dateStr = tx.createdAt ?? '';
          try {
            final date = DateTime.tryParse(tx.createdAt ?? '');
            if (date != null) {
              final localDate = date.toLocal();
              dateStr =
                  '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')} ${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
            }
          } catch (_) {}

          final isNegative = tx.type == 'BOOKING' || tx.type == 'WITHDRAW';
          final color = isNegative
              ? const Color(0xFFF44336)
              : const Color(0xFF4CAF50);
          final sign = isNegative ? '-' : '+';

          String title = 'top_up'.tr;
          String icon = IconsPath.topUp;

          if (tx.type == 'REFERALL' || tx.type == 'REFERRAL') {
            title = 'referral_bonus'.tr;
            icon = IconsPath.refarrelBonus;
          } else if (tx.type == 'BOOKING') {
            final doctorName = tx.appointment?.doctor?.user?.fullName;
            title = doctorName != null
                ? '${'booking'.tr}: $doctorName'
                : 'booking'.tr;
            icon = IconsPath.booking;
          } else if (tx.type == 'WITHDRAW') {
            title = 'withdraw'.tr;
            icon = IconsPath.withdraw;
          } else if (tx.type == 'RECHARGE') {
            title = 'recharge'.tr;
            icon = IconsPath.topUp;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                SvgPicture.asset(icon),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: globalTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1A1A1A),
                        ),
                      ),
                      Text(
                        '#${tx.id?.substring(0, 8) ?? '...'}  -  $dateStr',
                        style: globalTextStyle(
                          fontSize: 12,
                          color: const Color(0xff94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$sign ${tx.amount} ${CurrencyUtil.getUserCurrencySymbol()}',
                  style: globalTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  // void _showTopUpDialog(BuildContext context) {
  //   final TextEditingController amountController = TextEditingController();
  //   Get.dialog(
  //     AlertDialog(
  //       backgroundColor: Colors.white,
  //       title: Text(
  //         'top_up_amount'.tr,
  //         style: globalTextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.black,
  //         ),
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //             controller: amountController,
  //             keyboardType: const TextInputType.numberWithOptions(
  //               decimal: true,
  //             ),
  //             decoration: InputDecoration(
  //               hintText: 'enter_amount_hint'.tr,
  //               prefixText: '${CurrencyUtil.getUserCurrencySymbol()} ',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           child: Text(
  //             'cancel'.tr,
  //             style: globalTextStyle(color: Colors.grey),
  //           ),
  //         ),
  //         Obx(
  //           () => ElevatedButton(
  //             onPressed: controller.isLoading.value
  //                 ? null
  //                 : () {
  //                     final val = amountController.text.trim();
  //                     if (val.isEmpty) return;
  //                     final amount = double.tryParse(val);
  //                     if (amount == null || amount <= 0) {
  //                       Get.snackbar(
  //                         'error'.tr,
  //                         'invalid_amount'.tr,
  //                         backgroundColor: Colors.red,
  //                         colorText: Colors.white,
  //                       );
  //                       return;
  //                     }
  //                     Get.back(); // Close dialog
  //                     _showCardBottomSheet(context, amount);
  //                   },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF1E88E5),
  //             ),
  //             child: Text(
  //               'continue'.tr,
  //               style: globalTextStyle(color: Colors.white),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showCardBottomSheet(BuildContext context, double amount) {
  //   Get.bottomSheet(
  //     Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //       ),
  //       child: SafeArea(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'enter_card_details'.tr,
  //               style: globalTextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             CardField(
  //               enablePostalCode: false,
  //               decoration: InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 labelText: 'card_details'.tr,
  //               ),
  //             ),
  //             const SizedBox(height: 30),
  //             SizedBox(
  //               width: double.infinity,
  //               child: Obx(
  //                 () => ElevatedButton(
  //                   onPressed: controller.isLoading.value
  //                       ? null
  //                       : () => controller.processTopUp(amount),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: const Color(0xFF1E88E5),
  //                     padding: const EdgeInsets.symmetric(vertical: 16),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   child: controller.isLoading.value
  //                       ? const SizedBox(
  //                           height: 20,
  //                           width: 20,
  //                           child: CircularProgressIndicator(
  //                             color: Colors.white,
  //                             strokeWidth: 2,
  //                           ),
  //                         )
  //                       : Text(
  //                           'pay_with_amount'.trParams({
  //                             'amount': '${CurrencyUtil.getUserCurrencySymbol()} ${amount.toStringAsFixed(2)}',
  //                           }),
  //                           style: globalTextStyle(
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     isScrollControlled: true,
  //   );
  // }
}
