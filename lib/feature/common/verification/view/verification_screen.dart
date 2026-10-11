import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';
import 'package:nabeelaljirbi_app/core/widgets/blue_badge_widget.dart';
import '../controller/verification_controller.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerificationController());
    final notesController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xffF0F4FA),
      appBar: AppBar(
        title: Text(
          'blue_badge_verification'.tr,
          style: globalTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xff1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xff1E293B), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final status = controller.verificationStatus.value;
        final hasSubmittedDocs = controller.documents.isNotEmpty;

        return RefreshIndicator(
          onRefresh: controller.fetchStatus,
          color: AppColors.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card at top
                _buildStatusCard(controller, context),
                const SizedBox(height: 20),

                // If documents have already been submitted, show previously submitted documents
                if (hasSubmittedDocs && (status == 'PENDING' || status == 'APPROVED' || status == 'REJECTED')) ...[
                  _buildSubmittedDocumentsSection(controller, context),
                  const SizedBox(height: 20),
                ],

                // Show document upload section if NOT_SUBMITTED or REJECTED
                if (status == 'NOT_SUBMITTED' || status == '' || status == 'REJECTED') ...[
                  _buildUploadSection(controller, context, notesController),
                ],

                // Legal Disclaimer Footer
                const SizedBox(height: 20),
                _buildLegalDisclaimerNotice(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // -------------------------------------------------------------
  // Top Status Card
  // -------------------------------------------------------------
  Widget _buildStatusCard(VerificationController controller, BuildContext context) {
    final status = controller.verificationStatus.value;
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData icon;

    switch (status) {
      case 'APPROVED':
        bgColor = const Color(0xffF0FDF4);
        borderColor = const Color(0xff86EFAC);
        iconColor = const Color(0xff16A34A);
        icon = Icons.check_circle_outline;
        break;
      case 'PENDING':
        bgColor = const Color(0xffFFFBEB);
        borderColor = const Color(0xffFCD34D);
        iconColor = const Color(0xffD97706);
        icon = Icons.hourglass_empty;
        break;
      case 'REJECTED':
        bgColor = const Color(0xffFFF1F2);
        borderColor = const Color(0xffFCA5A5);
        iconColor = const Color(0xffDC2626);
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = const Color(0xffF8FAFC);
        borderColor = const Color(0xffE2E8F0);
        iconColor = const Color(0xff94A3B8);
        icon = Icons.shield_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 26, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'verification_status'.tr,
                      style: globalTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.statusLabel,
                      style: globalTextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.badgeActive.value) ...[
                GestureDetector(
                  onTap: () => BlueBadgeWidget.showBlueBadgeNoticeDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xffEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xff93C5FD)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, size: 15, color: Color(0xff1D9BF0)),
                        const SizedBox(width: 4),
                        Text(
                          'active'.tr,
                          style: globalTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff1D9BF0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (status == 'APPROVED') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                controller.badgeActive.value
                    ? 'badge_active_note'.tr
                    : 'badge_pending_activation'.tr,
                style: globalTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff374151),
                  lineHeight: 1.6,
                ),
              ),
            ),
          ],

          if (status == 'PENDING') ...[
            const SizedBox(height: 14),
            Text(
              'طلبك قيد المراجعة لدى فريق الإدارة. سيتم إشعارك فور اكتمال التدقيق.',
              style: globalTextStyle(
                fontSize: 12,
                color: const Color(0xff92400E),
                lineHeight: 1.6,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],

          if (status == 'REJECTED' && controller.adminNote.value.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'rejection_reason'.tr,
                    style: globalTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff991B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.adminNote.value,
                    style: globalTextStyle(
                      fontSize: 12,
                      color: const Color(0xff374151),
                      lineHeight: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Submitted Documents (Preview Section)
  // -------------------------------------------------------------
  Widget _buildSubmittedDocumentsSection(VerificationController controller, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_shared_outlined, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'الوثائق المقدمة (Submitted Documents)',
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...controller.documents.map((doc) {
            final title = doc['title'] ?? 'وثيقة رسمية';
            final url = doc['url'] ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: const Color(0xffE2E8F0),
                      child: url.isNotEmpty
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.description_outlined,
                                color: Color(0xff64748B),
                              ),
                            )
                          : const Icon(Icons.description_outlined, color: Color(0xff64748B)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: globalTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'تم الرفع بنجاح (Uploaded)',
                          style: globalTextStyle(fontSize: 11, color: const Color(0xff16A34A)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, color: AppColors.primaryColor),
                    onPressed: () {
                      if (url.isNotEmpty) {
                        _showImagePreviewDialog(context, url, title);
                      }
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Native Upload Section (Industry Standard)
  // -------------------------------------------------------------
  Widget _buildUploadSection(
    VerificationController controller,
    BuildContext context,
    TextEditingController notesController,
  ) {
    final isClinic = controller.entityType.value == 'CLINIC';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.verificationStatus.value == 'REJECTED') ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffFED7AA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xffEA580C), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'resubmit_documents'.tr,
                    style: globalTextStyle(
                      fontSize: 13,
                      color: const Color(0xff9A3412),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Text(
          'upload_documents'.tr,
          style: globalTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xff1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'الرجاء التقاط أو اختيار الوثائق الرسمية المطلوبة للتحقق والتوثيق.',
          style: globalTextStyle(
            fontSize: 13,
            color: const Color(0xff64748B),
            lineHeight: 1.5,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),

        // Document 1: License Card
        Obx(() => _buildNativeDocumentCard(
              context: context,
              title: isClinic ? 'Clinic Operating License' : 'medical_license_doc'.tr,
              subtitle: 'رخصة مزاولة المهنة أو ترخيص العيادة الرسمي',
              icon: Icons.medical_information_outlined,
              iconColor: const Color(0xff0369A1),
              isUploading: controller.isUploadingLicense.value,
              uploadedUrl: controller.licenseUploadedUrl.value,
              localFile: controller.licenseLocalFile.value,
              onTapPick: () => _showSourceSelectionSheet(
                context: context,
                onSelectSource: (source) => controller.pickAndUploadLicense(source),
              ),
              onRemove: () => controller.removeLicense(),
            )),
        const SizedBox(height: 14),

        // Document 2: ID / Registration Card
        Obx(() => _buildNativeDocumentCard(
              context: context,
              title: isClinic ? 'Commercial Registration' : 'id_proof_doc'.tr,
              subtitle: 'بطاقة الهوية الوطنية أو السجل التجاري',
              icon: Icons.badge_outlined,
              iconColor: const Color(0xff7C3AED),
              isUploading: controller.isUploadingId.value,
              uploadedUrl: controller.idUploadedUrl.value,
              localFile: controller.idLocalFile.value,
              onTapPick: () => _showSourceSelectionSheet(
                context: context,
                onSelectSource: (source) => controller.pickAndUploadIdProof(source),
              ),
              onRemove: () => controller.removeIdProof(),
            )),
        const SizedBox(height: 16),

        // Optional Notes
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffE2E8F0)),
          ),
          child: TextField(
            controller: notesController,
            maxLines: 3,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ملاحظات إضافية للإدارة (اختياري)...',
              hintStyle: globalTextStyle(
                fontSize: 13,
                color: const Color(0xffA0AEC0),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        Obx(() {
          final hasAnyDoc = controller.licenseUploadedUrl.value.isNotEmpty ||
              controller.idUploadedUrl.value.isNotEmpty;

          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (!hasAnyDoc || controller.isSubmitting.value)
                  ? null
                  : () async {
                      final docs = <Map<String, dynamic>>[];
                      if (controller.licenseUploadedUrl.value.isNotEmpty) {
                        docs.add({
                          'title': isClinic ? 'Clinic License' : 'Medical License',
                          'url': controller.licenseUploadedUrl.value,
                          'type': 'MEDICAL_LICENSE',
                          'uploadedAt': DateTime.now().toIso8601String(),
                        });
                      }
                      if (controller.idUploadedUrl.value.isNotEmpty) {
                        docs.add({
                          'title': isClinic ? 'Commercial Registration' : 'National ID',
                          'url': controller.idUploadedUrl.value,
                          'type': 'ID_PROOF',
                          'uploadedAt': DateTime.now().toIso8601String(),
                        });
                      }

                      final success = await controller.submitVerification(
                        docs: docs,
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      );

                      if (success) {
                        Get.snackbar(
                          'تم الإرسال بنجاح',
                          'verification_submitted_success'.tr,
                          backgroundColor: const Color(0xffF0FDF4),
                          colorText: const Color(0xff15803D),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        Get.snackbar(
                          'خطأ',
                          'حدث خطأ أثناء الإرسال. الرجاء المحاولة مرة أخرى.',
                          backgroundColor: const Color(0xffFEE2E2),
                          colorText: const Color(0xff991B1B),
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                disabledBackgroundColor: const Color(0xffCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'submit_for_verification'.tr,
                          style: globalTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),
      ],
    );
  }

  // -------------------------------------------------------------
  // Native Interactive Document Card
  // -------------------------------------------------------------
  Widget _buildNativeDocumentCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isUploading,
    required String uploadedUrl,
    required File? localFile,
    required VoidCallback onTapPick,
    required VoidCallback onRemove,
  }) {
    final bool isReady = uploadedUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isReady
              ? const Color(0xff86EFAC)
              : isUploading
                  ? const Color(0xff93C5FD)
                  : const Color(0xffE2E8F0),
          width: isReady ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: globalTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: globalTextStyle(
                          fontSize: 11,
                          color: const Color(0xff64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isReady)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xffF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xff86EFAC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 12, color: Color(0xff16A34A)),
                        const SizedBox(width: 4),
                        Text(
                          'Ready',
                          style: globalTextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Uploading State
          if (isUploading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'جاري رفع الوثيقة بأمان إلى السحابة...',
                    style: globalTextStyle(fontSize: 12, color: const Color(0xff64748B)),
                  ),
                ],
              ),
            )
          // Uploaded State with Preview
          else if (isReady)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffE2E8F0)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showImagePreviewDialog(context, uploadedUrl, title),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 52,
                        height: 52,
                        color: const Color(0xffE2E8F0),
                        child: localFile != null
                            ? Image.file(localFile, fit: BoxFit.cover)
                            : Image.network(
                                uploadedUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.description_outlined,
                                  color: Color(0xff64748B),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document Attached',
                          style: globalTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () => _showImagePreviewDialog(context, uploadedUrl, title),
                          child: Text(
                            'اضغط للمعاينة الكاملة',
                            style: globalTextStyle(
                              fontSize: 11,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onTapPick,
                    icon: const Icon(Icons.refresh, size: 14, color: Color(0xff475569)),
                    label: Text(
                      'تغيير',
                      style: globalTextStyle(fontSize: 11, color: const Color(0xff475569)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xffEF4444)),
                    onPressed: onRemove,
                  ),
                ],
              ),
            )
          // Empty State (Tap to Pick)
          else
            GestureDetector(
              onTap: onTapPick,
              child: Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xffCBD5E1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اضغط لرفع الوثيقة (كاميرا / استوديو)',
                          style: globalTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'JPG, PNG • الحد الأقصى 15MB',
                          style: globalTextStyle(
                            fontSize: 10,
                            color: const Color(0xff94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Camera / Gallery Source BottomSheet
  // -------------------------------------------------------------
  void _showSourceSelectionSheet({
    required BuildContext context,
    required Function(ImageSource source) onSelectSource,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xffE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'اختيار مصدر الوثيقة (Upload Document)',
                style: globalTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff1E293B),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xffEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryColor),
                ),
                title: Text(
                  'التقاط صورة بالكاميرا (Camera)',
                  style: globalTextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'تصوير الوثيقة مباشرة',
                  style: globalTextStyle(fontSize: 11, color: const Color(0xff64748B)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onSelectSource(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xffF0FDF4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Color(0xff16A34A)),
                ),
                title: Text(
                  'اختيار من الاستوديو (Gallery)',
                  style: globalTextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'اختيار ملف أو صورة محفوظة',
                  style: globalTextStyle(fontSize: 11, color: const Color(0xff64748B)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onSelectSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Full Image Preview Modal Dialog
  // -------------------------------------------------------------
  void _showImagePreviewDialog(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: globalTextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primaryColor),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: const Color(0xffF1F5F9),
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 48, color: Color(0xff94A3B8)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'إغلاق (Close)',
                        style: globalTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xff64748B)),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Verbatim Arabic Legal Disclaimer
  // -------------------------------------------------------------
  Widget _buildLegalDisclaimerNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Color(0xff64748B)),
              const SizedBox(width: 8),
              Text(
                'verification_notice_title'.tr,
                style: globalTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'verification_notice_content'.tr,
              style: globalTextStyle(
                fontSize: 11,
                color: const Color(0xff64748B),
                lineHeight: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
