import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../todo/views/todo_view.dart';
import '../../vendor/views/vendor_view.dart';
import '../../edukasi/views/edukasi_view.dart';
import '../../profile/views/profile_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  // Tema Warna Berdasarkan Desain Baru
  static const Color primaryDark = Color(0xFF3D6B5F);
  static const Color primaryMid = Color(0xFFA8C4BD);
  static const Color primaryLight = Color(0xFFE8F0EE);
  static const Color gold = Color(0xFFC8A96A);
  static const Color goldLight = Color(0xFFF5F0E8);
  static const Color bgColor = Color(0xFFF9F9F9); // Latar lebih bersih
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFF0F0F0);
  
  // Warna Aksen Baru
  static const Color purpleLight = Color(0xFFF0F0F8);
  static const Color purpleDark = Color(0xFF6A6AAA);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          return IndexedStack(
            index: controller.tabIndex.value,
            children: [
              _buildHomeContent(),     // Index 0: Beranda
              const TodoView(),         
              const VendorView(),
              EdukasiView(),
              const ProfileView(),
            ],
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNav(controller),
    );
  }

  // --- KONTEN UTAMA BERANDA ---
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildPairSyncCard(),
            const SizedBox(height: 16),
            _buildHeroCountdown(),
            const SizedBox(height: 24),
            _buildSectionTitle('MENU UTAMA'),
            _buildMenuGrid(),
            const SizedBox(height: 24),
            _buildSectionTitle('PROGRES LEGAL'),
            _buildLegalProgress(),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  // --- 1. HEADER (Dengan Titik Notifikasi) ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'PERENCANA PERNIKAHAN',
              style: TextStyle(fontSize: 10, color: textGrey, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            Text(
              'Simpul',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: primaryDark),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderGrey, width: 1.5),
              ),
              child: const Icon(Icons.notifications_none, color: primaryDark),
            ),
            // Titik notifikasi hijau
            Container(
              margin: const EdgeInsets.only(top: 12, right: 12),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: primaryDark, shape: BoxShape.circle),
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. KARTU SINKRONISASI PASANGAN ---
  Widget _buildPairSyncCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primaryLight,
            child: const Text('RZ', style: TextStyle(color: primaryDark, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Column(
              children: [
                // Garis dengan Pill "Tersinkron" di tengah
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(height: 1, color: borderGrey, width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Reza & Sari', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(height: 2),
                const Text('Setiap centang terlihat oleh keduanya', style: TextStyle(fontSize: 10, color: textGrey)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: purpleLight,
            child: const Text('SR', style: TextStyle(color: purpleDark, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 3. KARTU HERO HITUNG MUNDUR & PROGRES ---
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
              const Text('HITUNG MUNDUR HARI BAHAGIA', style: TextStyle(fontSize: 9, color: Colors.white70, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Text('14 JUN 2025', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Lingkaran Progres 68%
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(value: 0.68, strokeWidth: 5, backgroundColor: Colors.white24, color: primaryMid),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('68%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('SELESAI', style: TextStyle(fontSize: 8, color: Colors.white70, letterSpacing: 1.0)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Angka Hitung Mundur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reza & Sari', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeTile('45', 'HARI'),
                        _buildTimeTile('12', 'JAM'),
                        _buildTimeTile('38', 'MNT'),
                        _buildTimeTile('22', 'DTK'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Garis pemisah samar
          Container(height: 1, color: Colors.white12),
          const SizedBox(height: 16),
          // Baris Progres Keseluruhan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Progres keseluruhan', style: TextStyle(fontSize: 10, color: Colors.white70)),
              Text('40 / 58 tugas', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          // Linear Progress Bar Multi-Warna
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(flex: 40, child: Container(height: 6, color: primaryMid)),   // Legal (40%)
                Expanded(flex: 28, child: Container(height: 6, color: gold)),         // Tugas (28%)
                Expanded(flex: 32, child: Container(height: 6, color: Colors.black26)), // Sisa (32%)
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Legenda Progres
          Row(
            children: [
              _buildProgressLegend(primaryMid, 'Legal (40%)'),
              const SizedBox(width: 12),
              _buildProgressLegend(gold, 'Tugas (28%)'),
              const SizedBox(width: 12),
              _buildProgressLegend(Colors.white38, 'Sisa (32%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70, letterSpacing: 1.0)),
      ],
    );
  }

  Widget _buildProgressLegend(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textGrey, letterSpacing: 1.2)),
    );
  }

  // --- 4. GRID MENU UTAMA (Pilar Kehidupan, Katalog) ---
  Widget _buildMenuGrid() {
    return Column(
      children: [
        // Menu Legal Checklist (Full Width) dengan Arrow
        _buildMenuCard(
          title: 'Legal Checklist',
          subtitle: 'Panduan & pelacakan dokumen N1-N4',
          icon: Icons.assignment_outlined,
          iconBg: primaryLight,
          iconColor: primaryDark,
          badgeText: 'N1 sedang berjalan',
          badgeIcon: Icons.access_time,
          badgeColorText: const Color(0xFF966C23),
          badgeColorBg: const Color(0xFFFBF4E6),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward, size: 16, color: primaryDark),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Pilar Kehidupan (Ubah dari Edukasi)
            Expanded(
              child: _buildMenuCard(
                title: 'Pilar Kehidupan',
                subtitle: 'Panduan spiritual & agama',
                icon: Icons.menu_book_outlined,
                iconBg: purpleLight,
                iconColor: purpleDark,
                badgeText: '+ 3 pilar',
                badgeIcon: Icons.add,
                badgeColorText: purpleDark,
                badgeColorBg: purpleLight,
              ),
            ),
            const SizedBox(width: 12),
            // Katalog Vendor
            Expanded(
              child: _buildMenuCard(
                title: 'Katalog Vendor',
                subtitle: 'Direktori & info vendor',
                icon: Icons.storefront_outlined,
                iconBg: goldLight,
                iconColor: gold,
                badgeText: '48 vendor',
                badgeIcon: Icons.shopping_bag_outlined,
                badgeColorText: const Color(0xFF966C23),
                badgeColorBg: const Color(0xFFFBF4E6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String badgeText,
    required IconData badgeIcon,
    required Color badgeColorText,
    required Color badgeColorBg,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: textGrey)),
                const SizedBox(height: 12),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: badgeColorBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 10, color: badgeColorText),
                      const SizedBox(width: 4),
                      Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColorText)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // --- 5. KARTU PROGRES LEGAL ---
  Widget _buildLegalProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey, width: 1.5),
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
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: goldLight, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, size: 6, color: gold),
                          SizedBox(width: 4),
                          Text('Level Kelurahan — Dokumen N1', style: TextStyle(fontSize: 10, color: Color(0xFF966C23), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Text('25%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textGrey)),
                  ],
                ),
                const SizedBox(height: 16),
                // Segmented Progress Bar (Putus-putus)
                Row(
                  children: [
                    Expanded(child: Container(height: 4, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 4, decoration: BoxDecoration(color: borderGrey, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 4, decoration: BoxDecoration(color: borderGrey, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 4, decoration: BoxDecoration(color: borderGrey, borderRadius: BorderRadius.circular(2)))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('N1 Kelurahan', style: TextStyle(fontSize: 10, color: gold, fontWeight: FontWeight.bold)),
                    Text('N2 • N3 • N4', style: TextStyle(fontSize: 10, color: textGrey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NAVIGASI BAWAH ---
  Widget _buildBottomNav(HomeController controller) {
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryDark,
          unselectedItemColor: textGrey,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 20,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'To Do'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Vendor'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Edukasi'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          ],
        ));
  }
}