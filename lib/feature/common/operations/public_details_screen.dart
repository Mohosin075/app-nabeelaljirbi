import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/feature/patient/profile/controller/patient_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/doctor/profile/controller/doctor_profile_controller.dart';
import 'package:nabeelaljirbi_app/feature/clinic/profile/controller/clinic_profile_controller.dart';
import 'phase_one_api.dart';

class PublicDetailsScreen extends StatefulWidget {
  final String role;
  final String? initialAbout, initialImage;
  const PublicDetailsScreen({
    super.key,
    required this.role,
    this.initialAbout,
    this.initialImage,
  });
  @override
  State<PublicDetailsScreen> createState() => _PublicDetailsScreenState();
}

class _PublicDetailsScreenState extends State<PublicDetailsScreen> {
  late final TextEditingController about;
  XFile? image;
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    about = TextEditingController(text: widget.initialAbout ?? '');
  }

  @override
  void dispose() {
    about.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    try {
      final chosen = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (chosen != null && mounted)
        setState(() {
          image = chosen;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          error = '$e';
        });
    }
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final data = await PhaseOneApi.updatePublicDetails(
        widget.role,
        about: widget.role == 'PATIENT' ? null : about.text.trim(),
        imagePath: image?.path,
      );
      if (data is Map && data['accessToken'] is String)
        await SharedPrefHelper.saveToken(data['accessToken']);
      if (widget.role == 'PATIENT' &&
          Get.isRegistered<PatientProfileController>())
        await Get.find<PatientProfileController>().fetchProfile();
      if (widget.role == 'DOCTOR' &&
          Get.isRegistered<DoctorProfileController>())
        await Get.find<DoctorProfileController>().fetchProfile();
      if (widget.role == 'CLINIC' &&
          Get.isRegistered<ClinicProfileController>())
        await Get.find<ClinicProfileController>().fetchClinicProfile();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        setState(() {
          error = '$e';
          busy = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        phaseText('Photo & Public Details', 'الصورة والبيانات العامة'),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          phaseText(
            'Core information stays locked. Use a profile change request to correct approved details.',
            'تبقى البيانات الأساسية مقفلة. استخدم طلب تعديل الملف لتصحيح البيانات المعتمدة.',
          ),
        ),
        const SizedBox(height: 20),
        if (image != null)
          SizedBox(
            height: 160,
            child: Image.file(File(image!.path), fit: BoxFit.contain),
          )
        else if (widget.initialImage?.isNotEmpty == true)
          SizedBox(
            height: 160,
            child: Image.network(
              widget.initialImage!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        OutlinedButton(
          onPressed: busy ? null : pick,
          child: Text(phaseText('Choose photo', 'اختيار صورة')),
        ),
        if (widget.role != 'PATIENT')
          TextField(
            controller: about,
            maxLines: 5,
            maxLength: 5000,
            enabled: !busy,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: phaseText('Public description', 'الوصف العام'),
              border: const OutlineInputBorder(),
            ),
          ),
        if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red)),
        if (busy) const LinearProgressIndicator(),
        FilledButton(
          onPressed:
              busy ||
                  (image == null && about.text == (widget.initialAbout ?? ''))
              ? null
              : save,
          child: Text(phaseText('Save public details', 'حفظ البيانات العامة')),
        ),
      ],
    ),
  );
}
