import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';

class ClinicCustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ClinicCustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildNavItem(
                context,
                0,
                IconsPath.homeActive,
                IconsPath.homeInactive,
                'home'.tr,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                1,
                IconsPath.appointmentActive,
                IconsPath.appointmentInactive,
                'appointment'.tr,
              ),
            ),

            Expanded(
              child: _buildNavItem(
                context,
                2,
                IconsPath.doctorActive,
                IconsPath.doctorInactive,
                'doctors'.tr,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                3,
                IconsPath.walletActive,
                IconsPath.walletInactive,
                'wallet'.tr,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                context,
                4,
                IconsPath.profileActive,
                IconsPath.profileInactive,
                'profile'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String activeIcon,
    String inactiveIcon,
    String label,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Align(
        alignment: Alignment.center,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? activeIcon : inactiveIcon,
              width: (screenWidth * 0.064).clamp(20.0, 26.0),
              height: (screenWidth * 0.064).clamp(20.0, 26.0),
              colorFilter: isSelected
                  ? const ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    )
                  : ColorFilter.mode(
                      AppColors.darkColor.withValues(alpha: 0.4),
                      BlendMode.srcIn,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: globalTextStyle(
                fontSize: (screenWidth * 0.026).clamp(9.0, 12.0),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.darkColor.withValues(alpha: 0.4),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
