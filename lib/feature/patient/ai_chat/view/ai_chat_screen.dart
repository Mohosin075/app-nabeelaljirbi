import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/icons_path.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/feature/patient/ai_chat/controller/ai_chat_controller.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';

class AiChatScreen extends StatelessWidget {
  AiChatScreen({super.key});

  final AiChatController controller = Get.put(AiChatController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'ai_chat_title'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildDisclaimerBanner(),
          Expanded(
            child: Obx(() {
              if (!controller.hasMessages) {
                return _buildWelcomeState();
              }
              return _buildChatList();
            }),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'hi_im_your'.tr,
                    style: globalTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff1A1A1A),
                    ),
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: SvgPicture.asset(
                      IconsPath.aiMagic,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  TextSpan(
                    text: 'medical'.tr,
                    style: globalTextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'assistant_excl'.tr,
              style: globalTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xff1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ai_welcome_desc'.tr,
              textAlign: TextAlign.center,
              style: globalTextStyle(
                fontSize: 14,
                color: const Color(0xff636F85),
                lineHeight: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Obx(
      () => ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          if (message['isUser'] == true) {
            return _buildUserBubble(message['text']);
          } else {
            return _buildAiBubble(message);
          }
        },
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E9F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: globalTextStyle(fontSize: 14, color: const Color(0xff1A1A1A)),
        ),
      ),
    );
  }

  Widget _buildAiBubble(Map<String, dynamic> message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message['text'] != null &&
                message['text'].toString().trim().isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message['text'],
                  style: globalTextStyle(
                    fontSize: 14,
                    color: const Color(0xff1A1A1A),
                    lineHeight: 1.4,
                  ),
                ),
              ),
            if (message['doctorRecommendation'] != null) ...[
              if (message['text'] != null &&
                  message['text'].toString().trim().isNotEmpty)
                const SizedBox(height: 12),
              _buildDoctorCard(message['doctorRecommendation']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return GestureDetector(
      onTap: () {
        if (doctor['id'] != null) {
          Get.toNamed(AppRoutes.doctorDetails, arguments: doctor['id']);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                doctor['image'],
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFF5F7FA),
                  child: const Icon(Icons.person, color: Color(0xFF99A7BF)),
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
                      Flexible(
                        child: Text(
                          doctor['name'],
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                    doctor['specialty'],
                    style: globalTextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    doctor['experience'],
                    style: globalTextStyle(
                      fontSize: 11,
                      color: const Color(0xff636F85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    textAlign: TextAlign.end,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: doctor['fee'],
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: ' ly'.tr,
                          style: globalTextStyle(
                            fontSize: 10,
                            color: const Color(0xff636F85),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(IconsPath.star, width: 12, height: 12),
                      const SizedBox(width: 4),
                      Text(
                        doctor['rating'],
                        style: globalTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' (${doctor['reviews']})',
                        style: globalTextStyle(
                          fontSize: 11,
                          color: const Color(0xff636F85),
                        ),
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
  }

  Widget _buildInputBar(BuildContext context) {
    return Obx(() {
      if (controller.isConfigLoading.value) {
        return const SizedBox.shrink();
      }

      final bool isLimitReached = controller.chatLimit.value < 1;
      final bool isDisabled = !controller.isChatEnabled.value;

      if (isDisabled || isLimitReached) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          color: Colors.white,
          child: Center(
            child: Text(
              'limit_complete_message'.tr,
              style: globalTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: controller.hasMessages
                        ? 'ask'.tr
                        : 'describe_symptoms_hint'.tr,
                    hintStyle: globalTextStyle(
                      fontSize: 14,
                      color: const Color(0xff636F85),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                controller.sendMessage(textController.text);
                textController.clear();
              },
              child: SvgPicture.asset(
                IconsPath.send,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Light warm amber background
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFFFE0B2), // Soft amber border
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFE65100), // Warning orange icon
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'medical_disclaimer'.tr,
              style: globalTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB78103), // Deep warm amber text
                lineHeight: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
