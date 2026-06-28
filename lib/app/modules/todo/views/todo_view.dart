import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';

class TodoView extends StatelessWidget {
  const TodoView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color bgGreen = Color(0xFFF2F5F4);
  static const Color textDark = Color(0xFF333333);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E8);
  static const Color gold = Color(0xFFC8A96A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TodoController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const _JourneySkeleton();
        }

        if (controller.hasError.value) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: () => controller.fetchJourney(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(controller: controller),
            const SizedBox(height: 12),
            _ViewModeSwitch(controller: controller),
            const SizedBox(height: 4),
            Expanded(
              child: controller.viewMode.value == 'mine'
                  ? _MyJourneyTab(controller: controller)
                  : _PartnerJourneyTab(controller: controller),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Header (profil ringkas) ─────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Wedding Journey',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: TodoView.textDark)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (controller.userReligion.value.isNotEmpty)
                    _Pill(
                      label: '${controller.userReligion.value} (${controller.userGender.value})',
                      bg: TodoView.primaryGreen.withOpacity(0.08),
                      fg: TodoView.primaryGreen,
                    ),
                  if (controller.isOutOfTown.value)
                    _Pill(
                      label: 'Numpang Nikah',
                      bg: TodoView.gold.withOpacity(0.1),
                      fg: TodoView.gold,
                    ),
                  if (controller.isForeigner.value)
                    _Pill(
                      label: 'Campuran WNA',
                      bg: TodoView.gold.withOpacity(0.1),
                      fg: TodoView.gold,
                    ),
                ],
              ),
            ],
          )),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg, fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

// ─── Progress Summary ────────────────────────────────────────────────────────

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.controller});
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Obx(() {
        final pct = controller.progressPercent;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TodoView.bgGreen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TodoView.primaryGreen.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 4,
                      backgroundColor: TodoView.primaryGreen.withOpacity(0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(TodoView.primaryGreen),
                    ),
                    Center(
                      child: Text(
                        '${(pct * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: TodoView.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${controller.doneSteps.value} dari ${controller.totalSteps.value} langkah selesai',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: TodoView.textDark),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── View Mode Switch (Saya / Pasangan) ──────────────────────────────────────

class _ViewModeSwitch extends StatelessWidget {
  const _ViewModeSwitch({required this.controller});
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        final mode = controller.viewMode.value;
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: TodoView.bgGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _SwitchTab(
                  label: 'Checklist Saya',
                  isActive: mode == 'mine',
                  onTap: () => controller.switchViewMode('mine'),
                ),
              ),
              Expanded(
                child: _SwitchTab(
                  label: 'Pasangan',
                  isActive: mode == 'partner',
                  onTap: () => controller.switchViewMode('partner'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SwitchTab extends StatelessWidget {
  const _SwitchTab({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? TodoView.primaryGreen : TodoView.textGrey,
          ),
        ),
      ),
    );
  }
}

// ─── Tab: Checklist Saya ─────────────────────────────────────────────────────

class _MyJourneyTab extends StatelessWidget {
  const _MyJourneyTab({required this.controller});
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: TodoView.primaryGreen,
      onRefresh: () => controller.fetchJourney(isRefresh: true),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            _ProgressSummary(controller: controller),
            const SizedBox(height: 8),
            Expanded(
              child: controller.journeySteps.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 8, bottom: 24),
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: controller.journeySteps.length,
                      itemBuilder: (context, index) {
                        final step = controller.journeySteps[index];
                        final isLast = index == controller.journeySteps.length - 1;
                        return _JourneyStepCard(step: step, isLast: isLast, controller: controller);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Tab: Checklist Pasangan (read-only) ─────────────────────────────────────

class _PartnerJourneyTab extends StatelessWidget {
  const _PartnerJourneyTab({required this.controller});
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isPartnerLoading.value) {
        return const _JourneySkeleton();
      }

      if (controller.hasPartnerError.value) {
        return _ErrorState(
          message: controller.partnerErrorMessage.value,
          onRetry: () => controller.fetchPartnerJourney(),
        );
      }

      if (!controller.isSynced.value) {
        return const _NotPairedState();
      }

      return RefreshIndicator(
        color: TodoView.primaryGreen,
        onRefresh: () => controller.fetchPartnerJourney(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TodoView.gold.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined, color: TodoView.gold, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mode lihat saja — hanya ${controller.partnerName.value.isEmpty ? "pasanganmu" : controller.partnerName.value} yang bisa menandai langkah ini.',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF966C23), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PartnerProgressSummary(controller: controller),
            const SizedBox(height: 8),
            Expanded(
              child: controller.partnerSteps.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(top: 8, bottom: 24),
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: controller.partnerSteps.length,
                      itemBuilder: (context, index) {
                        final step = controller.partnerSteps[index];
                        final isLast = index == controller.partnerSteps.length - 1;
                        return _PartnerStepCard(step: step, isLast: isLast);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _PartnerProgressSummary extends StatelessWidget {
  const _PartnerProgressSummary({required this.controller});
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        final pct = controller.partnerProgressPercent;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TodoView.bgGreen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TodoView.primaryGreen.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 4,
                      backgroundColor: TodoView.primaryGreen.withOpacity(0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(TodoView.primaryGreen),
                    ),
                    Center(
                      child: Text('${(pct * 100).round()}%',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: TodoView.primaryGreen)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${controller.partnerDoneSteps.value} dari ${controller.partnerTotalSteps.value} langkah selesai',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: TodoView.textDark),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// Kartu langkah versi pasangan — tampilan mirip _JourneyStepCard tapi tanpa
// checkbox/upload yang bisa ditekan, supaya jelas terlihat read-only.
class _PartnerStepCard extends StatelessWidget {
  const _PartnerStepCard({required this.step, required this.isLast});
  final PartnerJourneyStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDone = step.isDone;
    final isLocked = step.isLocked;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade100 : (isDone ? TodoView.primaryGreen : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked ? Colors.grey.shade300 : (isDone ? TodoView.primaryGreen : TodoView.borderGrey),
                    width: 2,
                  ),
                ),
                child: isLocked
                    ? Icon(Icons.lock, size: 12, color: Colors.grey.shade400)
                    : (isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: isDone ? TodoView.primaryGreen : TodoView.borderGrey),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Opacity(
                opacity: isLocked ? 0.55 : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDone ? TodoView.primaryGreen.withOpacity(0.2) : TodoView.borderGrey),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0, top: 2.0),
                        child: Icon(
                          isLocked ? Icons.lock_outline : (isDone ? Icons.check_box : Icons.check_box_outline_blank),
                          color: isLocked ? Colors.grey : (isDone ? TodoView.primaryGreen : TodoView.textGrey),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${step.category}: ${step.title}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDone ? TodoView.textGrey : TodoView.textDark,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(step.subtitle, style: const TextStyle(fontSize: 12, color: TodoView.textGrey, height: 1.4)),
                            if (step.requiresDocument) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    step.documentStatus == 'uploaded' ? Icons.cloud_done : Icons.cloud_off_outlined,
                                    size: 14,
                                    color: step.documentStatus == 'uploaded' ? TodoView.primaryGreen : TodoView.textGrey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    step.documentStatus == 'uploaded' ? 'Dokumen sudah diunggah' : 'Dokumen belum diunggah',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: step.documentStatus == 'uploaded' ? TodoView.primaryGreen : TodoView.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Belum Terhubung Pasangan ─────────────────────────────────────────────────

class _NotPairedState extends StatelessWidget {
  const _NotPairedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: TodoView.bgGreen, shape: BoxShape.circle),
              child: const Icon(Icons.link_off_rounded, color: TodoView.primaryGreen, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Belum Terhubung Pasangan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TodoView.textDark)),
            const SizedBox(height: 6),
            const Text(
              'Hubungkan akun di halaman Beranda untuk melihat progres checklist pasanganmu di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: TodoView.textGrey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Journey Step Card ────────────────────────────────────────────────────────

class _JourneyStepCard extends StatelessWidget {
  const _JourneyStepCard({required this.step, required this.isLast, required this.controller});
  final JourneyStep step;
  final bool isLast;
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDone = step.isDone.value;
      final isLocked = controller.isStepLocked(step);

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline kiri
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey.shade100 : (isDone ? TodoView.primaryGreen : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLocked ? Colors.grey.shade300 : (isDone ? TodoView.primaryGreen : TodoView.borderGrey),
                      width: 2,
                    ),
                  ),
                  child: isLocked
                      ? Icon(Icons.lock, size: 12, color: Colors.grey.shade400)
                      : (isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
                ),
                if (!isLast)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 2,
                      color: isDone ? TodoView.primaryGreen : TodoView.borderGrey,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Kartu kanan
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLocked ? 0.55 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDone ? TodoView.primaryGreen.withOpacity(0.2) : TodoView.borderGrey,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => controller.toggleStep(step),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12.0, top: 2.0),
                                  child: Icon(
                                    isLocked
                                        ? Icons.lock_outline
                                        : (isDone ? Icons.check_box : Icons.check_box_outline_blank),
                                    color: isLocked ? Colors.grey : (isDone ? TodoView.primaryGreen : TodoView.textGrey),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${step.category}: ${step.title}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDone ? TodoView.textGrey : TodoView.textDark,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(step.subtitle,
                                      style: const TextStyle(fontSize: 12, color: TodoView.textGrey, height: 1.4)),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => controller.showStepInfo(step),
                                child: const Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: Icon(Icons.info_outline, color: TodoView.textGrey, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (step.requiresDocument) ...[
                          const SizedBox(height: 16),
                          _DocumentSection(step: step, isLocked: isLocked, controller: controller),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Document Upload Section ─────────────────────────────────────────────────

class _DocumentSection extends StatelessWidget {
  const _DocumentSection({required this.step, required this.isLocked, required this.controller});
  final JourneyStep step;
  final bool isLocked;
  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = step.documentStatus.value;
      final isUploaded = status != 'empty';
      final isUploading = step.isUploading.value;

      return Container(
        decoration: BoxDecoration(
          color: isUploaded ? TodoView.bgGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isUploaded ? TodoView.primaryGreen.withOpacity(0.3) : TodoView.borderGrey),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Lembaga: ${step.targetInstitution}',
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.bold, color: TodoView.primaryGreen, letterSpacing: 0.3),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isUploaded) const Icon(Icons.cloud_done, color: TodoView.primaryGreen, size: 14),
              ],
            ),
            const SizedBox(height: 12),
            if (isUploading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TodoView.borderGrey),
                ),
                child: const Column(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: TodoView.primaryGreen),
                    ),
                    SizedBox(height: 8),
                    Text('Mengunggah berkas...',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TodoView.textDark)),
                  ],
                ),
              )
            else if (!isUploaded)
              GestureDetector(
                onTap: () => controller.uploadDocument(step),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TodoView.borderGrey),
                  ),
                  child: Column(
                    children: [
                      Icon(isLocked ? Icons.lock : Icons.upload_file,
                          color: isLocked ? Colors.grey.shade400 : TodoView.textGrey, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        isLocked ? 'Fitur Unggah Terkunci' : 'Unggah Dokumen (PDF/JPG)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isLocked ? Colors.grey.shade400 : TodoView.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.uploadedFileName.value,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TodoView.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text('Berkas aman di enkripsi awan',
                            style: TextStyle(fontSize: 10, color: TodoView.primaryGreen, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.uploadDocument(step),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: TodoView.borderGrey),
                      ),
                      child: const Icon(Icons.refresh, size: 14, color: TodoView.textGrey),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}

// ─── Skeleton Loading ─────────────────────────────────────────────────────────

class _JourneySkeleton extends StatelessWidget {
  const _JourneySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (i) => const _SkeletonCard()),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.4 + (_controller.value * 0.3);
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: opacity,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Color(0xFFE8E8E8), shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: TodoView.bgGreen, shape: BoxShape.circle),
              child: const Icon(Icons.checklist_rtl_rounded, color: TodoView.primaryGreen, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Belum ada langkah',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TodoView.textDark)),
            const SizedBox(height: 6),
            const Text(
              'Lengkapi profil pernikahanmu agar checklist legal dapat disesuaikan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: TodoView.textGrey, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(color: Color(0xFFFFF0F0), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Gagal Memuat Checklist',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: TodoView.textDark)),
            const SizedBox(height: 6),
            Text(
              message.isNotEmpty ? message : 'Terjadi kesalahan saat memuat data.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: TodoView.textGrey, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TodoView.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}