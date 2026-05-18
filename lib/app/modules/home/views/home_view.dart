import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../todo/views/todo_view.dart';
import '../../vendor/views/vendor_view.dart';


class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  // Tema Warna Berdasarkan Desain
  static const Color primaryDark = Color(0xFF3D6B5F);
  static const Color primaryMid = Color(0xFFA8C4BD);
  static const Color primaryLight = Color(0xFFE8F0EE);
  static const Color gold = Color(0xFFC8A96A);
  static const Color goldLight = Color(0xFFF5F0E8);
  static const Color bgColor = Color(0xFFF7F7F5);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E5);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: bgColor,
      // Menggunakan SafeArea agar tidak tertutup notch/kamera depan
      body: SafeArea(
        child: Obx(() {
          // Menampilkan konten berbeda berdasarkan tab yang dipilih
          return IndexedStack(
            index: controller.tabIndex.value,
            children: [
              _buildHomeContent(),     // Index 0: Beranda
              const TodoView(),         
              const VendorView(),
    // Index 4: Profil
            ],
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNav(controller),
    );
  }

  // Konten Utama Beranda
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildPairSyncCard(),
            const SizedBox(height: 16),
            _buildHeroCountdown(),
            const SizedBox(height: 24),
            _buildSectionTitle('MENU UTAMA'),
            _buildMenuGrid(),
            const SizedBox(height: 24),
            _buildSectionTitle('PROGRES LEGAL'),
            _buildLegalProgress(),
            const SizedBox(height: 40), // Spacing bawah yang cukup
          ],
        ),
      ),
    );
  }

  // --- BAGIAN-BAGIAN WIDGET ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'PERENCANA PERNIKAHAN',
              style: TextStyle(
                  fontSize: 10,
                  color: textGrey,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              'Simpul',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: primaryDark,
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: borderGrey),
          ),
          child: const Icon(Icons.notifications_none, color: primaryDark),
        ),
      ],
    );
  }

  Widget _buildPairSyncCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryMid.withOpacity(0.3),
            child: const Text('RZ', style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryMid),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 6, color: primaryDark),
                      SizedBox(width: 4),
                      Text('Tersinkron', style: TextStyle(fontSize: 10, color: primaryDark, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Setiap centang terlihat oleh keduanya', style: TextStyle(fontSize: 10, color: textGrey)),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: primaryLight,
            child: const Text('SR', style: TextStyle(color: primaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCountdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HITUNG MUNDUR HARI BAHAGIA', style: TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 1.2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('14 Jun 2025', style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Circular Progress
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.68,
                      strokeWidth: 6,
                      backgroundColor: Colors.white24,
                      color: primaryMid,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('68%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Selesai', style: TextStyle(fontSize: 9, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Countdown Tiles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reza & Sari', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeTile('045', 'Hari'),
                        _buildTimeTile('12', 'Jam'),
                        _buildTimeTile('38', 'Mnt'),
                        _buildTimeTile('22', 'Dtk'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(number, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70, letterSpacing: 1.0)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textGrey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMenuCard('Project Manager', 'Papan Kanban tugas umum', Icons.dashboard_customize, primaryLight, primaryDark)),
            const SizedBox(width: 12),
            Expanded(child: _buildMenuCard('Legal Checklist', 'Panduan dokumen N1-N4', Icons.gavel, goldLight, gold)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMenuCard('Edukasi', 'Tips & panduan pernikahan', Icons.menu_book, const Color(0xFFEDEDF8), const Color(0xFF6A6AAA))),
            const SizedBox(width: 12),
            Expanded(child: _buildMenuCard('Katalog Vendor', 'Direktori & info vendor', Icons.storefront, goldLight, gold)),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: textGrey)),
        ],
      ),
    );
  }

  Widget _buildLegalProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.description_outlined, color: primaryDark),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tahap Dokumen Saat Ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: goldLight, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Level Kelurahan — Dokumen N1', style: TextStyle(fontSize: 10, color: Color(0xFF8A6420), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.25,
                        backgroundColor: const Color(0xFFF2F2F0),
                        color: gold,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('25%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: gold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigasi Bawah (Bottom Navigation Bar) - 5 Menu
  Widget _buildBottomNav(HomeController controller) {
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed, // Penting agar teks tidak hilang jika lebih dari 3 menu
          backgroundColor: Colors.white,
          selectedItemColor: primaryDark,
          unselectedItemColor: textGrey,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), label: 'To Do'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Vendor'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Edukasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ));
  }
}