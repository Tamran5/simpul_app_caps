import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/values/api_config.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  late final GoogleSignIn _googleSignIn;
  bool _isGoogleInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _googleSignIn = GoogleSignIn.instance;
  }

  Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
      );
      _isGoogleInitialized = true;
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // ── Helper Snackbar ────────────────────────────────────────────────────────
  void _showSnackbar(
    String title,
    String message, {
    Color bgColor = Colors.green,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bgColor.withOpacity(0.9),
      colorText: Colors.white,
      duration: duration,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(
        bgColor == Colors.green ? Icons.check_circle :
        bgColor == Colors.orange ? Icons.warning_amber :
        Icons.error_outline,
        color: Colors.white,
      ),
    );
  }

  // Menyimpan token dan langsung menuju home — dipakai oleh ketiga metode
  // login (email/password, Google, dan Face Recognition), karena sekarang
  // tidak ada lagi verifikasi wajah wajib setelah login berhasil.
  Future<void> _saveTokensAndGoHome(
    Map<String, dynamic> data,
    String welcomeMessage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access_token']);
    await prefs.setString('refresh_token', data['refresh_token']);

    _showSnackbar("Sukses", welcomeMessage);
    Get.offAllNamed('/home');
  }

  // ── Akun belum aktif (403) → auto kirim ulang OTP, lalu ke halaman OTP ────
  // Dipakai supaya user yang sempat daftar tapi keluar aplikasi sebelum
  // verifikasi tidak stuck di halaman login — mereka langsung diarahkan
  // untuk menyelesaikan verifikasi dengan kode OTP yang baru/sisa aktif.
  Future<void> _redirectToOtpVerification(String email) async {
    int remainingSeconds = 300;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.resendRegisterOtp),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        remainingSeconds = (data['remaining_seconds'] as int?) ?? 300;
      }
      // Kalau gagal (mis. koneksi timeout), tetap lanjut ke halaman OTP —
      // user masih bisa menekan tombol "Kirim Ulang OTP" manual di sana.
    } catch (_) {
      // sengaja diabaikan, lihat komentar di atas
    }

    await Future.delayed(const Duration(milliseconds: 600));
    Get.toNamed('/register-otp', arguments: {
      'email': email,
      'remainingSeconds': remainingSeconds,
    });
  }

  // ── LOGIN EMAIL & PASSWORD ─────────────────────────────────────────────────
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackbar(
        "Peringatan",
        "Email dan Kata Sandi wajib diisi!",
        bgColor: Colors.orange,
      );
      return;
    }

    final email = emailController.text.trim().toLowerCase();
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        emailController.clear();
        passwordController.clear();

        // Face Recognition sekarang adalah metode login TERPISAH.
        // Login manual yang berhasil langsung ke home, tanpa verifikasi
        // wajah tambahan (2FA lama sudah dihapus).
        await _saveTokensAndGoHome(data, "Selamat datang kembali di Simpul!");

      } else if (response.statusCode == 403) {
        _showSnackbar(
          "Akun Belum Aktif",
          data['message'] ?? "Silakan verifikasi email terlebih dahulu!",
          bgColor: Colors.orange,
          duration: const Duration(seconds: 4),
        );

        // Jangan bersihkan passwordController di sini — biarkan tetap ada
        // supaya kalau user kembali dari halaman OTP, tidak perlu ketik ulang.
        await _redirectToOtpVerification(email);

      } else {
        _showSnackbar(
          "Gagal Masuk",
          data['message'] ?? "Email atau kata sandi salah.",
          bgColor: Colors.redAccent,
        );
      }

    } catch (e) {
      _showSnackbar(
        "Koneksi Gagal",
        "Tidak dapat terhubung ke server. Pastikan IP Address benar.",
        bgColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── LOGIN GOOGLE ───────────────────────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    isLoading.value = true;

    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();

      GoogleSignInAccount googleUser;
      try {
        googleUser = await _googleSignIn.authenticate();
      } catch (e) {
        _showSnackbar(
          "Google Sign-In Gagal",
          "Proses login Google dibatalkan atau gagal.",
          bgColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _showSnackbar(
          "Gagal",
          "Sistem tidak dapat mengenali akun Google Anda.",
          bgColor: Colors.orange,
        );
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.googleLogin),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"google_id_token": idToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sama seperti login manual: langsung ke home, tanpa verifikasi
        // wajah tambahan.
        await _saveTokensAndGoHome(data, "Berhasil masuk dengan Google!");
      } else {
        _showSnackbar(
          "Gagal Masuk",
          data['message'] ?? "Gagal memverifikasi akun Google.",
          bgColor: Colors.redAccent,
        );
      }

    } catch (e) {
      _showSnackbar(
        "Kesalahan",
        "Terjadi masalah saat menghubungi layanan Google.",
        bgColor: Colors.redAccent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── LOGIN FACE RECOGNITION (opsi login mandiri) ─────────────────────────────
  void loginWithFace() {
    Get.toNamed('/face-scan', arguments: {'mode': 'login'});
  }

  void goToRegister() => Get.toNamed('/register');
  void forgotPassword() => Get.toNamed('/forgot-password');

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}