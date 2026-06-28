import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF596E63);
    const Color softGreenTint = Color(0xFFE8F0EE); // 10% dari primaryGreen
    const Color bgColor = Color(0xFFF5F6F8);
    const Color textDark = Color(0xFF1A1A1A);
    const Color textGrey = Color(0xFF666666);
    const Color borderGrey = Color(0xFFE0E0E0);
    const Color goldAccent = Color(0xFFC8A96A);

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
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                    
                    // --- ELEMEN BARU 1: IKON PSIKOLOGIS PENENANG ---
                    Center(
                      child: Container(
                        width: 64, height: 64,
                        decoration: const BoxDecoration(color: softGreenTint, shape: BoxShape.circle),
                        child: Icon(
                          !controller.isEmailSent.value ? Icons.lock_reset_rounded : Icons.mark_email_read_rounded,
                          size: 32, color: primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Indikator Tahapan
                    Text(
                      !controller.isEmailSent.value ? 'TAHAP 1 DARI 2' : 'TAHAP 2 DARI 2',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: goldAccent, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 6),

                    const Text(
                      'Reset Kata Sandi',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      !controller.isEmailSent.value
                          ? 'Masukkan email akun Simpul Anda. Kami akan mengirimkan kode OTP pengaman.'
                          : 'Kode verifikasi telah dikirim. Masukkan kode beserta sandi baru Anda.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: textGrey, height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    // --- STEP 1 & 2: INPUT EMAIL (DENGAN TOMBOL "UBAH" ANTI-JEBAKAN) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInputLabel('Email Terdaftar'),
                        // Jika sudah masuk Step 2, munculkan tombol "Ganti Email"
                        if (controller.isEmailSent.value)
                          GestureDetector(
                            onTap: () => controller.isEmailSent.value = false, // Mundur ke Step 1
                            child: const Text('Ganti Email', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: controller.emailController,
                      enabled: !controller.isEmailSent.value,
                      style: TextStyle(color: controller.isEmailSent.value ? textGrey : textDark, fontWeight: controller.isEmailSent.value ? FontWeight.bold : FontWeight.normal),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration('hello@example.com', Icons.mail_outline, borderGrey, primaryGreen, isDisabled: controller.isEmailSent.value),
                    ),
                    const SizedBox(height: 20),

                    // --- STEP 2: KODE OTP & SANDI BARU ---
                    if (controller.isEmailSent.value) ...[
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInputLabel('Kode OTP (6 Digit)'),
                          Text(
                            controller.timerString.value == "Kedaluwarsa" ? "Hangus" : controller.timerString.value,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold,
                              color: controller.timerString.value == "Kedaluwarsa" ? Colors.red : primaryGreen
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // ELEMEN BARU 2: OTP BERGAYA PIN EKSKLUSIF
                      TextFormField(
                        controller: controller.otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center, // Angka berada di tengah kotak
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 12.0, color: textDark), // Efek spasi PIN: 1  2  3  4  5  6
                        decoration: _buildInputDecoration('• • • • • •', Icons.pin_outlined, borderGrey, primaryGreen, isOtp: true),
                      ),
                      const SizedBox(height: 20),

                      _buildInputLabel('Kata Sandi Baru'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.newPasswordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          hintText: 'Minimal 6 karakter',
                          hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
                          prefixIcon: const Icon(Icons.lock_outline, color: textGrey, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textGrey, size: 20),
                            onPressed: () => controller.togglePasswordVisibility(),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderGrey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInputLabel('Verifikasi Sandi Baru'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.isConfirmPasswordHidden.value,
                        decoration: InputDecoration(
                          hintText: 'Ketik ulang sandi baru',
                          hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
                          prefixIcon: const Icon(Icons.gpp_good_outlined, color: textGrey, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isConfirmPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: textGrey, size: 20),
                            onPressed: () => controller.toggleConfirmPasswordVisibility(),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderGrey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // --- TOMBOL EKSEKUSI ---
                    SizedBox(
                      height: 52,
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
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                !controller.isEmailSent.value ? 'Kirim Kode OTP' : 'Simpan Kata Sandi',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),

                    // ELEMEN BARU 3: ESCAPE ROUTE (KIRIM ULANG OTP)
                    if (controller.isEmailSent.value) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: controller.timerString.value == "Kedaluwarsa" ? () => controller.requestOtp() : null,
                          child: Text(
                            controller.timerString.value == "Kedaluwarsa" ? "Tidak terima kode? Kirim Ulang OTP" : "Mohon tunggu sebelum kirim ulang...",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: controller.timerString.value == "Kedaluwarsa" ? primaryGreen : Colors.grey),
                          ),
                        ),
                      )
                    ]
                  ],
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildInputLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)));
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon, Color border, Color primary, {bool isDisabled = false, bool isOtp = false}) {
    return InputDecoration(
      hintText: hint,
      counterText: "", // Membunuh counter karakter
      hintStyle: TextStyle(color: isOtp ? const Color(0xFFCCCCCC) : const Color(0xFF999999), fontSize: 13, letterSpacing: isOtp ? 8.0 : 0),
      prefixIcon: isOtp ? null : Icon(icon, color: isDisabled ? const Color(0xFFBBBBBB) : const Color(0xFF666666), size: 20),
      fillColor: isDisabled ? const Color(0xFFF0F2F5) : Colors.white,
      filled: isDisabled,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDisabled ? Colors.transparent : border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
    );
  }
}