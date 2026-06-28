import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menggunakan GetView membuat variabel 'controller' otomatis tersedia tanpa Get.put()

    const Color primaryGreen = Color(0xFF596E63);
    const Color bgColor = Color(0xFFF5F6F8);
    const Color textDark = Color(0xFF1A1A1A);
    const Color textGrey = Color(0xFF666666);
    const Color borderGrey = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Judul Simpul (Disamakan dengan Register)
                    const Text(
                      'Simpul',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: primaryGreen,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subjudul
                    const Text(
                      'Ketenangan Terarah dalam Perencanaan Pernikahan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Input Email
                    _buildInputLabel('Email Address'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.emailController,
                      hintText: 'hello@example.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      borderColor: borderGrey,
                    ),
                    const SizedBox(height: 20),

                    // Area Label Password & Lupa Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInputLabel('Password'),
                        GestureDetector(
                          onTap: () => controller.forgotPassword(),
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              fontSize: 14,
                              color: textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Input Password (dengan Obx untuk tombol mata)
                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(
                            color: textGrey,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: textGrey,
                          ),
                          // Tombol Mata (Show/Hide)
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: textGrey,
                            ),
                            onPressed: () =>
                                controller.togglePasswordVisibility(),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: borderGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryGreen),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Obx(
                      () => SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          // Ketika loading, onPressed bernilai null (tombol otomatis beku/disabled)
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.login(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isLoading.value
                                ? primaryGreen.withValues(
                                    alpha: 0.6,
                                  ) // Penulisan modern anti-warning
                                : primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  // Kata kunci const dipindahkan ke sini
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Log In to Simpul',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ), 
                    const SizedBox(height: 32),

                    // Garis Pemisah (Divider)
                    Row(
                      children: [
                        const Expanded(child: Divider(color: borderGrey)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or continue with',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: borderGrey)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Tombol Google
                    _buildSocialButton(
                      text: 'Google',
                      iconWidget: _buildGoogleIcon(),
                      onPressed: () => controller.loginWithGoogle(),
                      borderColor: borderGrey,
                    ),
                    const SizedBox(height: 40),

                    // Teks Footer (Create account)
                    GestureDetector(
                      onTap: () => controller.goToRegister(),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: "Belum punya akun ? ",
                          style: TextStyle(color: textGrey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Daftar di sini',
                              style: TextStyle(
                                color: primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Label
  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF333333),
      ),
    );
  }

  // Widget TextField biasa
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color borderColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF666666)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF596E63)),
        ),
      ),
    );
  }

  // Widget Tombol Sosial Media
  Widget _buildSocialButton({
    required String text,
    required Widget iconWidget,
    required VoidCallback onPressed,
    required Color borderColor,
  }) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk logo Google
  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      color: Colors.transparent,
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
