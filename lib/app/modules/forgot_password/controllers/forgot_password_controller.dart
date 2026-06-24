import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/values/api_config.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController(); 

  var isLoading = false.obs;
  var isEmailSent = false.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs; // ➕ Sensor mata verifikasi password

  // 🕒 Variabel Reaktif untuk Hitung Mundur OTP
  Timer? _timer;
  var remainingSeconds = 300.obs; // 5 menit = 300 detik
  var timerString = "05:00".obs;

  // Variabel baseUrl lokal DIHAPUS karena kita menggunakan ApiConfig

  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  // ⏱️ Fungsi Memulai Hitung Mundur
  void startOtpTimer() {
    remainingSeconds.value = 300;
    _timer?.cancel(); // Reset timer jika ada timer lama yang berjalan
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
        int minutes = remainingSeconds.value ~/ 60;
        int seconds = remainingSeconds.value % 60;
        // Format angka agar selalu 2 digit (contoh: 04:09)
        timerString.value = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      } else {
        _timer?.cancel();
        timerString.value = "Kedaluwarsa";
      }
    });
  }

  // STEP 1: Minta OTP ke Flask
  Future<void> requestOtp() async {
    if (emailController.text.isEmpty) {
      Get.snackbar("Peringatan", "Masukkan alamat email Anda!", backgroundColor: Colors.orange.withOpacity(0.1));
      return;
    }

    isLoading.value = true;
    try {
      // Tembak API Menggunakan ApiConfig
      final response = await http.post(
        Uri.parse(ApiConfig.forgotPassword), // <--- Menggunakan ApiConfig
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        isEmailSent.value = true;
        startOtpTimer(); // 🚀 Mulai timer saat email sukses terkirim
        Get.snackbar("Sukses", data['message'] ?? "OTP terkirim!", backgroundColor: Colors.green.withOpacity(0.1));
      } else {
        Get.snackbar("Gagal", data['message'] ?? "Email tidak ditemukan.", backgroundColor: Colors.redAccent.withOpacity(0.1));
      }
    } catch (e) {
      Get.snackbar("Koneksi Gagal", "Tidak dapat terhubung ke server.");
    } finally {
      isLoading.value = false;
    }
  }

  // STEP 2: Verifikasi OTP & Reset Password
  Future<void> resetPassword() async {
    // 1. Validasi kolom kosong
    if (otpController.text.isEmpty || newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      Get.snackbar("Peringatan", "Semua kolom wajib diisi!", backgroundColor: Colors.orange.withOpacity(0.1));
      return;
    }

    // 2. Cek apakah masa berlaku OTP sudah habis
    if (remainingSeconds.value <= 0) {
      Get.snackbar("Gagal", "Kode OTP sudah kedaluwarsa! Silakan minta kode baru.", backgroundColor: Colors.redAccent.withOpacity(0.1));
      return;
    }

    // 3. Validasi kecocokan password baru dengan verifikasi password
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Password Tidak Cocok", 
        "Konfirmasi kata sandi harus sama dengan kata sandi baru Anda!", 
        backgroundColor: Colors.redAccent.withOpacity(0.1)
      );
      return;
    }

    isLoading.value = true;
    try {
      // Tembak API Menggunakan ApiConfig
      final response = await http.post(
        Uri.parse(ApiConfig.resetPassword), // <--- Menggunakan ApiConfig
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "otp": otpController.text.trim(),
          "new_password": newPasswordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _timer?.cancel(); // Matikan timer
        Get.snackbar("Berhasil", data['message'] ?? "Kata sandi diubah!", backgroundColor: Colors.green.withOpacity(0.1));
        
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed('/login');
        });
      } else {
        Get.snackbar("Gagal", data['message'] ?? "OTP salah.", backgroundColor: Colors.redAccent.withOpacity(0.1));
      }
    } catch (e) {
      Get.snackbar("Koneksi Gagal", "Terjadi kesalahan koneksi.");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel(); // Hentikan timer dari memori saat user keluar halaman
    super.onClose();
  }
}