import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color bgLight = Color(0xFFFBFBFB);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
        title: const Text(
          'Simpul',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      // 🔄 Membungkus body utama dengan Obx untuk memantau status loading server
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: primaryGreen,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchUserProfile(), // Tarik layar ke bawah untuk refresh data
          color: primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 1. Header Profil (Avatar & Nama)
                  _buildProfileHeader(),
                  const SizedBox(height: 32),

                  // 2. Kartu Wedding Info
                  _buildWeddingInfoCard(context),
                  const SizedBox(height: 32),

                  // 3. Grup Pengaturan Akun
                  _buildSectionLabel('PENGATURAN AKUN'),
                  _buildSettingsList([
                    _SettingItem(
                      Icons.person_outline,
                      'Edit Profil',
                      () => controller.editProfile(),
                    ),
                    _SettingItem(
                      Icons.face_retouching_natural,
                      'Face ID Registration',
                      () {
                        Get.toNamed('/face-scan', arguments: {'from': 'profile'}); 
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // 4. Grup Lainnya
                  _buildSectionLabel('LAINNYA'),
                  _buildSettingsList([
                    _SettingItem(Icons.help_outline, 'Pusat Bantuan', () => Get.toNamed('/faq')),
                    _SettingItem(Icons.info_outline, 'Tentang Simpul', () {}),
                  ]),
                  const SizedBox(height: 32),

                  // 5. Tombol Keluar
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryGreen, width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/seed/user/200'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          controller.userName.value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.userEmail.value,
          style: const TextStyle(fontSize: 14, color: textGrey),
        ),
      ],
    );
  }

  Widget _buildWeddingInfoCard(BuildContext context) {
    // KONDISI 1: JIKA BELUM SINKRON -> Tampilkan Tombol Ajakan
    if (!controller.isSynced.value) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9F8), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E7E5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.favorite_border, color: primaryGreen, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Belum Terhubung dengan Pasangan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hubungkan akunmu untuk mengelola tugas dan jadwal bersama.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: textGrey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.hubungkanPasangan(), 
                icon: const Icon(Icons.link, color: Colors.white, size: 18),
                label: const Text(
                  'Hubungkan Pasangan', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // KONDISI 2: JIKA SUDAH SUKSES SINKRON -> Tampilkan Nama & Tanggal
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PASANGAN', style: TextStyle(fontSize: 10, color: textGrey, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(controller.partnerName.value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: borderGrey),
          Expanded(
            child: InkWell(
              onTap: () => controller.aturJadwalNikah(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TANGGAL', style: TextStyle(fontSize: 10, color: textGrey, letterSpacing: 1.2)),
                        Icon(Icons.edit_calendar_outlined, size: 12, color: primaryGreen),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(controller.weddingDate.value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textGrey,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsList(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 56, color: borderGrey),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(item.icon, color: primaryGreen, size: 22),
            title: Text(
              item.title,
              style: const TextStyle(fontSize: 15, color: textDark),
            ),
            trailing: const Icon(Icons.chevron_right, color: borderGrey),
            onTap: item.onTap,
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => controller.logout(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFF5E8E6)),
          ),
          backgroundColor: const Color(0xFFFDF8F7),
        ),
        child: const Text(
          'Keluar dari Akun',
          style: TextStyle(
            color: Color(0xFFC8847A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  _SettingItem(this.icon, this.title, this.onTap);
}