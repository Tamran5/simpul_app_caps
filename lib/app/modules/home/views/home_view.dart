import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../todo/views/todo_view.dart';
import '../../vendor/views/vendor_view.dart';
import '../../edukasi/views/edukasi_view.dart';
import '../../profile/views/profile_view.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const _cForest = Color(0xFF2D5A4E);
const _cForestMid = Color(0xFF3D6B5F);
const _cMist = Color(0xFFB8CFC9);
const _cFog = Color(0xFFEBF2F0);
const _cGold = Color(0xFFC8A96A);
const _cGoldLight = Color(0xFFF7F3EB);
const _cBg = Color(0xFFF5F6F5);
const _cSurface = Colors.white;
const _cInk = Color(0xFF111827);
const _cSubtext = Color(0xFF6B7280);
const _cBorder = Color(0xFFEEEEEE);
const _cLavender = Color(0xFFF0EEF8);
const _cLavDark = Color(0xFF6B5EA8);

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: _cBg,
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: controller.tabIndex.value,
            children: [
              _HomeContent(controller: controller),
              const TodoView(),
              const VendorView(),
              EdukasiView(),
              const ProfileView(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(controller: controller),
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isPageLoading.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _cForestMid, strokeWidth: 2),
              SizedBox(height: 16),
              Text(
                'Memuat data...',
                style: TextStyle(fontSize: 12, color: _cSubtext),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        color: _cForestMid,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(controller: controller),
                const SizedBox(height: 20),
                _PairCard(controller: controller),
                const SizedBox(height: 16),
                _CountdownCard(controller: controller),
                const SizedBox(height: 24),
                _SectionLabel('MENU UTAMA'),
                _MenuGrid(controller: controller),
                const SizedBox(height: 24),
                _SectionLabel('PROGRES LEGAL'),
                _LegalProgressCard(controller: controller),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PERENCANA PERNIKAHAN',
              style: TextStyle(
                fontSize: 9,
                color: _cSubtext,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Simpul',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: _cForest,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: TextStyle(
                      fontSize: 30,
                      color: _cGold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Obx(
          () => GestureDetector(
            onTap: () => _showNotifPanel(context, controller),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _cSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: _cBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: _cForestMid,
                    size: 22,
                  ),
                ),
                if (controller.hasUnreadNotif.value)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        controller.unreadNotifCount.value > 9
                            ? '9+'
                            : controller.unreadNotifCount.value.toString(),
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNotifPanel(BuildContext context, HomeController controller) {
    controller.fetchNotifications(); // mulai fetch saat panel akan dibuka
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotifPanel(controller: controller),
    );
  }
}

// ─── Notification Panel ───────────────────────────────────────────────────────

class _NotifPanel extends StatelessWidget {
  const _NotifPanel({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: _cBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _cInk,
                    ),
                  ),
                  Obx(
                    () => controller.hasUnreadNotif.value
                        ? GestureDetector(
                            onTap: controller.markAllNotifRead,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _cFog,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Tandai semua dibaca',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _cForestMid,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: Obx(() {
                if (controller.isNotifLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _cForestMid,
                      strokeWidth: 2,
                    ),
                  );
                }

                final notifs = controller.notifications;
                if (notifs.isEmpty) {
                  return _EmptyNotif();
                }

                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _NotifItem(notif: notifs[i]),
                );
              }),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotif extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: _cFog, shape: BoxShape.circle),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: _cMist,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _cInk,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Semua notifikasi akan muncul di sini.',
            style: TextStyle(fontSize: 12, color: _cSubtext),
          ),
        ],
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({required this.notif});
  final Map<String, dynamic> notif;

  IconData get _icon {
    switch (notif['notif_type']) {
      case 'pair':
        return Icons.favorite_rounded;
      case 'task':
        return Icons.check_circle_outline_rounded;
      case 'legal':
        return Icons.description_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color get _iconColor {
    switch (notif['notif_type']) {
      case 'pair':
        return const Color(0xFFE53935);
      case 'task':
        return _cGold;
      case 'legal':
        return _cForestMid;
      default:
        return _cLavDark;
    }
  }

  Color get _iconBg {
    switch (notif['notif_type']) {
      case 'pair':
        return const Color(0xFFFFF0F0);
      case 'task':
        return _cGoldLight;
      case 'legal':
        return _cFog;
      default:
        return _cLavender;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notif['is_read'] == true;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? _cSurface : _cFog,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRead ? _cBorder : _cMist, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _iconBg, shape: BoxShape.circle),
            child: Icon(_icon, color: _iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif['title'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isRead
                              ? FontWeight.w500
                              : FontWeight.bold,
                          color: _cInk,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _cForestMid,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if ((notif['body'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notif['body'] ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _cSubtext,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  notif['time_ago'] ?? '',
                  style: const TextStyle(fontSize: 10, color: _cSubtext),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pair Card ────────────────────────────────────────────────────────────────

class _PairCard extends StatelessWidget {
  const _PairCard({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final synced = controller.isSynced.value;
      final status = controller.syncStatus.value;

      if (synced) return _SyncedCard(controller: controller);
      if (status == 'pending_sent') return _PendingCard(controller: controller);
      return _UnsyncedCard(controller: controller);
    });
  }
}

class _UnsyncedCard extends StatelessWidget {
  const _UnsyncedCard({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cGold.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _cGold.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _cGoldLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.link_rounded, color: _cGold, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Belum terhubung pasangan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _cInk,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Hubungkan akun untuk merencanakan bersama.',
                  style: TextStyle(fontSize: 11, color: _cSubtext, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: controller.goToPairingSetup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _cForestMid,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Hubungkan',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cMist, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: _cFog,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: _cForestMid,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menunggu konfirmasi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _cInk,
                  ),
                ),
                const SizedBox(height: 3),
                Obx(
                  () => Text(
                    'Permintaan dikirim ke ${controller.partnerName.value.isNotEmpty ? controller.partnerName.value : "pasanganmu"}.',
                    style: const TextStyle(fontSize: 11, color: _cSubtext),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncedCard extends StatelessWidget {
  const _SyncedCard({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Avatar(
            initials: controller.myInitials.value,
            photoUrl: controller.myPhotoUrl.value,
            bgColor: _cFog,
            textColor: _cForestMid,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _cFog,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cMist),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 5, color: _cForestMid),
                      SizedBox(width: 5),
                      Text(
                        'Tersinkron',
                        style: TextStyle(
                          fontSize: 10,
                          color: _cForestMid,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Text(
                    '${controller.myName.value} & ${controller.partnerName.value}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _cInk,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Progres terlihat berdua',
                  style: TextStyle(fontSize: 10, color: _cSubtext),
                ),
              ],
            ),
          ),
          _Avatar(
            initials: controller.partnerInitials.value,
            photoUrl: controller.partnerPhotoUrl.value,
            bgColor: _cLavender,
            textColor: _cLavDark,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.photoUrl,
    required this.bgColor,
    required this.textColor,
  });
  final String initials, photoUrl;
  final Color bgColor, textColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: bgColor,
      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
      child: photoUrl.isEmpty
          ? Text(
              initials,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}

// ─── Countdown Card ───────────────────────────────────────────────────────────

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.controller});
  final HomeController controller;

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
            color: const Color(0xFF2D5A4E).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HITUNG MUNDUR',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white60,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(
                  () => GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 10,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            controller.weddingDateStr.value.isEmpty
                                ? 'Atur tanggal'
                                : controller.weddingDateStr.value,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Ring + countdown
            Row(
              children: [
                Obx(() {
                  final pct = controller.totalTasks.value > 0
                      ? controller.completedTasks.value /
                            controller.totalTasks.value
                      : 0.0;
                  return SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: pct,
                          strokeWidth: 5,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            _cMist,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(pct * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'SELESAI',
                              style: TextStyle(
                                fontSize: 7,
                                color: Colors.white60,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.isSynced.value &&
                                  controller.partnerName.value.isNotEmpty
                              ? '${controller.myName.value} & ${controller.partnerName.value}'
                              : controller.myName.value.isEmpty
                              ? 'Hari Bahagiamu'
                              : 'Rencana ${controller.myName.value}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _TimeTile(
                              number: _pad(controller.daysRemaining.value),
                              label: 'HARI',
                            ),
                            _TimeDot(),
                            _TimeTile(
                              number: _pad(controller.hoursRemaining.value),
                              label: 'JAM',
                            ),
                            _TimeDot(),
                            _TimeTile(
                              number: _pad(controller.minutesRemaining.value),
                              label: 'MNT',
                            ),
                            _TimeDot(),
                            _TimeTile(
                              number: _pad(controller.secondsRemaining.value),
                              label: 'DTK',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white10),
            const SizedBox(height: 16),

            // Progress bar — hanya tampil jika ada data legal
            Obx(() {
              final lp = controller.legalProgress.value;
              final tp = controller.taskProgress.value;
              final rem = (1 - lp - tp).clamp(0.0, 1.0);

              final hasLegal = lp > 0 || tp > 0;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progres keseluruhan',
                        style: TextStyle(fontSize: 10, color: Colors.white60),
                      ),
                      // ✅ FIX: hanya tampil jika ada data
                      if (hasLegal)
                        Text(
                          '${controller.completedTasks.value} / ${controller.totalTasks.value} selesai',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          'Belum ada progres',
                          style: TextStyle(fontSize: 10, color: Colors.white38),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: hasLegal
                        ? Row(
                            children: [
                              if ((lp * 100).round() > 0)
                                Expanded(
                                  flex: (lp * 100).round(),
                                  child: Container(height: 7, color: _cMist),
                                ),
                              if ((tp * 100).round() > 0)
                                Expanded(
                                  flex: (tp * 100).round(),
                                  child: Container(height: 7, color: _cGold),
                                ),
                              if ((rem * 100).round() > 0)
                                Expanded(
                                  flex: (rem * 100).round(),
                                  child: Container(
                                    height: 7,
                                    color: Colors.black26,
                                  ),
                                ),
                            ],
                          )
                        : Container(
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  if (hasLegal)
                    Row(
                      children: [
                        _Legend(_cMist, 'Legal (${(lp * 100).round()}%)'),
                        const SizedBox(width: 16),
                        _Legend(_cGold, 'Tugas (${(tp * 100).round()}%)'),
                        const SizedBox(width: 16),
                        _Legend(
                          Colors.white38,
                          'Sisa (${(rem * 100).round()}%)',
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Mulai checklist untuk melihat progres',
                      style: TextStyle(fontSize: 10, color: Colors.white38),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<void> _pickDate(BuildContext context) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    // FIX: pastikan initialDate tidak kurang dari tomorrow
    DateTime initialDate = tomorrow;
    if (controller.targetDate != null &&
        controller.targetDate!.isAfter(DateTime.now())) {
      initialDate = controller.targetDate!;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // ← selalu >= tomorrow
      firstDate: tomorrow, // ← hard block tanggal lampau
      lastDate: DateTime(2035),
      helpText: 'Pilih tanggal pernikahan',
      cancelText: 'Batal',
      confirmText: 'Simpan',
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _cForestMid,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _cForestMid),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.updateWeddingDate(picked);
    }
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.number, required this.label});
  final String number, label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white60,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _TimeDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white38,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 6, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white60)),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _cSubtext,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ─── Menu Grid ────────────────────────────────────────────────────────────────

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuCard(
          title: 'Legal Checklist',
          subtitle: 'Panduan & pelacakan dokumen N1–N4',
          icon: Icons.assignment_outlined,
          iconBg: _cFog,
          iconColor: _cForestMid,
          badgeBuilder: (context) => Obx(() {
            final doc = controller.currentLegalDoc.value;
            return _Badge(
              icon: Icons.access_time_rounded,
              label: doc.isNotEmpty
                  ? '$doc sedang berjalan'
                  : 'Mulai cek dokumen',
              textColor: const Color(0xFF966C23),
              bgColor: const Color(0xFFFBF4E6),
            );
          }),
          trailing: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _cFog, shape: BoxShape.circle),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: _cForestMid,
            ),
          ),
          onTap: () => controller.changeTabIndex(1),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MenuCard(
                title: 'Edukasi',
                subtitle: 'Artikel & panduan nikah',
                icon: Icons.menu_book_outlined,
                iconBg: _cLavender,
                iconColor: _cLavDark,
                badgeBuilder: (_) => const _Badge(
                  icon: Icons.auto_stories_outlined,
                  label: 'Jelajahi artikel',
                  textColor: _cLavDark,
                  bgColor: _cLavender,
                ),
                onTap: () => controller.changeTabIndex(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MenuCard(
                title: 'Vendor',
                subtitle: 'Direktori & info vendor',
                icon: Icons.storefront_outlined,
                iconBg: _cGoldLight,
                iconColor: _cGold,
                badgeBuilder: (_) => const _Badge(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Lihat katalog',
                  textColor: Color(0xFF966C23),
                  bgColor: Color(0xFFFBF4E6),
                ),
                onTap: () => controller.changeTabIndex(2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeBuilder,
    this.trailing,
    this.onTap,
  });

  final String title, subtitle;
  final IconData icon;
  final Color iconBg, iconColor;
  final WidgetBuilder badgeBuilder;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _cInk,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _cSubtext,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(builder: badgeBuilder),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.bgColor,
  });
  final IconData icon;
  final String label;
  final Color textColor, bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legal Progress Card ──────────────────────────────────────────────────────

class _LegalProgressCard extends StatelessWidget {
  const _LegalProgressCard({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final level = controller.currentLegalLevel.value;
      final doc = controller.currentLegalDoc.value;
      final percent = controller.legalProgressPercent.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _cFog,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: _cForestMid,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tahap Dokumen Saat Ini',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _cInk,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        level.isNotEmpty ? 'Level $level' : 'Belum ada data',
                        style: const TextStyle(fontSize: 11, color: _cSubtext),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _cSubtext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            if (doc.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _cGoldLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 6, color: _cGold),
                    const SizedBox(width: 6),
                    Text(
                      level.isNotEmpty
                          ? 'Level $level — Dokumen $doc'
                          : 'Dokumen $doc',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF966C23),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            _StageProgressBar(currentDoc: doc),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stageLabel('N1', doc),
                _stageLabel('N2', doc),
                _stageLabel('N3', doc),
                _stageLabel('N4', doc),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _stageLabel(String stage, String currentDoc) {
    final isActive = currentDoc == stage;
    return Text(
      stage,
      style: TextStyle(
        fontSize: 10,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        color: isActive ? _cGold : _cSubtext,
      ),
    );
  }
}

class _StageProgressBar extends StatelessWidget {
  const _StageProgressBar({required this.currentDoc});
  final String currentDoc;

  static const stages = ['N1', 'N2', 'N3', 'N4'];

  Color _color(String stage) {
    final idx = stages.indexOf(stage);
    final cur = stages.indexOf(currentDoc);
    if (cur < 0) return _cBorder;
    if (idx < cur) return _cForestMid;
    if (idx == cur) return _cGold;
    return _cBorder;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stages.asMap().entries.map((e) {
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: _color(e.value),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (e.key < stages.length - 1) const SizedBox(width: 4),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: _cSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: _cForestMid,
          unselectedItemColor: _cSubtext,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'To Do',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              label: 'Vendor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: 'Edukasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
