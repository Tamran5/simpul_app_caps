import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color bgLight = Color(0xFFFBFBFB);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Foto Profil
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://picsum.photos/seed/user/200'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Form Input Nama Lengkap
            _buildInputField('Nama Lengkap', controller.nameController, Icons.person_outline),
            const SizedBox(height: 20),
            
            // 3. Form Input Nomor Telepon
            _buildInputField('Nomor Telepon', controller.phoneController, Icons.phone_android_outlined, kbdType: TextInputType.phone),
            const SizedBox(height: 20),

            // 4. Area Komponen Email Dinamis (UX Tingkat Tinggi)
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Label Email Terdaftar + Tombol Aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Email Terdaftar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    GestureDetector(
                      onTap: () {
                        controller.isChangingEmail.value = !controller.isChangingEmail.value;
                        if (!controller.isChangingEmail.value) {
                          controller.newEmailController.clear();
                        }
                      },
                      child: Text(
                        controller.isChangingEmail.value ? 'Batal Ubah' : 'Ubah Email',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Field Email Lama (Selalu Terkunci/Disabled demi Keamanan)
                TextField(
                  controller: controller.emailController,
                  enabled: false, 
                  decoration: _buildInputDecoration(Icons.email_outlined, Colors.grey[100]!),
                  style: TextStyle(color: Colors.grey[600]),
                ),

                // Komponen Tambahan yang Muncul Hanya Jika Tombol "Ubah Email" Diklik
                if (controller.isChangingEmail.value) ...[
                  const SizedBox(height: 20),
                  const Text('Alamat Email Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.newEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(Icons.mark_email_unread_outlined, Colors.white),
                  ),
                  const SizedBox(height: 12),
                  
                  // Spanduk Alert Box Pemberitahuan OTP 
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.orange, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Demi keamanan, kode verifikasi OTP akan dikirimkan ke email terdaftar saat ini sebelum email baru disetujui.',
                            style: TextStyle(fontSize: 11, color: Colors.orange, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            )),
            
            const SizedBox(height: 48),

            // 5. Tombol Simpan Perubahan
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value 
                        ? null 
                        : () => controller.simpanPerubahan(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, IconData icon, {TextInputType kbdType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: kbdType,
          decoration: _buildInputDecoration(icon, Colors.white),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(IconData icon, Color fillColor) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: primaryGreen, size: 20), 
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen),
      ),
    );
  }
}