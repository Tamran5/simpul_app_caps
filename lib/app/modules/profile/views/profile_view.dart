import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  static const _cForest    = Color(0xFF2D5A4E);
  static const _cForestMid = Color(0xFF3D6B5F);
  static const _cMist      = Color(0xFFB8CFC9);
  static const _cFog       = Color(0xFFEBF2F0);
  static const _cGold      = Color(0xFFC8A96A);
  static const _cGoldLight = Color(0xFFF7F3EB);
  static const _cBg        = Color(0xFFF5F6F5);
  static const _cSurface   = Colors.white;
  static const _cInk       = Color(0xFF111827);
  static const _cSubtext   = Color(0xFF6B7280);
  static const _cBorder    = Color(0xFFEEEEEE);
  static const _cDanger    = Color(0xFFDC2626);
  static const _cDangerBg  = Color(0xFFFEF2F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cBg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _cForestMid, strokeWidth: 2),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchUserProfile,
          color: _cForestMid,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              SliverAppBar(
                backgroundColor: _cBg,
                elevation: 0,
                floating: true,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Simpul',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          color: _cForest,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: TextStyle(
                            fontSize: 26,
                            color: _cGold,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ProfileHero(controller: controller),
                    const SizedBox(height: 24),

                    Obx(() => controller.isSynced.value
                        ? Column(
                            children: [
                              _WeddingInfoCard(
                                  controller: controller,
                                  context: context),
                              const SizedBox(height: 24),
                            ],
                          )
                        : const SizedBox.shrink()),

                    _SectionHeader('PENGATURAN AKUN'),
                    const SizedBox(height: 10),
                    _SettingsGroup(items: [
                      _SettingTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profil',
                        subtitle: 'Nama, foto, dan informasi dasar',
                        onTap: controller.editProfile,
                      ),
                      _SettingTile(
                        icon: Icons.face_retouching_natural_outlined,
                        label: 'Face ID',
                        subtitle: 'Daftarkan wajah untuk login cepat',
                        onTap: () => Get.toNamed('/face-scan',
                            arguments: {'from': 'profile'}),
                      ),
                      _SettingTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Ubah Kata Sandi',
                        subtitle: 'Perbarui keamanan akunmu',
                        onTap: () => Get.toNamed('/changepassword'),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    _SectionHeader('LAINNYA'),
                    const SizedBox(height: 10),
                    _SettingsGroup(items: [
                      _SettingTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Pusat Bantuan',
                        subtitle: 'FAQ dan panduan penggunaan',
                        onTap: () => Get.toNamed('/faq'),
                      ),
                      _SettingTile(
                        icon: Icons.info_outline_rounded,
                        label: 'Tentang Simpul',
                        subtitle: 'Versi aplikasi dan lisensi',
                        onTap: () => Get.toNamed('/about'),
                      ),
                    ]),
                    const SizedBox(height: 28),

                    _LogoutButton(onTap: controller.logout),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Profile Hero ─────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.controller});
  final ProfileController controller;

  static const _cForestMid = Color(0xFF3D6B5F);
  static const _cGold      = Color(0xFFC8A96A);
  static const _cInk       = Color(0xFF111827);
  static const _cSubtext   = Color(0xFF6B7280);
  static const _cFog       = Color(0xFFEBF2F0);
  static const _cBorder    = Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Avatar — TANPA icon kamera (ganti foto hanya via Edit Profil)
          Obx(() {
            final url = controller.userPhotoUrl.value;
            return CircleAvatar(
              radius: 44,
              backgroundColor: _cFog,
              backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
              child: url.isEmpty
                  ? Text(
                      _initials(controller.userName.value),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _cForestMid),
                    )
                  : null,
            );
          }),
          const SizedBox(height: 14),

          Obx(() => Text(
                controller.userName.value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _cInk),
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.userEmail.value,
                style: const TextStyle(fontSize: 13, color: _cSubtext),
              )),
          const SizedBox(height: 16),

          Obx(() {
            final code = controller.myUniqueCode.value;
            if (code.isEmpty) return const SizedBox.shrink();
            return GestureDetector(
              onTap: controller.copyMyCode,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _cFog,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _cForestMid.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag_rounded, size: 14, color: _cForestMid),
                    const SizedBox(width: 6),
                    Text(
                      code,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                          color: _cForestMid),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _cGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Salin',
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF966C23),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
  }
}

// ─── Wedding Info Card ────────────────────────────────────────────────────────

class _WeddingInfoCard extends StatelessWidget {
  const _WeddingInfoCard({required this.controller, required this.context});
  final ProfileController controller;
  final BuildContext context;

  static const _cMist = Color(0xFFB8CFC9);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D5A4E), Color(0xFF3D6B5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2D5A4E).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RENCANA PERNIKAHAN',
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.white60,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BERSAMA',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.white54,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            controller.partnerName.value.isNotEmpty
                                ? controller.partnerName.value
                                : '—',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                    ],
                  ),
                ),

                Container(width: 1, height: 36, color: Colors.white24),
                const SizedBox(width: 16),

                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.aturJadwalNikah(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text('TANGGAL',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white54,
                                    letterSpacing: 1.2)),
                            SizedBox(width: 4),
                            Icon(Icons.edit_rounded,
                                size: 10, color: Colors.white38),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              controller.weddingDate.value.isNotEmpty
                                  ? controller.weddingDate.value
                                  : 'Atur tanggal',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: controller.weddingDate.value.isNotEmpty
                                      ? Colors.white
                                      : const Color(0xFFC8A96A)),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white10),
            const SizedBox(height: 14),

            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 5, color: _cMist),
                      SizedBox(width: 5),
                      Text('Akun Tersinkron',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B7280),
            letterSpacing: 1.5),
      ),
    );
  }
}

// ─── Settings Group ───────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<_SettingTile> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final tile = entry.value;
          return Column(
            children: [
              tile,
              if (i < items.length - 1)
                const Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 0,
                    color: Color(0xFFF0F0F0)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Setting Tile ─────────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconColor = const Color(0xFF3D6B5F),
    this.iconBg = const Color(0xFFEBF2F0),
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827))),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCCCCCC), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 8),
            Text(
              'Keluar dari Akun',
              style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}