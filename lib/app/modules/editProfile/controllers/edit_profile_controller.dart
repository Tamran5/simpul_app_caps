import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/values/api_config.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController(); 
  final newEmailController = TextEditingController(); 
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  var isLoading = false.obs;
  var isChangingEmail = false.obs; 
  String initialEmail = "";

  // Variabel baseUrl lokal DIHAPUS karena kita menggunakan ApiConfig

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserData();
  }

  void loadCurrentUserData() {
    if (Get.isRegistered<ProfileController>()) {
      final profile = Get.find<ProfileController>();
      nameController.text = profile.userName.value;
      emailController.text = profile.userEmail.value;
      initialEmail = profile.userEmail.value.trim().toLowerCase();
    }
  }

  Future<void> simpanPerubahan({String? otpCode}) async {
    if (nameController.text.isEmpty) {
      Get.snackbar("Peringatan", "Nama tidak boleh kosong!");
      return;
    }

    String emailTarget = isChangingEmail.value 
        ? newEmailController.text.trim() 
        : emailController.text.trim();

    if (isChangingEmail.value && emailTarget.isEmpty) {
      Get.snackbar("Peringatan", "Email baru wajib diisi jika ingin mengganti email!");
      return;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // TEMBAK API MENGGUNAKAN API CONFIG
      final response = await http.post(
        Uri.parse(ApiConfig.updateProfile), // <--- Menggunakan ApiConfig
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailTarget, 
          "phone": phoneController.text.trim(),
          "otp": otpCode
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'require_otp') {
          isLoading.value = false;
          bukaDialogVerifikasiOTP(); 
          Get.snackbar("Verifikasi Diperlukan", data['message'], backgroundColor: Colors.orange.withOpacity(0.1));
        } else {
          Get.back(); 
          Get.back(); 
          
          if (Get.isRegistered<ProfileController>()) {
            Get.find<ProfileController>().fetchUserProfile();
          }
          Get.snackbar("Sukses", "Profil berhasil diperbarui!", backgroundColor: Colors.green.withOpacity(0.1));
        }
      } else {
        Get.snackbar("Gagal", data['message'] ?? "Terjadi kesalahan.");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal terhubung ke pelayan server.");
    } finally { 
      isLoading.value = false;
    }
  }

  void bukaDialogVerifikasiOTP() {
    otpController.clear();
    Get.defaultDialog(
      title: "Verifikasi Email Lama",
      middleText: "Masukkan 6 digit kode OTP yang dikirim ke email lama Anda (${emailController.text}) untuk mengonfirmasi perubahan ini.",
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: TextFormField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4),
          decoration: InputDecoration(
            hintText: "000000",
            hintStyle: TextStyle(color: Colors.grey[300], letterSpacing: 4),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      textConfirm: "Verifikasi & Simpan",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF596E63),
      onConfirm: () {
        if (otpController.text.length == 6) {
          simpanPerubahan(otpCode: otpController.text.trim());
        } else {
          Get.snackbar("Peringatan", "Kode OTP harus 6 digit angka!");
        }
      },
    );
  }
}