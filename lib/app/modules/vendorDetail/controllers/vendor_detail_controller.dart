import 'package:get/get.dart';
import '../../vendor/controllers/vendor_controller.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class VendorDetailController extends GetxController {
  // PERBAIKAN UTAMA: Gunakan tipe data VendorModel yang sudah kita buat, jangan dynamic
  late VendorModel vendor; 

  // State khusus halaman detail (misal: 0 = Deskripsi, 1 = Paket Harga, 2 = Ulasan)
  // Catatan: Variabel ini aman dibiarkan jika ke depannya kamu ingin memakai sistem Tab
  var activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Menangkap data vendor yang dikirim saat kartu diklik di halaman utama
    if (Get.arguments != null) {
      // Karena yang dikirim dari VendorView adalah objek VendorModel, ini akan sangat aman
      vendor = Get.arguments as VendorModel; 
    }
  }

  void ubahTab(int index) {
    activeTab.value = index;
  }

  // --- 1. FUNGSI MEMBUKA WHATSAPP ---
  void hubungiWhatsApp() async {
    // Ambil nomor dari database
    String phoneNumber = vendor.whatsapp;
    
    // Validasi jika admin lupa mengisi nomor WA
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        "Gagal", 
        "Nomor WhatsApp vendor ini belum tersedia.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // Format nomor: Ubah awalan '0' menjadi '62' sesuai standar WhatsApp API
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '62${phoneNumber.substring(1)}';
    } else if (phoneNumber.startsWith('+')) {
      phoneNumber = phoneNumber.replaceAll('+', '');
    }

    String message = "Halo ${vendor.name}, saya tertarik dengan layanan Anda dan menemukan profil Anda di Aplikasi Simpul. Bisa minta info lebih lanjut?";
    
    String url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    final Uri waUri = Uri.parse(url);

    if (await canLaunchUrl(waUri)) {
      await launchUrl(waUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Gagal", "Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstal.");
    }
  }

  void lihatSemuaPortofolio() {
    if (vendor.portfolioUrls.isEmpty) return;

    // Membuka halaman baru secara instan berisi GridView gambar
    Get.to(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Galeri ${vendor.name}', style: const TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 kolom menyamping
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: vendor.portfolioUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              vendor.portfolioUrls[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    ));
  }
}