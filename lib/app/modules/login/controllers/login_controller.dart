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

  // 1. FUNGSI DIPERBARUI: Menghapus 'scopes' sesuai aturan Google v7+
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

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Peringatan", 
        "Email dan Kata Sandi wajib diisi!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String accessToken = data['access_token'];
        String refreshToken = data['refresh_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        Get.snackbar(
          "Sukses", 
          "Selamat datang kembali di Simpul!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );

        emailController.clear();
        passwordController.clear();
        Get.offAllNamed('/home');

      } else if (response.statusCode == 403) {
        Get.snackbar(
          "Akun Belum Aktif", 
          data['message'] ?? "Silakan lakukan verifikasi email terlebih dahulu!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          "Gagal Masuk", 
          data['message'] ?? "Email atau kata sandi salah.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Koneksi Gagal", 
        "Tidak dapat terhubung ke pelayan server. Pastikan IP Address benar.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false; 
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();

      // 2. FUNGSI DIPERBARUI: authenticate() pasti mengembalikan nilai (non-null) jika sukses.
      // Jika user membatalkan, ia akan langsung masuk ke blok catch.
      GoogleSignInAccount googleUser;
      try {
        googleUser = await _googleSignIn.authenticate();
      } catch (e) {
        // Ini akan menangkap aksi ketika pengguna menutup pop-up akun Google
        print("🚨 ERROR GOOGLE SIGN-IN LOKAL: $e");
        Get.snackbar(
          "Google Sign-In Gagal", 
          "Pesan dari Google: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          duration: const Duration(seconds: 5),
        );
        isLoading.value = false;
        return; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final response = await http.post(
          Uri.parse(ApiConfig.googleLogin),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "google_id_token": idToken,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          String accessToken = data['access_token'];
          String refreshToken = data['refresh_token'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('refresh_token', refreshToken);

          Get.snackbar(
            "Sukses", 
            "Berhasil masuk dengan Google!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
          );

          Get.offAllNamed('/home');

        } else {
          Get.snackbar(
            "Gagal Masuk", 
            data['message'] ?? "Gagal memverifikasi akun Google.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withOpacity(0.1),
          );
        }
      } else {
         Get.snackbar(
          "Gagal", 
          "Sistem tidak dapat mengenali identitas akun Google Anda.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
        );
      }
    } catch (error) {
      print("Error Google Sign-In: $error");
      Get.snackbar(
        "Kesalahan", 
        "Terjadi masalah saat menghubungi layanan Google.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed('/register'); 
  }

  void forgotPassword() {
    Get.toNamed('/forgot-password');
  }

  @override
  void onClose() {
    super.onClose();
  }
}