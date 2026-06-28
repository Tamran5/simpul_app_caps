import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/values/api_config.dart';

class ChangepasswordController extends GetxController {
  // ─── Text Controllers ──────────────────────────────────────────────
  final oldPasswordController     = TextEditingController();
  final newPasswordController     = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ─── State ────────────────────────────────────────────────────────
  var isLoading       = false.obs;
  var showOld         = false.obs;
  var showNew         = false.obs;
  var showConfirm     = false.obs;

  // ─── Validation state (real-time) ─────────────────────────────────
  var hasMinLength    = false.obs;
  var hasUppercase    = false.obs;
  var hasNumber       = false.obs;
  var passwordsMatch  = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Real-time validation saat user mengetik
    newPasswordController.addListener(_validateNewPassword);
    confirmPasswordController.addListener(_validateConfirm);
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _validateNewPassword() {
    final pw = newPasswordController.text;
    hasMinLength.value  = pw.length >= 8;
    hasUppercase.value  = pw.contains(RegExp(r'[A-Z]'));
    hasNumber.value     = pw.contains(RegExp(r'[0-9]'));
    _validateConfirm();
  }

  void _validateConfirm() {
    passwordsMatch.value = confirmPasswordController.text.isNotEmpty &&
        newPasswordController.text == confirmPasswordController.text;
  }

  bool get _isFormValid =>
      hasMinLength.value &&
      hasUppercase.value &&
      hasNumber.value &&
      passwordsMatch.value &&
      oldPasswordController.text.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════════
  // SUBMIT
  // ═══════════════════════════════════════════════════════════════════

  Future<void> gantiPassword() async {
    if (oldPasswordController.text.trim().isEmpty) {
      Get.snackbar('Perhatian', 'Masukkan kata sandi saat ini.',
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (!_isFormValid) {
      Get.snackbar('Perhatian', 'Pastikan semua syarat kata sandi terpenuhi.',
          backgroundColor: Colors.orange.shade100);
      return;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final response = await http.patch(
        Uri.parse(ApiConfig.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password_lama':        oldPasswordController.text.trim(),
          'password_baru':        newPasswordController.text.trim(),
          'konfirmasi_password':  confirmPasswordController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Berhasil ✓', 'Kata sandi berhasil diperbarui.',
            backgroundColor: const Color(0xFF3D6B5F),
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
      } else if (response.statusCode == 401) {
        Get.snackbar('Gagal', 'Kata sandi saat ini salah.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        Get.snackbar('Gagal', data['message'] ?? 'Terjadi kesalahan.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (_) {
      Get.snackbar('Error', 'Tidak dapat menghubungi server.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}