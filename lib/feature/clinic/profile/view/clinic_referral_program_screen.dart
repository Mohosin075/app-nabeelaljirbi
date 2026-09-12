import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/utils/currency_util.dart';
import 'package:nabeelaljirbi_app/feature/clinic/wallet/controller/clinic_wallet_controller.dart';

class ClinicReferralProgramScreen extends StatelessWidget {
  const ClinicReferralProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClinicWalletController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'referral_program'.tr,
          style: globalTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xff1A1A1A),
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
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: const Color(0xFF1E88E5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: _buildReferralSection(controller),
        ),
      ),
    );
  }

  Widget _buildReferralSection(ClinicWalletController controller) {
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
                IconsPath.chartUp,
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
          _buildInfoCard(
            controller,
            0xFFFFF8E1,
            IconsPath.refarrelBonus,
            'Unclaimed Earnings',
            controller.currentEarnings,
            isCurrency: true,
            showClaimButton: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  controller,
                  0xFFF1F5F9,
                  IconsPath.reward,
                  'Total Earned',
                  controller.totalEarned,
                  isCurrency: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  controller,
                  0xFFE3F2FD,
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
    ClinicWalletController controller,
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
                              color: const Color(0xFF1E88E5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Claim',
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
}
