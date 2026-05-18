import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';

class ProfileController extends GetxController {
  var userName = "Tamran".obs;
  var userEmail = "tamran@email.com".obs;
  var isPushNotification = true.obs;
  var isTaskReminder = true.obs;
  var isEmailUpdate = false.obs;
  var isVendorPromo = false.obs;

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

  void tampilkanPengaturanNotifikasi() {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'PREFERENSI NOTIFIKASI',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          
          // 1. Push Notification
          Obx(() => SwitchListTile(
            title: const Text('Push Notification', style: TextStyle(fontSize: 15)),
            activeColor: const Color(0xFF596E63),
            value: isPushNotification.value,
            onChanged: (val) => isPushNotification.value = val,
          )),
          
          // 2. Pengingat Tugas
          Obx(() => SwitchListTile(
            title: const Text('Pengingat Tugas', style: TextStyle(fontSize: 15)),
            activeColor: const Color(0xFF596E63),
            value: isTaskReminder.value,
            onChanged: (val) => isTaskReminder.value = val,
          )),
          
          // 3. Update Email
          // Obx(() => SwitchListTile(
          //   title: const Text('Update Email', style: TextStyle(fontSize: 15)),
          //   activeColor: const Color(0xFF596E63),
          //   value: isEmailUpdate.value,
          //   onChanged: (val) => isEmailUpdate.value = val,
          // )),
          
          // // 4. Promo Vendor
          // Obx(() => SwitchListTile(
          //   title: const Text('Promo Vendor', style: TextStyle(fontSize: 15)),
          //   activeColor: const Color(0xFF596E63),
          //   value: isVendorPromo.value,
          //   onChanged: (val) => isVendorPromo.value = val,
          // )),
          // const SizedBox(height: 16),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

  void editProfile() => Get.toNamed('/edit-profile');
  void logout() => Get.offAllNamed('/login');
}