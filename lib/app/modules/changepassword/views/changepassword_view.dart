import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/changepassword_controller.dart';

class ChangepasswordView extends GetView<ChangepasswordController> {
  const ChangepasswordView({super.key});

  static const _cBg       = Color(0xFFF5F6F5);
  static const _cSurface  = Colors.white;
  static const _cForest   = Color(0xFF2D5A4E);
  static const _cForestMid= Color(0xFF3D6B5F);
  static const _cInk      = Color(0xFF111827);
  static const _cSubtext  = Color(0xFF6B7280);
  static const _cBorder   = Color(0xFFEEEEEE);
  static const _cFog      = Color(0xFFEBF2F0);
  static const _cGreen    = Color(0xFF16A34A);
  static const _cRed      = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cBg,
      appBar: AppBar(
        backgroundColor: _cBg,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cSurface,
              shape: BoxShape.circle,
              border: Border.all(color: _cBorder, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: _cInk, size: 18),
          ),
        ),
        title: const Text('Ubah Kata Sandi',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _cInk,
                letterSpacing: -0.2)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info Banner ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cFog,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _cForestMid.withOpacity(0.2), width: 1.5),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline_rounded,
                      color: _cForestMid, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gunakan minimal 8 karakter dengan kombinasi huruf besar dan angka.',
                      style: TextStyle(
                          fontSize: 12, color: _cForestMid, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Kata Sandi Lama ─────────────────────────────────────
            _sectionLabel('KATA SANDI SAAT INI'),
            const SizedBox(height: 10),
            _buildCard([
              Obx(() => _PasswordField(
                    label: 'Kata Sandi Lama',
                    ctrl: controller.oldPasswordController,
                    icon: Icons.lock_outline_rounded,
                    hint: 'Masukkan kata sandi saat ini',
                    show: controller.showOld.value,
                    onToggle: () =>
                        controller.showOld.value = !controller.showOld.value,
                  )),
            ]),
            const SizedBox(height: 20),

            // ── Kata Sandi Baru ─────────────────────────────────────
            _sectionLabel('KATA SANDI BARU'),
            const SizedBox(height: 10),
            _buildCard([
              Obx(() => _PasswordField(
                    label: 'Kata Sandi Baru',
                    ctrl: controller.newPasswordController,
                    icon: Icons.lock_reset_outlined,
                    hint: 'Minimal 8 karakter',
                    show: controller.showNew.value,
                    onToggle: () =>
                        controller.showNew.value = !controller.showNew.value,
                  )),
              const Divider(
                  height: 1, indent: 16, endIndent: 16,
                  color: Color(0xFFF0F0F0)),
              Obx(() => _PasswordField(
                    label: 'Konfirmasi Kata Sandi',
                    ctrl: controller.confirmPasswordController,
                    icon: Icons.lock_outline_rounded,
                    hint: 'Ulangi kata sandi baru',
                    show: controller.showConfirm.value,
                    onToggle: () => controller.showConfirm.value =
                        !controller.showConfirm.value,
                  )),
            ]),
            const SizedBox(height: 16),

            // ── Password Strength Checklist ─────────────────────────
            Obx(() => _buildChecklist()),
            const SizedBox(height: 32),

            // ── Submit Button ────────────────────────────────────────
            Obx(() => _SubmitButton(
                  isLoading: controller.isLoading.value,
                  onTap: controller.gantiPassword,
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _cSubtext,
                letterSpacing: 1.5)),
      );

  Widget _buildCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _buildChecklist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Syarat kata sandi:',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _cSubtext)),
          const SizedBox(height: 10),
          _checkItem('Minimal 8 karakter', controller.hasMinLength.value),
          const SizedBox(height: 6),
          _checkItem('Mengandung huruf besar (A-Z)', controller.hasUppercase.value),
          const SizedBox(height: 6),
          _checkItem('Mengandung angka (0-9)', controller.hasNumber.value),
          const SizedBox(height: 6),
          _checkItem('Kata sandi cocok', controller.passwordsMatch.value),
        ],
      ),
    );
  }

  Widget _checkItem(String text, bool ok) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: ok ? _cGreen.withOpacity(0.1) : const Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            ok ? Icons.check_rounded : Icons.close_rounded,
            size: 11,
            color: ok ? _cGreen : const Color(0xFFD1D5DB),
          ),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: TextStyle(
                fontSize: 12,
                color: ok ? _cGreen : _cSubtext,
                fontWeight: ok ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }
}

// ─── Password Field ───────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.ctrl,
    required this.icon,
    required this.hint,
    required this.show,
    required this.onToggle,
  });

  final String label, hint;
  final TextEditingController ctrl;
  final IconData icon;
  final bool show;
  final VoidCallback onToggle;

  static const _cForestMid = Color(0xFF3D6B5F);
  static const _cSubtext   = Color(0xFF6B7280);
  static const _cInk       = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _cSubtext,
                  letterSpacing: 0.3)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            obscureText: !show,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: _cInk),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 13, color: Color(0xFFCBCBCB)),
              prefixIcon:
                  Icon(icon, color: _cForestMid, size: 18),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  show
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFFB0B7C3),
                  size: 18,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF3D6B5F), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─── Submit Button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF2D5A4E), Color(0xFF3D6B5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isLoading ? const Color(0xFFB0C4BC) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                      color: const Color(0xFF2D5A4E).withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5))
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_reset_outlined,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Perbarui Kata Sandi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.2)),
                  ],
                ),
        ),
      ),
    );
  }
}