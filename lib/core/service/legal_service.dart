import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';
import 'package:nabeelaljirbi_app/core/style/global_text_style.dart';

class LegalDocumentModel {
  final String id;
  final String role;
  final String title;
  final String? titleAr;
  final String content;
  final String? contentAr;
  final String version;
  final DateTime effectiveDate;
  final bool requireReacceptance;

  LegalDocumentModel({
    required this.id,
    required this.role,
    required this.title,
    this.titleAr,
    required this.content,
    this.contentAr,
    required this.version,
    required this.effectiveDate,
    required this.requireReacceptance,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    return LegalDocumentModel(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['titleAr'],
      content: json['content'] ?? '',
      contentAr: json['contentAr'],
      version: json['version'] ?? '1.0',
      effectiveDate: json['effectiveDate'] != null
          ? DateTime.tryParse(json['effectiveDate'].toString()) ??
              DateTime.now()
          : DateTime.now(),
      requireReacceptance: json['requireReacceptance'] == true,
    );
  }

  String get localizedTitle {
    if (Get.locale?.languageCode == 'ar' &&
        titleAr != null &&
        titleAr!.isNotEmpty) {
      return titleAr!;
    }
    return title;
  }

  String get localizedContent {
    if (Get.locale?.languageCode == 'ar' &&
        contentAr != null &&
        contentAr!.isNotEmpty) {
      return contentAr!;
    }
    return content;
  }
}

class LegalService {
  // 1. Fetch active legal document for a specific role
  static Future<LegalDocumentModel?> fetchActiveDocument(String role) async {
    try {
      final url = '${Urls.baseUrl}/legal-documents/active?role=${role.toUpperCase()}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['data'] != null) {
          return LegalDocumentModel.fromJson(decoded['data']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching active legal document: $e');
    }
    return null;
  }

  // 2. Accept agreement (records version & timestamp in backend)
  static Future<bool> acceptAgreement(
    String documentId, {
    String? version,
  }) async {
    try {
      final token = SharedPrefHelper.getAccessToken();
      if (token == null || token.isEmpty) return false;

      final url = '${Urls.baseUrl}/legal-documents/accept';
        final Map<String, dynamic> bodyData = {'documentId': documentId};
        if (version != null) bodyData['documentVersion'] = version;

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
          body: jsonEncode(bodyData),
        );

      debugPrint('Accept Agreement Response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error accepting legal document: $e');
      return false;
    }
  }

  // 3. Check if user needs re-acceptance
  static Future<Map<String, dynamic>> checkAcceptanceStatus() async {
    try {
      final token = SharedPrefHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        return {'needsAcceptance': false};
      }

      final url = '${Urls.baseUrl}/legal-documents/check-status';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        return decoded['data'] ?? {'needsAcceptance': false};
      }
    } catch (e) {
      debugPrint('Error checking legal acceptance status: $e');
    }
    return {'needsAcceptance': false};
  }

  // 4. View Document BottomSheet
  static void showLegalBottomSheet(
    BuildContext context, {
    required String role,
    LegalDocumentModel? preloadedDoc,
    VoidCallback? onAccepted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<LegalDocumentModel?>(
          future: preloadedDoc != null
              ? Future.value(preloadedDoc)
              : fetchActiveDocument(role),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 350,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final doc = snapshot.data;
            final String title = doc != null
                ? doc.localizedTitle
                : '${role.capitalizeFirst} Terms of Service';
            final String content = doc != null
                ? doc.localizedContent
                : 'terms_content'.tr;
            final String version = doc?.version ?? '1.0';

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: globalTextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Version $version',
                                style: globalTextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: globalTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (doc != null) {
                            acceptAgreement(doc.id, version: doc.version);
                          }
                          if (onAccepted != null) onAccepted();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'i_agree'.tr.isNotEmpty ? 'i_agree'.tr : 'I Understand & Agree',
                          style: globalTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 5. Check and prompt re-acceptance if terms changed
  static Future<void> checkAndPromptReacceptance(BuildContext context) async {
    final status = await checkAcceptanceStatus();
    if (status['needsAcceptance'] == true && status['document'] != null) {
      final doc = LegalDocumentModel.fromJson(status['document']);
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          bool isSubmitting = false;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return PopScope(
                canPop: false,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'terms_updated_title'.tr.isNotEmpty
                              ? 'terms_updated_title'.tr
                              : 'Terms of Service Updated',
                          style: globalTextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'terms_updated_desc'.tr.isNotEmpty
                            ? 'terms_updated_desc'.tr
                            : 'We have updated our terms (Version ${doc.version}). Please review and accept the new terms to continue using Salama.',
                        style: globalTextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () {
                          showLegalBottomSheet(
                            context,
                            role: doc.role,
                            preloadedDoc: doc,
                            onAccepted: () {
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 18,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'read_full_terms'.tr.isNotEmpty
                                      ? 'read_full_terms'.tr
                                      : 'Read full terms & conditions',
                                  style: globalTextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setDialogState(() {
                                  isSubmitting = true;
                                });
                                await acceptAgreement(
                                  doc.id,
                                  version: doc.version,
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'i_agree'.tr.isNotEmpty
                                    ? 'i_agree'.tr
                                    : 'I Agree & Continue',
                                style: globalTextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }
}
