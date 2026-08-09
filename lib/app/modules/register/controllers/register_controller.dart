import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/values/api_config.dart';

class RegisterController extends GetxController {
  // Controller untuk teks input dasar
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  // --- PENYESUAIAN BARU: Controller & State untuk Kalkulator Syarat Nikah ---
  final ktpCityController = TextEditingController();
  final weddingCityController = TextEditingController();
  var isPartnerForeigner = false.obs;

  // Variabel reaktif untuk status & Dropdown
  var isLoading = false.obs;
  var selectedAgama = 'Islam'.obs;              // Beri nilai default agar dropdown UI tidak crash
  var selectedJenisKelamin = 'Laki-laki'.obs;   // Beri nilai default
  var isPasswordHidden = true.obs;

  // Daftar pilihan agama
  final List<String> agamaList = [
    'Islam',
    'Kristen Protestan',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  // Daftar pilihan jenis kelamin
  final List<String> jenisKelaminList = [
    'Laki-laki',
    'Perempuan',
  ];

  // Fungsi untuk menyalakan/mematikan sensor mata password
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> register() async {
    // 1. Validasi agar tidak ada kolom formulir yang kosong
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty ||
        ktpCityController.text.isEmpty ||
        weddingCityController.text.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Semua data pendaftaran wajib diisi!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
      return;
    }

    // --- LOGIKA KALKULASI OTOMATIS: NUMPANG NIKAH ---
    String kotaKtp = ktpCityController.text.trim().toLowerCase();
    String kotaNikah = weddingCityController.text.trim().toLowerCase();
    bool isNumpangNikahResult = (kotaKtp != kotaNikah);

    final email = emailController.text.trim();

    // Ubah status tombol jadi loading
    isLoading.value = true;

    try {
      // 2. Tembak RESTful API Flask MENGGUNAKAN API CONFIG
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": email,
          "password": passwordController.text.trim(),
          "gender": selectedJenisKelamin.value,
          "religion": selectedAgama.value,
          "phone": phoneController.text.trim(),

          // Kirim juga parameter hukum ke Backend Flask kamu
          "ktp_city": ktpCityController.text.trim(),
          "wedding_city": weddingCityController.text.trim(),
          "is_out_of_town": isNumpangNikahResult,
          "is_foreigner": isPartnerForeigner.value,
        }),
      );

      final data = jsonDecode(response.body);

      // 3. Cek respon status dari Flask
      if (response.statusCode == 201) {
        Get.snackbar(
          "Sukses",
          data['message'] ?? "Registrasi berhasil!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );

        // Bersihkan form input data
        nameController.clear();
        passwordController.clear();
        phoneController.clear();
        ktpCityController.clear();
        weddingCityController.clear();
        isPartnerForeigner.value = false;

        // ── Arahkan ke halaman OTP Verification (bukan lagi dialog Gmail) ──
        // Halaman OTP akan otomatis login (dapat token) setelah kode benar,
        // lalu meneruskan ke pendaftaran Face Recognition (bisa di-skip).
        Get.offNamed('/register-otp', arguments: {
          'email': data['email'] ?? email,
          'remainingSeconds': data['remaining_seconds'] ?? 300,
        });

        emailController.clear();
      } else {
        Get.snackbar(
          "Gagal",
          data['message'] ?? "Terjadi kesalahan pada sistem.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Koneksi Gagal",
        "Tidak dapat terhubung ke server. Pastikan server aktif dan IP address benar.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.toNamed('/login');
  }

  @override
  void onClose() {
    super.onClose();
  }
}