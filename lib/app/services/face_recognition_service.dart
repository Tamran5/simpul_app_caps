// services/face_recognition_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/values/api_config.dart';
import 'face_embedding_service.dart';

class FaceRecognitionService {

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ── REGISTRASI WAJAH ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> registerFace({required File imageFile}) async {
    return _sendEmbedding(imageFile, ApiConfig.faceRegister, requireAuth: true);
  }

  // ── UPDATE WAJAH ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateFace({required File imageFile}) async {
    return _sendEmbedding(imageFile, ApiConfig.faceUpdate, requireAuth: true);
  }

  // ── LOGIN DENGAN WAJAH ────────────────────────────────────────────
  static Future<Map<String, dynamic>> loginFace({required File imageFile}) async {
    final result = await _sendEmbedding(imageFile, ApiConfig.faceLogin, requireAuth: false);

    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', result['data']['access_token']);
      await prefs.setString('refresh_token', result['data']['refresh_token']);
    }
    return result;
  }

  /// Helper terpusat: ekstrak embedding on-device lalu kirim sebagai JSON
  static Future<Map<String, dynamic>> _sendEmbedding(
    File imageFile,
    String url, {
    required bool requireAuth,
  }) async {
    try {
      final embedding = await FaceEmbeddingService.extractEmbedding(imageFile);

      final headers = {'Content-Type': 'application/json'};
      if (requireAuth) {
        final token = await _getToken();
        if (token != null) headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'embedding': embedding}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': body['message'], 'data': body};
      } else {
        return {'success': false, 'message': body['message'] ?? 'Proses wajah gagal.'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString().replaceFirst('Exception: ', '')};
    }
  }
}