import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahan untuk fitur copy-paste (Clipboard)
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/controllers/home_controller.dart';
import '../../../core/values/api_config.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;

  var userName = "Memuat nama...".obs;
  var userEmail = "Memuat email...".obs;

  // 🔗 STATE SINKRONISASI PASANGAN (Sistem Real-time)
  var myUniqueCode = "".obs; // Kode milik user sendiri
  var syncStatus = "none".obs; // Status: none, pending_sent, pending_received, synced
  var isSynced = false.obs; 
  var partnerName = "".obs;
  var weddingDate = "".obs;

  // Controller untuk input text kode unik
  final kodePasanganController = TextEditingController();

  // Variabel baseUrl lokal DIHAPUS karena menggunakan ApiConfig

  @override
  void onInit() {
    super.onInit();
    if (userName.value == "Memuat nama...") {
      fetchUserProfile();
    }
    // fetchUserProfile(); 
  }

  // 📥 AMBIL DATA PROFIL ASLI DARI SERVER FLASK
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      // TEMBAK API MENGGUNAKAN API CONFIG
      final response = await http.get(
        Uri.parse(ApiConfig.profile), // <--- Menggunakan ApiConfig
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token" 
        },
      );

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        final data = resBody['data'];
        
        userName.value = data['name'] ?? 'User';
        userEmail.value = data['email'] ?? '';
        
        // Update State Relasi
        myUniqueCode.value = data['my_code'] ?? '';
        syncStatus.value = data['sync_status'] ?? 'none';
        isSynced.value = (syncStatus.value == 'synced'); // True jika status sudah synced
        partnerName.value = data['partner_name'] ?? '';
        weddingDate.value = data['wedding_date'] ?? '';

        // Otomatis sinkronisasi sisa waktu hitung mundur di Beranda
        if (isSynced.value && weddingDate.value.isNotEmpty && Get.isRegistered<HomeController>()) {
           // update logika jadwal jika diperlukan
        }
        
        // 🔔 NOTIFIKASI OTOMATIS: Munculkan popup jika ada undangan masuk saat buka profil
        if (syncStatus.value == 'pending_received') {
           tampilkanDialogPersetujuan();
        }

      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print("Error memuat profil: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🔄 FUNGSI UTAMA TOMBOL "HUBUNGKAN PASANGAN" DI UI
  void hubungkanPasangan() {
    if (syncStatus.value == 'pending_sent') {
      Get.snackbar(
        'Menunggu Persetujuan', 
        'Kamu sudah mengirimkan undangan. Menunggu pasanganmu menerima.', 
        backgroundColor: Colors.orange.withOpacity(0.1)
      );
      return;
    }
    
    if (syncStatus.value == 'pending_received') {
      tampilkanDialogPersetujuan();
      return;
    }

    // Tampilkan BottomSheet untuk Input Kode Pasangan & Lihat Kode Sendiri
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sinkronisasi Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Tampilan Kode Unik Milik Sendiri (Bisa disalin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kode Unik Kamu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(myUniqueCode.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFF596E63)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: myUniqueCode.value));
                      Get.snackbar('Disalin', 'Kode unik berhasil disalin!', snackPosition: SnackPosition.TOP);
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Input Text Kode Pasangan
            TextField(
              controller: kodePasanganController,
              textCapitalization: TextCapitalization.characters, // Otomatis huruf kapital
              decoration: InputDecoration(
                labelText: 'Masukkan Kode Pasangan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.link, color: Color(0xFF596E63)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF596E63)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Tutup bottom sheet dulu
                  kirimPermintaanSinkronisasi(); // Jalankan proses ke server
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF596E63),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kirim Permintaan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // 📤 KIRIM KODE UNIK PASANGAN KE FLASK
  Future<void> kirimPermintaanSinkronisasi() async {
    if (kodePasanganController.text.trim().isEmpty) return;
    
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // TEMBAK API MENGGUNAKAN API CONFIG
      final response = await http.post(
        Uri.parse(ApiConfig.connectPartner), // <--- Menggunakan ApiConfig
        headers: {
          "Content-Type": "application/json", 
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"partner_code": kodePasanganController.text.trim()}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        kodePasanganController.clear();
        fetchUserProfile(); // Refresh data untuk mengupdate status di HP menjadi 'pending_sent'
        Get.snackbar('Berhasil', data['message'], backgroundColor: Colors.green.withOpacity(0.1));
      } else {
        Get.snackbar('Gagal', data['message'], backgroundColor: Colors.redAccent.withOpacity(0.1));
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal menghubungi server.");
    } finally {
      isLoading.value = false;
    }
  }

  // 📥 JENDELA PERSETUJUAN (MUNCUL JIKA ADA REQUEST MASUK DARI PASANGAN)
  void tampilkanDialogPersetujuan() {
    Get.defaultDialog(
      title: "Permintaan Masuk!",
      middleText: "Seseorang mengundangmu untuk mensinkronkan akun pernikahan. Apakah kamu menerima?",
      textConfirm: "Terima",
      textCancel: "Tolak",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.redAccent,
      buttonColor: const Color(0xFF596E63),
      onConfirm: () {
        Get.back(); // Tutup pop-up
        responPermintaan('accept'); // Terima
      },
      onCancel: () {
        responPermintaan('reject'); // Tolak
      }
    );
  }

  // 📤 FUNGSI MERESPONS REQUEST (TERIMA/TOLAK) KE SERVER FLASK
  Future<void> responPermintaan(String action) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // TEMBAK API MENGGUNAKAN API CONFIG
      final response = await http.post(
        Uri.parse(ApiConfig.respondPartner), // <--- Menggunakan ApiConfig
        headers: {
          "Content-Type": "application/json", 
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"action": action}),
      );

      if (response.statusCode == 200) {
        fetchUserProfile(); // Refresh UI menjadi Sinkron Penuh atau Batal
        Get.snackbar(
          'Sukses', 
          action == 'accept' ? 'Akun berhasil terhubung!' : 'Permintaan dibatalkan.', 
          backgroundColor: Colors.green.withOpacity(0.1)
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan koneksi.");
    } finally {
      isLoading.value = false;
    }
  }

  // 📅 FUNGSI ATUR TANGGAL PERNIKAHAN VIA CALENDAR PICKER
  void aturJadwalNikah(BuildContext context) async {
    if (!isSynced.value) return;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2027, 6, 18),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF596E63),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      List<String> daftarBulan = [
        "Januari", "Februari", "Maret", "April", "Mei", "Juni",
        "Juli", "Agustus", "September", "Oktober", "November", "Desember"
      ];
      
      weddingDate.value = "${pickedDate.day} ${daftarBulan[pickedDate.month - 1]} ${pickedDate.year}";
      
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().updateJadwalNikah(pickedDate);
      }
    }
  }

  void editProfile() => Get.toNamed('/edit-profile');

  // KELUAR AKUN SECARA BERSIH DAN AMAN
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    Get.offAllNamed('/login'); 
  }

  @override
  void onClose() {
    kodePasanganController.dispose(); 
    super.onClose();
  }
}