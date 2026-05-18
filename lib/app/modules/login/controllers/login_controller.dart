import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Variabel reaktif untuk mengatur visibilitas password
  var isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() {
    print("Email: ${emailController.text}");
    print("Password: ${passwordController.text}");
    // Tambahkan logika validasi & API Login Anda di sini
    
    // Pindah ke Home jika sukses
    Get.offAllNamed('/home');
  }

  void goToRegister() {
    // Kembali ke halaman sebelumnya (Register)
    Get.back();
  }

  void forgotPassword() {
    Get.toNamed('/forgot-password');
  }

  void loginWithGoogle() {
    print("Login menggunakan Google");
  }

  void loginWithApple() {
    print("Login menggunakan Apple");
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}