import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  // Controller untuk teks input
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Variabel reaktif untuk Dropdown Agama & Jenis Kelamin
  var selectedAgama = ''.obs;
  var selectedJenisKelamin = ''.obs; // <- TAMBAHAN BARU

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
  final List<String> jenisKelaminList = [ // <- TAMBAHAN BARU
    'Laki-laki',
    'Perempuan',
  ];

  void register() {
    // Logika ketika tombol daftar ditekan
    print("Nama: ${nameController.text}");
    print("Email: ${emailController.text}");
    print("Jenis Kelamin: ${selectedJenisKelamin.value}"); // <- TAMBAHAN BARU
    print("Agama: ${selectedAgama.value}");

    Get.toNamed('/face-scan', arguments: {'from': 'register'});
  }

  void goToLogin() {
    Get.toNamed('/login');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}