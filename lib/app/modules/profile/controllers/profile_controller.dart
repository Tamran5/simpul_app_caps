import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  var userName = "Tamran".obs;
  var userEmail = "tamran@email.com".obs;

  // 1. TAMBAHKAN STATE SINKRONISASI SESUAI REQ-043 (Mulai dari false/belum sinkron)
  var isSynced = false.obs; 
  var partnerName = "".obs;
  var weddingDate = "".obs;

  // 2. Fungsi untuk mensimulasikan proses hubungkan pasangan sukses
  void hubungkanPasangan() {
    isSynced.value = true;
    partnerName.value = "Risa";
    weddingDate.value = "18 Juni 2027";

    // Hubungkan otomatis ke hitung mundur Beranda jika HomeController aktif
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().updateJadwalNikah(DateTime(2027, 6, 18));
    }

    Get.snackbar(
      'Sinkronisasi Sukses',
      'Akun Kamu berhasil terhubung dengan Risa!',
      backgroundColor: const Color(0xFF596E63),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void aturJadwalNikah(BuildContext context) async {
    // Jalankan date picker hanya jika sudah tersinkronisasi
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
  void logout() => Get.offAllNamed('/login');
}