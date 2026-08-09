import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/values/api_config.dart';

class RegisterOtpController extends GetxController {
  // ── Sesuaikan kalau nama route di project kamu berbeda ────────────────────
  // FaceScanController butuh Get.arguments berupa {'mode':..., 'origin':...}.
  // Setelah wajah berhasil didaftarkan (mode 'register', origin 'onboarding'),
  // FaceScanController SENDIRI yang otomatis pindah ke '/connect-partner'.
  static const String faceScanRoute = '/face-scan';
  static const String homeRoute = '/home';

  late final String email;

  // Satu TextField tersembunyi menampung semua 6 digit — backspace, cursor,
  // dan keyboard number pad jadi bawaan Flutter (tidak perlu hack FocusNode
  // per-kotak yang sebelumnya menyebabkan crash "child into a parent of itself").
  // 6 kotak yang terlihat di UI murni dekorasi, isinya diambil dari otpController.text.
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  final isVerifying = false.obs;
  final isResending = false.obs;
  final remainingSeconds = 0.obs;
  final errorText = ''.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    email = (args is Map ? args['email'] : null) ?? '';
    final initialSeconds = (args is Map ? args['remainingSeconds'] : null);
    remainingSeconds.value = (initialSeconds is int) ? initialSeconds : 300;
    _startTimer();

    otpController.addListener(_onOtpTextChanged);

    // Fokus & buka keyboard otomatis saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpFocusNode.requestFocus();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.removeListener(_onOtpTextChanged);
    otpController.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }

  void _onOtpTextChanged() {
    if (errorText.value.isNotEmpty) errorText.value = '';
    if (otpController.text.length == 6) {
      otpFocusNode.unfocus();
      verifyOtp();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds.value <= 0) {
        t.cancel();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  String get timerLabel {
    if (remainingSeconds.value <= 0) return 'Kedaluwarsa';
    final m = remainingSeconds.value ~/ 60;
    final s = remainingSeconds.value % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isExpired => remainingSeconds.value <= 0;

  String get maskedEmail {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name.substring(0, 1)}***@$domain';
    return '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain';
  }

  String get combinedOtp => otpController.text;

  void _clearDigits() {
    otpController.clear();
    otpFocusNode.requestFocus();
  }

  Future<void> verifyOtp() async {
    final otp = combinedOtp;
    if (otp.length != 6) {
      errorText.value = 'Masukkan 6 digit kode OTP.';
      return;
    }

    isVerifying.value = true;
    errorText.value = '';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyRegisterOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access_token'] ?? '');
        await prefs.setString('refresh_token', data['refresh_token'] ?? '');

        Get.snackbar(
          'Berhasil',
          data['message'] ?? 'Verifikasi berhasil!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );

        final faceRegistered = data['face_registered'] == true;

        await Future.delayed(const Duration(milliseconds: 500));
        if (faceRegistered) {
          // Kasus langka: wajah ternyata sudah terdaftar sebelumnya
          // (mis. user sempat daftar ulang) → langsung ke Home.
          Get.offAllNamed(homeRoute);
        } else {
          // Alur normal onboarding: Face Scan akan otomatis lanjut ke
          // '/connect-partner' setelah wajah berhasil didaftarkan.
          Get.offAllNamed(faceScanRoute, arguments: {
            'mode': 'register',
            'origin': 'onboarding',
          });
        }
      } else {
        errorText.value = data['message'] ?? 'Kode OTP salah atau kedaluwarsa.';
        _clearDigits();
      }
    } catch (_) {
      errorText.value = 'Tidak dapat terhubung ke server.';
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!isExpired || isResending.value) return;

    isResending.value = true;
    errorText.value = '';
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resendRegisterOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        remainingSeconds.value = (data['remaining_seconds'] as int?) ?? 300;
        _startTimer();
        _clearDigits();
        Get.snackbar(
          'Terkirim',
          data['message'] ?? 'Kode OTP baru telah dikirim.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );
      } else {
        Get.snackbar(
          'Gagal',
          data['message'] ?? 'Gagal mengirim ulang kode.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Koneksi Gagal',
        'Tidak dapat terhubung ke server.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isResending.value = false;
    }
  }

  void goBackToRegister() => Get.back();
}