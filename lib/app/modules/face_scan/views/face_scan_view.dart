// views/face_scan_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/face_scan_controller.dart';

class FaceScanView extends StatelessWidget {
  const FaceScanView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color bgColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA726);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FaceScanController());
    final args = Get.arguments as Map<String, dynamic>?;
    final mode = args?['mode'] ?? 'register';
    // 'onboarding' = alur daftar akun baru, 'settings' = dipicu dari menu Pengaturan
    // final origin = args?['origin'] ?? 'onboarding';

    final String modeTitle = switch (mode) {
      'login' => 'Login dengan Wajah',
      'verify' => 'Verifikasi Wajah',
      'update' => 'Perbarui Data Wajah',
      _ => 'Daftarkan Wajah',
    };

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textDark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          modeTitle,
          style: const TextStyle(
            color: textDark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE8E8E8), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Kartu Status Step ─────────────────────────────────
              _StepIndicator(mode: mode),
              const SizedBox(height: 24),

              // ── Kartu Kamera Utama ────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Instruksi ─────────────────────────────────
                    Obx(
                      () => _InstructionBanner(
                        text: controller.instructionText.value,
                        step: controller.scanStep.value,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Area Kamera ───────────────────────────────
                    GetBuilder<FaceScanController>(
                      builder: (ctrl) => Obx(() {
                        final step = ctrl.scanStep.value;
                        final progress = ctrl.scanProgress.value;
                        return _CameraFrame(
                          controller: ctrl,
                          step: step,
                          progress: progress,
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // ── Indikator Cahaya ──────────────────────────
                    Obx(() => _LightIndicator(step: controller.scanStep.value)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Panduan Singkat ───────────────────────────────────
              Obx(() {
                if (controller.scanStep.value != 0) return const SizedBox();
                return _GuideTips();
              }),

              const SizedBox(height: 20),

              // ── Tombol Aksi ───────────────────────────────────────
              Obx(() {
                final step = controller.scanStep.value;
                final showLoginOption = controller.showLoginOption.value;
                return _ActionButton(
                  step: step,
                  showLoginOption: showLoginOption,
                  onStart: () => controller.startScanning(),
                  onReset: () => controller.resetScan(),
                  onGoToLogin: () => controller.goToLogin(),
                );
              }),

              const SizedBox(height: 12),

              // ── Teks Privasi ──────────────────────────────────────
              const Text(
                '🔒  Foto tidak disimpan. Hanya data vektor terenkripsi yang digunakan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: textGrey, height: 1.5),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Step Indicator (3 langkah)
// ─────────────────────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final String mode;
  const _StepIndicator({required this.mode});

  @override
  Widget build(BuildContext context) {
    final steps = (mode == 'verify' || mode == 'login')
        ? ['Posisikan', 'Pindai', 'Verifikasi']
        : ['Posisikan', 'Pindai', 'Simpan'];

    return GetX<FaceScanController>(
      builder: (ctrl) {
        // 0=idle→step0, 1=scanning→step1, 2=processing→step2, 3=done→step3
        final activeIndex = ctrl.scanStep.value == 0
            ? 0
            : ctrl.scanStep.value == 1
            ? 1
            : ctrl.scanStep.value >= 2
            ? 2
            : 0;

        return Row(
          children: List.generate(steps.length * 2 - 1, (i) {
            if (i.isOdd) {
              // Garis penghubung
              final lineActive = (i ~/ 2) < activeIndex;
              return Expanded(
                child: Container(
                  height: 2,
                  color: lineActive
                      ? const Color(0xFF596E63)
                      : const Color(0xFFE0E0E0),
                ),
              );
            }
            final idx = i ~/ 2;
            final isDone = idx < activeIndex;
            final isActive = idx == activeIndex;

            return Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? const Color(0xFF596E63)
                        : isActive
                        ? const Color(0xFF596E63).withOpacity(0.15)
                        : const Color(0xFFF0F0F0),
                    border: Border.all(
                      color: isActive || isDone
                          ? const Color(0xFF596E63)
                          : const Color(0xFFE0E0E0),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? const Color(0xFF596E63)
                                  : const Color(0xFFBDBDBD),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[idx],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive || isDone
                        ? const Color(0xFF596E63)
                        : const Color(0xFFBDBDBD),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Banner Instruksi Dinamis
// ─────────────────────────────────────────────────────────────────────────────
class _InstructionBanner extends StatelessWidget {
  final String text;
  final int step;
  const _InstructionBanner({required this.text, required this.step});

  @override
  Widget build(BuildContext context) {
    Color bgCol = const Color(0xFFF0F4F2);
    Color fgCol = const Color(0xFF596E63);
    IconData icon = Icons.info_outline_rounded;

    if (step == 3) {
      bgCol = const Color(0xFFE8F5E9);
      fgCol = const Color(0xFF2E7D32);
      icon = Icons.check_circle_outline_rounded;
    } else if (step == 4) {
      bgCol = const Color(0xFFFFEBEE);
      fgCol = const Color(0xFFC62828);
      icon = Icons.error_outline_rounded;
    } else if (step == 1) {
      bgCol = const Color(0xFFFFF8E1);
      fgCol = const Color(0xFFF57F17);
      icon = Icons.face_rounded;
    } else if (step == 2) {
      bgCol = const Color(0xFFE3F2FD);
      fgCol = const Color(0xFF1565C0);
      icon = Icons.sync_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgCol, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fgCol,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Frame Kamera dengan Overlay
// ─────────────────────────────────────────────────────────────────────────────
class _CameraFrame extends StatelessWidget {
  final FaceScanController controller;
  final int step;
  final double progress;

  const _CameraFrame({
    required this.controller,
    required this.step,
    required this.progress,
  });

  static const Color primaryGreen = Color(0xFF596E63);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Background + Preview Kamera ───────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildCameraOrPlaceholder(),
          ),

          // ── Sudut Bingkai (Corner Brackets) ───────────────────
          ..._buildCornerBrackets(step),

          // ── Oval Guide (Panduan posisi wajah) ─────────────────
          _OvalFaceGuide(step: step, progress: progress),

          // ── Garis Scan Animasi ─────────────────────────────────
          if (step == 1) _ScanLine(progress: progress),

          // ── Overlay Processing ─────────────────────────────────
          if (step == 2) _ProcessingOverlay(),

          // ── Overlay Sukses ─────────────────────────────────────
          if (step == 3) _ResultOverlay(isSuccess: true),

          // ── Overlay Gagal ──────────────────────────────────────
          if (step == 4) _ResultOverlay(isSuccess: false),

          // ── Progress Bar bawah ─────────────────────────────────
          if (step == 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraOrPlaceholder() {
    if (controller.isCameraReady.value &&
        controller.cameraController != null &&
        controller.cameraController!.value.isInitialized &&
        step < 3) {
      return CameraPreview(controller.cameraController!);
    }
    // Placeholder saat kamera belum siap
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                color: const Color(0xFF596E63),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Memuat kamera...',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerBrackets(int step) {
    final color = step == 3
        ? const Color(0xFF4CAF50)
        : step == 4
        ? const Color(0xFFE53935)
        : const Color(0xFF596E63);

    const double size = 24;
    const double thick = 3;
    const double r = 20.0;

    Widget bracket({
      required Alignment align,
      required BorderRadius borderRadius,
    }) => Positioned.fill(
      child: Align(
        alignment: align,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: color, width: thick),
          ),
        ),
      ),
    );

    return [
      bracket(
        align: Alignment.topLeft,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(r)),
      ),
      bracket(
        align: Alignment.topRight,
        borderRadius: BorderRadius.only(topRight: Radius.circular(r)),
      ),
      bracket(
        align: Alignment.bottomLeft,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(r)),
      ),
      bracket(
        align: Alignment.bottomRight,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(r)),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Oval Guide Posisi Wajah
// ─────────────────────────────────────────────────────────────────────────────
class _OvalFaceGuide extends StatelessWidget {
  final int step;
  final double progress;
  const _OvalFaceGuide({required this.step, required this.progress});

  @override
  Widget build(BuildContext context) {
    final borderColor = step == 3
        ? const Color(0xFF4CAF50)
        : step == 4
        ? const Color(0xFFE53935)
        : step == 1
        ? const Color(0xFF596E63)
        : Colors.white54;

    return Container(
      width: 180,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(120),
        border: Border.all(color: borderColor, width: step == 1 ? 2.5 : 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Garis Scan
// ─────────────────────────────────────────────────────────────────────────────
class _ScanLine extends StatelessWidget {
  final double progress;
  const _ScanLine({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30 + (220 * progress).clamp(0.0, 220.0),
      child: Container(
        width: 160,
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFF596E63),
              const Color(0xFF596E63),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF596E63).withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Overlay Processing
// ─────────────────────────────────────────────────────────────────────────────
class _ProcessingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: Color(0xFF596E63),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Menganalisis wajah...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Harap tunggu sebentar',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Overlay Hasil (Sukses / Gagal)
// ─────────────────────────────────────────────────────────────────────────────
class _ResultOverlay extends StatelessWidget {
  final bool isSuccess;
  const _ResultOverlay({required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: isSuccess
            ? const Color(0xFF4CAF50).withOpacity(0.20)
            : const Color(0xFFE53935).withOpacity(0.20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSuccess
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935),
                ),
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSuccess ? 'Wajah Terverifikasi' : 'Verifikasi Gagal',
                style: TextStyle(
                  color: isSuccess
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Indikator Cahaya
// ─────────────────────────────────────────────────────────────────────────────
class _LightIndicator extends StatelessWidget {
  final int step;
  const _LightIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    // Simulasi status cahaya berdasarkan step
    // Di produksi: bisa dihitung dari luminance frame kamera
    final bool isScanning = step == 1;
    final bool isIdle = step == 0;

    if (!isIdle && !isScanning) return const SizedBox();

    // Status cahaya: ideal saat scanning, peringatan saat idle
    final lightStatus = isScanning ? _LightStatus.good : _LightStatus.checking;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: lightStatus.bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: lightStatus.borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Ikon lampu + level bar
          Icon(Icons.wb_sunny_outlined, color: lightStatus.iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lightStatus.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: lightStatus.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                // Bar level cahaya
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: lightStatus.level,
                    minHeight: 5,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      lightStatus.iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: lightStatus.iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              lightStatus.badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: lightStatus.iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _LightStatus { good, warning, bad, checking }

extension _LightStatusExt on _LightStatus {
  Color get bgColor => switch (this) {
    _LightStatus.good => const Color(0xFFE8F5E9),
    _LightStatus.warning => const Color(0xFFFFF8E1),
    _LightStatus.bad => const Color(0xFFFFEBEE),
    _LightStatus.checking => const Color(0xFFF5F5F5),
  };

  Color get borderColor => switch (this) {
    _LightStatus.good => const Color(0xFFA5D6A7),
    _LightStatus.warning => const Color(0xFFFFE082),
    _LightStatus.bad => const Color(0xFFEF9A9A),
    _LightStatus.checking => const Color(0xFFE0E0E0),
  };

  Color get iconColor => switch (this) {
    _LightStatus.good => const Color(0xFF388E3C),
    _LightStatus.warning => const Color(0xFFF57F17),
    _LightStatus.bad => const Color(0xFFD32F2F),
    _LightStatus.checking => const Color(0xFF9E9E9E),
  };

  Color get textColor => switch (this) {
    _LightStatus.good => const Color(0xFF1B5E20),
    _LightStatus.warning => const Color(0xFFE65100),
    _LightStatus.bad => const Color(0xFFB71C1C),
    _LightStatus.checking => const Color(0xFF757575),
  };

  String get label => switch (this) {
    _LightStatus.good => 'Pencahayaan baik — siap dipindai',
    _LightStatus.warning => 'Cahaya kurang — pindah ke tempat lebih terang',
    _LightStatus.bad => 'Terlalu gelap — tidak dapat memindai wajah',
    _LightStatus.checking => 'Mendeteksi pencahayaan ruangan...',
  };

  String get badge => switch (this) {
    _LightStatus.good => 'BAIK',
    _LightStatus.warning => 'KURANG',
    _LightStatus.bad => 'GELAP',
    _LightStatus.checking => 'CEK',
  };

  double get level => switch (this) {
    _LightStatus.good => 0.85,
    _LightStatus.warning => 0.45,
    _LightStatus.bad => 0.15,
    _LightStatus.checking => 0.50,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Tips Panduan (hanya muncul di step 0)
// ─────────────────────────────────────────────────────────────────────────────
class _GuideTips extends StatelessWidget {
  final _tips = const [
    (Icons.wb_sunny_outlined, 'Pastikan pencahayaan cukup dan merata'),
    (Icons.face_rounded, 'Hadap langsung ke kamera, jangan miring'),
    (Icons.remove_red_eye_outlined, 'Lepas kacamata dan penutup wajah'),
    (Icons.stay_current_portrait_outlined, 'Pegang ponsel setinggi wajah'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: Color(0xFF596E63),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Tips untuk hasil terbaik',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF596E63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(t.$1, size: 15, color: const Color(0xFF8A8A8A)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t.$2,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Tombol Aksi
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final int step;
  final bool showLoginOption;
  final VoidCallback onStart;
  final VoidCallback onReset;
  final VoidCallback onGoToLogin;

  const _ActionButton({
    required this.step,
    required this.showLoginOption,
    required this.onStart,
    required this.onReset,
    required this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIdle = step == 0;
    final bool isDone = step == 3;
    final bool isFailed = step == 4;
    final bool isScanning = step == 1 || step == 2;

    String label;
    Color bgCol;
    IconData icon;

    if (isIdle) {
      label = 'Mulai Pemindaian';
      bgCol = const Color(0xFF596E63);
      icon = Icons.face_retouching_natural_rounded;
    } else if (isScanning) {
      label = 'Memindai...';
      bgCol = const Color(0xFF596E63).withOpacity(0.5);
      icon = Icons.hourglass_top_rounded;
    } else if (isDone) {
      label = 'Selesai';
      bgCol = const Color(0xFF4CAF50);
      icon = Icons.check_rounded;
    } else {
      label = 'Coba Lagi';
      bgCol = const Color(0xFFE53935);
      icon = Icons.refresh_rounded;
    }

    final primaryButton = SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isScanning
            ? null
            : isDone
            ? null
            : isFailed
            ? onReset
            : onStart,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgCol,
          disabledBackgroundColor: bgCol,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white70,
          elevation: isScanning ? 0 : 2,
          shadowColor: bgCol.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );

    // ✅ Hanya tampil saat error fatal di mode verify — user pilih sendiri
    if (isFailed && showLoginOption) {
      return Column(
        children: [
          primaryButton,
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onGoToLogin,
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text(
                'Kembali ke Login',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF596E63),
                side: const BorderSide(color: Color(0xFF596E63), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return primaryButton;
  }
}
