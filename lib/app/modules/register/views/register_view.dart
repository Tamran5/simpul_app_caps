import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Karena kita memakai GetView, kita tidak perlu Get.put() lagi jika Binding sudah bekerja
    // Jika lewat rute manual, pastikan RegisterController sudah dipanggil

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
                    // Logo Text
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
                    const SizedBox(height: 32),

                    // Judul
                    const Text(
                      'Daftar Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subjudul
                    const Text(
                      'Mulai perjalanan tenang menuju\nhari bahagiamu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: textGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Input Nama Lengkap
                    _buildInputLabel('Nama Lengkap'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.nameController,
                      hintText: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                      borderColor: borderGrey,
                      primaryColor: primaryGreen,
                    ),
                    const SizedBox(height: 20),

                    // Input Email
                    _buildInputLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.emailController,
                      hintText: 'contoh@email.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      borderColor: borderGrey,
                      primaryColor: primaryGreen,
                    ),
                    const SizedBox(height: 20),

                    _buildInputLabel('Kata Sandi'),
                    const SizedBox(height: 8),
                    Obx(
                      () => _buildTextField(
                        controller: controller.passwordController,
                        hintText: 'Minimal 6 karakter',
                        icon: Icons.lock_outline,
                        isPassword: controller
                            .isPasswordHidden
                            .value, // Nilainya reaktif mengikuti controller
                        borderColor: borderGrey,
                        primaryColor: primaryGreen,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textGrey,
                            size: 20,
                          ),
                          onPressed: () =>
                              controller.togglePasswordVisibility(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildInputLabel('Nomor Telepon'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.phoneController,
                      hintText: 'Contoh: 081234567890',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType
                          .phone, 
                      borderColor: borderGrey,
                      primaryColor: primaryGreen,
                    ),
                    const SizedBox(height: 20),

                    // Dropdown Jenis Kelamin
                    _buildInputLabel('Jenis Kelamin'),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Pilih Jenis Kelamin',
                          hintStyle: const TextStyle(
                            color: textGrey,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(Icons.wc, color: textGrey),
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
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: textGrey,
                        ),
                        value: controller.selectedJenisKelamin.value.isEmpty
                            ? null
                            : controller.selectedJenisKelamin.value,
                        items: controller.jenisKelaminList.map((String jk) {
                          return DropdownMenuItem<String>(
                            value: jk,
                            child: Text(jk),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedJenisKelamin.value = newValue;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown Agama
                    _buildInputLabel('Pilih Agama'),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Pilih Agama',
                          hintStyle: const TextStyle(
                            color: textGrey,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.people_outline,
                            color: textGrey,
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
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: textGrey,
                        ),
                        value: controller.selectedAgama.value.isEmpty
                            ? null
                            : controller.selectedAgama.value,
                        items: controller.agamaList.map((String agama) {
                          return DropdownMenuItem<String>(
                            value: agama,
                            child: Text(agama),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedAgama.value = newValue;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Tombol Daftar (DIBUNGKUS OBX UNTUK ANIMASI LOADING)
                    Obx(
                      () => SizedBox(
                        height: 56,
                        child: controller.isLoading.value
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: primaryGreen,
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () => controller.register(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Daftar',
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
                    const SizedBox(height: 40),

                    // Teks Footer (Login)
                    GestureDetector(
                      onTap: () => controller.goToLogin(),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'Sudah memiliki akun? ',
                          style: TextStyle(color: textGrey, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Masuk di sini',
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

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
        letterSpacing: 0.5,
      ),
    );
  }

  // Modifikasi _buildTextField untuk mendukung isPassword
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color borderColor,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF666666)),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }
}
