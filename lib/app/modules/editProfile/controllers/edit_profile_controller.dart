import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  // 1. Definisikan controller untuk masing-masing field
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    // 2. Ambil data awal dari ProfileController agar form tidak kosong
    final profileCtrl = Get.find<ProfileController>();
    
    nameController = TextEditingController(text: profileCtrl.userName.value);
    emailController = TextEditingController(text: profileCtrl.userEmail.value);
    phoneController = TextEditingController(text: "081234567890"); // Dummy data awal
  }

  void simpanPerubahan() {
    // 3. LOGIKA SINKRONISASI: Perbarui data di ProfileController
    final profileCtrl = Get.find<ProfileController>();
    
    profileCtrl.userName.value = nameController.text;
    profileCtrl.userEmail.value = emailController.text;

    Get.back(); // Kembali ke halaman profil
    
    Get.snackbar(
      'Berhasil',
      'Profil Kamu telah diperbarui',
      backgroundColor: const Color(0xFF596E63),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}