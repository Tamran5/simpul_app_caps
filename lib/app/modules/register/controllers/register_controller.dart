import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart'; // Wajib untuk sistem Smart-Detect
import 'package:url_launcher/url_launcher.dart';
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

    // Ubah status tombol jadi loading
    isLoading.value = true;

    try {
      // 2. Tembak RESTful API Flask MENGGUNAKAN API CONFIG
      final response = await http.post(
        Uri.parse(ApiConfig.register), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
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
        
        // --- SIMPAN HASIL KALKULASI KE LACI HP (SharedPreferences) ---
        // Ini krusial agar saat user masuk ke To-Do List, urutan dokumennya langsung akurat!
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_religion', selectedAgama.value);
        await prefs.setString('user_gender', selectedJenisKelamin.value);
        await prefs.setBool('is_out_of_town', isNumpangNikahResult);
        await prefs.setBool('is_foreigner', isPartnerForeigner.value);

        // Bersihkan form input data
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        phoneController.clear();
        ktpCityController.clear();
        weddingCityController.clear();
        isPartnerForeigner.value = false;

        Get.snackbar(
          "Sukses", 
          data['message'] ?? "Registrasi berhasil!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );
        
        // Jeda 1.5 detik agar snackbar terbaca, lalu pindah ke Login + Munculkan Dialog Verifikasi
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.offAllNamed('/login'); 
          
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: const [
                  Icon(Icons.mark_email_unread_outlined, color: Color(0xFF596E63)),
                  SizedBox(width: 10),
                  Text(
                    "Verifikasi Email", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                ],
              ),
              content: const Text(
                "Akun berhasil dibuat! Silakan buka kotak masuk email Anda untuk memverifikasi akun sebelum masuk ke aplikasi Simpul.",
                style: TextStyle(height: 1.5, color: Color(0xFF666666), fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    "NANTI SAJA", 
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF596E63),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    Get.back(); 
                    
                    final Uri gmailUrl = Uri.parse('https://mail.google.com');
                    if (!await launchUrl(gmailUrl, mode: LaunchMode.externalApplication)) {
                      Get.snackbar(
                        "Gagal", 
                        "Tidak dapat membuka Gmail otomatis.",
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: const Text(
                    "BUKA GMAIL", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
            barrierDismissible: false, 
          );
        });
        
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