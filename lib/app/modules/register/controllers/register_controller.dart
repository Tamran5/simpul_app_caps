import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; 
import 'package:url_launcher/url_launcher.dart';
import '../../../core/values/api_config.dart'; 

class RegisterController extends GetxController {
  // Controller untuk teks input
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController(); 
  final phoneController = TextEditingController();

  // Variabel reaktif untuk status & Dropdown
  var isLoading = false.obs; 
  var selectedAgama = ''.obs;
  var selectedJenisKelamin = ''.obs;
  var isPasswordHidden = true.obs;

  // Variabel baseUrl lokal DIHAPUS karena kita akan menggunakan ApiConfig

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
        selectedJenisKelamin.value.isEmpty || 
        selectedAgama.value.isEmpty) {
      Get.snackbar(
        "Peringatan", 
        "Semua data pendaftaran wajib diisi!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
      );
      return;
    }

    // Ubah status tombol jadi loading
    isLoading.value = true;

    try {
      // 2. Tembak RESTful API Flask MENGGUNAKAN API CONFIG (Sangat Rapi!)
      final response = await http.post(
        Uri.parse(ApiConfig.register), // <--- Cukup panggil ApiConfig.register di sini
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "gender": selectedJenisKelamin.value,
          "religion": selectedAgama.value,
          "phone": phoneController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      // 3. Cek respon status dari Flask
      if (response.statusCode == 201) {
        // Jika sukses masuk database MySQL, langsung bersihkan form input data
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        selectedJenisKelamin.value = '';
        selectedAgama.value = '';
        phoneController.clear();

        Get.snackbar(
          "Sukses", 
          data['message'] ?? "Registrasi berhasil!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
        );
        
        // Jeda 1.5 detik agar snackbar terbaca, lalu pindah ke Login + Munculkan Dialog Verifikasi
        Future.delayed(const Duration(milliseconds: 1500), () {
          // Pindah ke halaman login dan hapus tumpukan history pendaftaran
          Get.offAllNamed('/login'); 
          
          // Memunculkan Pop-up Dialog elegan bertema Simpul (Hijau #596E63) dengan Integrasi Gmail
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
                // Pilihan 1: Tutup dialog saja
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text(
                    "NANTI SAJA", 
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                  ),
                ),
                // Pilihan 2: Langsung mental ke Gmail browser/aplikasi
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF596E63),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    Get.back(); // Tutup dialog terlebih dahulu
                    
                    final Uri gmailUrl = Uri.parse('https://mail.google.com');
                    // Membuka Gmail secara eksternal (Tab Baru di Web / Aplikasi Gmail di HP)
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
            barrierDismissible: false, // User wajib klik tombol agar pop-up menutup
          );
        });
        
      } else {
        // Jika gagal karena aturan bisnis backend (contoh: email sudah dipakai)
        Get.snackbar(
          "Gagal", 
          data['message'] ?? "Terjadi kesalahan pada sistem.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
        );
      }
    } catch (e) {
      // Jika server Flask mati atau device beda jaringan WiFi
      Get.snackbar(
        "Koneksi Gagal", 
        "Tidak dapat terhubung ke server. Pastikan server aktif dan IP address benar.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // Matikan animasi loading tombol setelah semua proses selesai
      isLoading.value = false; 
    }
  }

  void goToLogin() {
    Get.toNamed('/login');
  }

  @override
  void onClose() {
    // Bersihkan memori controller saat halaman dihancurkan untuk mencegah memory leak
    // nameController.dispose();
    // emailController.dispose();
    // passwordController.dispose(); 
    // phoneController.clear();
    super.onClose();
  }
}