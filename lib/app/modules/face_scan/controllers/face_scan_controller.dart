import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FaceScanController extends GetxController {
  // 0: Belum mulai, 1: Scan Depan, 2: Scan Samping, 3: Selesai
  var scanStep = 0.obs;
  var instructionText = "Arahkan wajah Anda ke dalam bingkai".obs;
  var scanProgress = 0.0.obs;

  void startScanning() async {
    // Tahap 1: Pindai Wajah Depan
    scanStep.value = 1;
    instructionText.value = "Hadap lurus ke depan...";
    for (int i = 0; i <= 50; i += 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      scanProgress.value = i / 100;
    }

    // Tahap 2: Pindai Wajah Samping
    scanStep.value = 2;
    instructionText.value = "Perlahan palingkan wajah ke samping...";
    for (int i = 50; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      scanProgress.value = i / 100;
    }

    // Tahap 3: Selesai
    scanStep.value = 3;
    instructionText.value = "Pemindaian Selesai!";

    await Future.delayed(const Duration(seconds: 1));

    // --- LOGIKA PERPINDAHAN HALAMAN ---
    var args = Get.arguments;

    if (args != null && args['from'] == 'register') {
      // Jika datang dari halaman Pendaftaran -> Masuk ke Beranda
      Get.offAllNamed('/home');
      Get.snackbar(
        'Selamat Datang!',
        'Registrasi berhasil. Data wajah Anda telah diamankan.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF596E63),
        colorText: const Color(0xFFFFFFFF),
      );
    } else {
      // Jika datang dari halaman Profil -> Kembali ke Profil
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Data wajah Anda telah berhasil diperbarui.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF596E63),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  void resetScan() {
    scanStep.value = 0;
    scanProgress.value = 0.0;
    instructionText.value = "Arahkan wajah Anda ke dalam bingkai";
  }
}