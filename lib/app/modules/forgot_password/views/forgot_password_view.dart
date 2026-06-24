import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF596E63);
    const Color bgColor = Color(0xFFF5F6F8);
    const Color textGrey = Color(0xFF666666);
    const Color borderGrey = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Reset Kata Sandi',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryGreen),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      !controller.isEmailSent.value
                          ? 'Masukkan email terdaftar Anda untuk menerima kode verifikasi OTP.'
                          : 'Silakan masukkan kode OTP beserta kata sandi baru Anda di bawah ini.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: textGrey, height: 1.4),
                    ),
                    const SizedBox(height: 32),

                    // --- STEP 1: INPUT EMAIL ADDRESS ---
                    _buildInputLabel('Email Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.emailController,
                      enabled: !controller.isEmailSent.value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration('hello@example.com', Icons.mail_outline, borderGrey, primaryGreen),
                    ),
                    const SizedBox(height: 20),

                    // --- STEP 2: INPUT KODE OTP & PASSWORD BARU (MUNCUL BERURUTAN DI BAWAHNYA) ---
                    if (controller.isEmailSent.value) ...[
                      // Baris Label OTP & Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInputLabel('Kode OTP (6 Digit)'),
                          // Info Masa Berlaku OTP secara Real-time
                          Text(
                            controller.timerString.value == "Kedaluwarsa" 
                                ? "OTP Kedaluwarsa" 
                                : "Berlaku: ${controller.timerString.value}",
                            style: TextStyle(
                              fontSize: 13, 
                              fontWeight: FontWeight.bold,
                              color: controller.timerString.value == "Kedaluwarsa" ? Colors.red : primaryGreen
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: _buildInputDecoration('Masukkan 6 digit kode', Icons.pin_outlined, borderGrey, primaryGreen),
                      ),
                      const SizedBox(height: 20),

                      // Input Kata Sandi Baru
                      _buildInputLabel('Kata Sandi Baru'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.newPasswordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          hintText: 'Minimal 6 karakter',
                          hintStyle: const TextStyle(color: textGrey, fontSize: 15),
                          prefixIcon: const Icon(Icons.lock_outline, color: textGrey),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textGrey),
                            onPressed: () => controller.togglePasswordVisibility(),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderGrey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Verifikasi Kata Sandi Baru
                      _buildInputLabel('Verifikasi Kata Sandi Baru'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.isConfirmPasswordHidden.value,
                        decoration: InputDecoration(
                          hintText: 'Ulangi kata sandi baru',
                          hintStyle: const TextStyle(color: textGrey, fontSize: 15),
                          prefixIcon: const Icon(Icons.gpp_good_outlined, color: textGrey),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isConfirmPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textGrey),
                            onPressed: () => controller.toggleConfirmPasswordVisibility(),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderGrey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen)),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // --- TOMBOL SUBMIT ---
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (!controller.isEmailSent.value) {
                                  controller.requestOtp();
                                } else {
                                  controller.resetPassword();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                !controller.isEmailSent.value ? 'Kirim Kode OTP' : 'Perbarui Kata Sandi',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)));
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, Color border, Color primary) {
    return InputDecoration(
      hintText: hint,
      counterText: "", // Menyembunyikan teks counter panjang karakter bawaan maxLength
      hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
      prefixIcon: Icon(icon, color: const Color(0xFF666666)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary)),
    );
  }
}