import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/network_caller/endpoints.dart';

String phaseText(String en, String ar) =>
    Get.locale?.languageCode == 'ar' ? ar : en;

String phaseFieldLabel(String key) {
  final labels = <String, List<String>>{
    'fullName': ['Full name', 'الاسم الكامل'],
    'phoneNumber': ['Phone number', 'رقم الهاتف'],
    'dateOfBirth': ['Date of birth', 'تاريخ الميلاد'],
    'email': ['Email', 'البريد الإلكتروني'],
    'gender': ['Gender', 'الجنس'],
    'country': ['Country', 'الدولة'],
    'city': ['City', 'المدينة'],
    'address': ['Address', 'العنوان'],
    'clinicName': ['Clinic name', 'اسم العيادة'],
    'managerName': ['Manager name', 'اسم المدير'],
    'managerPhone': ['Manager phone', 'هاتف المدير'],
    'contactPhone': ['Contact phone', 'هاتف التواصل'],
    'location': ['Location', 'الموقع'],
    'latitude': ['Latitude', 'خط العرض'],
    'longitude': ['Longitude', 'خط الطول'],
    'timezone': ['Time zone', 'المنطقة الزمنية'],
    'speciality': ['Specialty', 'التخصص'],
    'qualifications': ['Qualifications', 'المؤهلات'],
    'experience': ['Experience', 'الخبرة'],
    'licenseNumber': ['License number', 'رقم الترخيص'],
    'consultFee': ['Consultation fee', 'رسوم الاستشارة'],
  };
  final label = labels[key];
  return label == null ? key : phaseText(label[0], label[1]);
}

class PhaseOneApi {
  static Uri uri(String path, Map<String, dynamic>? query) =>
      Uri.parse('${Urls.baseUrl}/phase-one/$path').replace(
        queryParameters: query == null
            ? null
            : {
                for (final e in query.entries)
                  if (e.value != null && e.value.toString().isNotEmpty)
                    e.key: e.value.toString(),
              },
      );
  static Map<String, String> get headers {
    final token = SharedPrefHelper.getAccessToken() ?? '';
    return {
      'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<dynamic> call(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    http.Client? client,
  }) async {
    final request = http.Request(method, uri(path, query))
      ..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
    final response = await http.Response.fromStream(
      await (client == null ? request.send() : client.send(request)).timeout(
        const Duration(seconds: 45),
      ),
    );
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        phaseText(
          'The server returned an unreadable response. Try again.',
          'استجابة الخادم غير قابلة للقراءة. حاول مرة أخرى.',
        ),
      );
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] == false) {
      throw Exception(data['message'] ?? 'Request failed');
    }
    return data['data'];
  }

  static Future<Uint8List> download(
    String kind,
    String format,
    Map<String, dynamic> query, {
    http.Client? client,
  }) async {
    final response =
        await (client == null
                ? http.get(
                    uri('reports/$kind/$format', query),
                    headers: headers,
                  )
                : client.get(
                    uri('reports/$kind/$format', query),
                    headers: headers,
                  ))
            .timeout(const Duration(seconds: 90));
    if (response.statusCode != 200) {
      try {
        throw Exception(jsonDecode(response.body)['message']);
      } on FormatException {
        throw Exception('Unable to download report');
      }
    }
    return response.bodyBytes;
  }

  static Future<dynamic> updatePublicDetails(
    String role, {
    String? about,
    String? imagePath,
    http.Client? client,
  }) async {
    final paths = {
      'PATIENT': 'patient/profile-update',
      'DOCTOR': 'doctor/profile-update',
      'CLINIC': 'clinic/update-info',
    };
    if (!paths.containsKey(role))
      throw Exception(
        'Public profile editing is not available for this account',
      );
    final request = http.MultipartRequest(
      'PATCH',
      Uri.parse('${Urls.baseUrl}/${paths[role]}'),
    );
    request.headers['Authorization'] = headers['Authorization']!;
    request.fields['data'] = jsonEncode({
      if (role != 'PATIENT' && about != null) 'about': about,
    });
    if (imagePath != null)
      request.files.add(
        await http.MultipartFile.fromPath(
          role == 'CLINIC' ? 'companyLogo' : 'profilePicture',
          imagePath,
          contentType: MediaType(
            'image',
            imagePath.toLowerCase().endsWith('.png') ? 'png' : 'jpeg',
          ),
        ),
      );
    final response = await http.Response.fromStream(
      await (client == null ? request.send() : client.send(request)).timeout(
        const Duration(seconds: 60),
      ),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        data['success'] == false)
      throw Exception(data['message'] ?? 'Unable to save public details');
    return data['data'];
  }
}
