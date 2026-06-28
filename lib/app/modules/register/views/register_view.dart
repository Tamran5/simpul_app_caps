import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF596E63);
    const Color bgColor = Color(0xFFF5F6F8);
    const Color textDark = Color(0xFF1A1A1A);
    const Color textGrey = Color(0xFF666666);
    const Color borderGrey = Color(0xFFE0E0E0);
    const Color goldAccent = Color(0xFFC8A96A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
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
                    // Teks Logo
                    const Text(
                      'Simpul',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic, color: primaryGreen, letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Daftar Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Langkah awal menyusun legalitas\npernikahan yang tenang.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: textGrey, height: 1.5),
                    ),
                    const SizedBox(height: 32),

                    // --- SEGMEN 1: INFORMASI AKUN ---
                    _buildSectionHeader('1. Informasi Akun'),
                    const SizedBox(height: 16),

                    _buildInputLabel('Nama Lengkap'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.nameController,
                      hintText: 'Sesuai KTP',
                      icon: Icons.person_outline,
                      borderColor: borderGrey, primaryColor: primaryGreen,
                    ),
                    const SizedBox(height: 18),

                    _buildInputLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.emailController,
                      hintText: 'contoh@email.com',
                      icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress,
                      borderColor: borderGrey, primaryColor: primaryGreen,
                    ),
                    const SizedBox(height: 18),

                    _buildInputLabel('Kata Sandi'),
                    const SizedBox(height: 8),
                    Obx(() => _buildTextField(
                      controller: controller.passwordController,
                      hintText: 'Minimal 6 karakter',
                      icon: Icons.lock_outline,
                      isPassword: controller.isPasswordHidden.value,
                      borderColor: borderGrey, primaryColor: primaryGreen,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: textGrey, size: 20,
                        ),
                        onPressed: () => controller.togglePasswordVisibility(),
                      ),
                    )),
                    const SizedBox(height: 18),

                    _buildInputLabel('Nomor WhatsApp'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: controller.phoneController,
                      hintText: '081234567890',
                      icon: Icons.phone_android_outlined, keyboardType: TextInputType.phone,
                      borderColor: borderGrey, primaryColor: primaryGreen,
                    ),

                    const SizedBox(height: 32),

                    // --- SEGMEN 2: PROFIL HUKUM (Penting untuk Smart-Detect) ---
                    _buildSectionHeader('2. Profil Legalitas Nikah'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: goldAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: goldAccent, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Data ini digunakan sistem untuk menyusun urutan dokumen hukum yang tepat untuk Anda.',
                              style: TextStyle(fontSize: 11, color: textDark, height: 1.3),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Gender
                    _buildInputLabel('Peran Mempelai'),
                    const SizedBox(height: 8),
                    Obx(() => _buildDropdown(
                      value: controller.selectedJenisKelamin.value,
                      items: controller.jenisKelaminList,
                      icon: Icons.wc,
                      hint: 'Pilih Peran',
                      onChanged: (val) => controller.selectedJenisKelamin.value = val!,
                      borderColor: borderGrey, primaryColor: primaryGreen,
                    )),
                    const SizedBox(height: 18),

                    // Dropdown Agama (Lengkap 6 Agama Resmi RI)
                    _buildInputLabel('Agama Pernikahan'),
                    const SizedBox(height: 8),
                    Obx(() => _buildDropdown(
                      value: controller.selectedAgama.value,
                      items: controller.agamaList,
                      icon: Icons.account_balance_outlined,
                      hint: 'Pilih Agama',
                      onChanged: (val) => controller.selectedAgama.value = val!,
                      borderColor: borderGrey, primaryColor: primaryGreen,
                    )),
                    const SizedBox(height: 18),

                    // Input Kota KTP vs Kota Nikah (Sistem Numpang Nikah)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Kota KTP Anda'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: controller.ktpCityController,
                                hintText: 'Cth: Bandung',
                                icon: Icons.location_city,
                                borderColor: borderGrey, primaryColor: primaryGreen,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Kota Akad/Nikah'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: controller.weddingCityController,
                                hintText: 'Cth: Surabaya',
                                icon: Icons.favorite_border,
                                borderColor: borderGrey, primaryColor: primaryGreen,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Checkbox WNA
                    Obx(() => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: primaryGreen,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Pasangan saya Warga Negara Asing (WNA)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textDark)),
                      value: controller.isPartnerForeigner.value,
                      onChanged: (val) => controller.isPartnerForeigner.value = val ?? false,
                    )),

                    const SizedBox(height: 36),

                    // Tombol Submit
                    Obx(() => SizedBox(
                      height: 54,
                      child: controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                        : ElevatedButton(
                            onPressed: () => controller.register(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Buat Akun & Susun Rencana', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                    )),

                    const SizedBox(height: 32),

                    // Footer Login Link
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
                              style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
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

  // --- WIDGET HELPER ---

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF596E63))),
        const Divider(color: Color(0xFFE0E0E0), thickness: 1),
      ],
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)));
  }

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
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF666666), size: 20),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
      ),
    );
  }

  // Komponen Dropdown Anti-Bug
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required String hint,
    required Function(String?) onChanged,
    required Color borderColor,
    required Color primaryColor,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first, // Proteksi agar tidak pernah null
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF666666), size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
      ),
    );
  }
}