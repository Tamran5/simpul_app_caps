import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ConnectPartnerController extends GetxController {
  final partnerCodeController = TextEditingController();
  
  // Mock Kode Unik Pengguna Sendiri
  var myCode = "SMPL-7892".obs;

  void salinKode() {
    Clipboard.setData(ClipboardData(text: myCode.value));
    Get.snackbar(
      'Salin Kode',
      'Kode unik Kamu berhasil disalin ke papan klip.',
      backgroundColor: const Color(0xFF596E63),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void prosesHubungkan() {
    String inputCode = partnerCodeController.text.trim();
    
    if (inputCode.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Silakan masukkan kode unik pasangan Kamu terlebih dahulu.',
        backgroundColor: const Color(0xFFC8847A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Simulasi Berhasil Sinkronisasi Pasangan
    Get.offAllNamed('/home', arguments: {'status_sync': true});
    
    Get.snackbar(
      'Berhasil Sinkron',
      'Akun Kamu telah sukses terhubung dengan pasangan!',
      backgroundColor: const Color(0xFF596E63),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void lewatiSementara() {
    Get.offAllNamed('/home', arguments: {'status_sync': false});
  }

  @override
  void onClose() {
    partnerCodeController.dispose();
    super.onClose();
  }
}