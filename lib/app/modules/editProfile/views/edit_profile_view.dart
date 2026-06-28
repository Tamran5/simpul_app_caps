import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

  static const _cBg      = Color(0xFFF5F6F5);
  static const _cSurface = Colors.white;
  static const _cInk     = Color(0xFF111827);
  static const _cBorder  = Color(0xFFEEEEEE);

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
        title: const Text(
          'Edit Profil',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _cInk,
              letterSpacing: -0.2),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AvatarSection(controller: controller),
            const SizedBox(height: 28),

            _SectionLabel('INFORMASI DASAR'),
            const SizedBox(height: 10),
            _FormCard(children: [
              _FormField(
                label: 'Nama Lengkap',
                ctrl: controller.nameController,
                icon: Icons.person_outline_rounded,
                hint: 'Masukkan nama lengkap',
              ),
              _Divider(),
              _FormField(
                label: 'Nomor Telepon',
                ctrl: controller.phoneController,
                icon: Icons.phone_android_outlined,
                hint: '08xx-xxxx-xxxx',
                kbdType: TextInputType.phone,
              ),
            ]),
            const SizedBox(height: 20),

            _SectionLabel('ALAMAT EMAIL'),
            const SizedBox(height: 10),

            // ── Email Section (inline Obx, tidak pakai class terpisah) ──
            Obx(() {
              final isChanging = controller.isChangingEmail.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormCard(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Email Terdaftar',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B7280),
                                letterSpacing: 0.3),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.isChangingEmail.value = !isChanging;
                              if (isChanging) {
                                controller.newEmailController.clear();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isChanging
                                    ? const Color(0xFFFEF2F2)
                                    : const Color(0xFFEBF2F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isChanging ? 'Batal' : 'Ubah',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isChanging
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF3D6B5F)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _FormField(
                      label: '',
                      ctrl: controller.emailController,
                      icon: Icons.email_outlined,
                      hint: '',
                      enabled: false,
                      showLabel: false,
                    ),
                  ]),

                  if (isChanging) ...[
                    const SizedBox(height: 12),
                    _FormCard(children: [
                      _FormField(
                        label: 'Email Baru',
                        ctrl: controller.newEmailController,
                        icon: Icons.mark_email_unread_outlined,
                        hint: 'nama@email.com',
                        kbdType: TextInputType.emailAddress,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFC8A96A).withOpacity(0.3),
                            width: 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.info_outline_rounded,
                              color: Color(0xFFC8A96A), size: 16),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Kode verifikasi akan dikirim ke email terdaftar saat ini sebelum perubahan disimpan.',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF966C23),
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),

            const SizedBox(height: 32),

            Obx(() => _SaveButton(
                  isLoading: controller.isLoading.value,
                  onTap: controller.simpanPerubahan,
                )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar Section ───────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.controller});
  final EditProfileController controller;

  static const _cForestMid = Color(0xFF3D6B5F);
  static const _cFog       = Color(0xFFEBF2F0);
  static const _cSubtext   = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: controller.pickAndUploadPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Obx(() {
                  final url = controller.previewPhotoUrl.value;
                  return Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _cForestMid, width: 2.5),
                      color: _cFog,
                    ),
                    child: ClipOval(
                      child: url.isNotEmpty
                          ? Image.network(url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _InitialAvatar(
                                  name: controller.nameController.text))
                          : _InitialAvatar(
                              name: controller.nameController.text),
                    ),
                  );
                }),
                Obx(() => controller.isUploadingPhoto.value
                    ? Positioned.fill(
                        child: ClipOval(
                          child: Container(
                            color: Colors.black38,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _cForestMid,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('Ketuk foto untuk mengubah',
              style: TextStyle(fontSize: 12, color: _cSubtext)),
          const SizedBox(height: 4),
          const Text('JPG atau PNG, maksimal 5 MB',
              style: TextStyle(fontSize: 11, color: Color(0xFFB0B7C3))),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.name});
  final String name;

  static const _cForestMid = Color(0xFF3D6B5F);

  String get _initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEBF2F0),
      child: Center(
        child: Text(_initials,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _cForestMid)),
      ),
    );
  }
}

// ─── Reusable Components ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
              letterSpacing: 1.5)),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});
  final List<Widget> children;

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
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, indent: 16, endIndent: 16, color: Color(0xFFF0F0F0));
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.ctrl,
    required this.icon,
    required this.hint,
    this.kbdType = TextInputType.text,
    this.enabled = true,
    this.showLabel = true,
  });

  final String label, hint;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType kbdType;
  final bool enabled;
  final bool showLabel;

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
          if (showLabel && label.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _cSubtext,
                    letterSpacing: 0.3)),
            const SizedBox(height: 6),
          ] else
            const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            keyboardType: kbdType,
            enabled: enabled,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: enabled ? _cInk : _cSubtext),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 13, color: Color(0xFFCBCBCB)),
              prefixIcon: Icon(icon,
                  color: enabled ? _cForestMid : const Color(0xFFCCCCCC),
                  size: 18),
              filled: true,
              fillColor: enabled ? Colors.white : const Color(0xFFF9F9F9),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              disabledBorder: OutlineInputBorder(
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isLoading, required this.onTap});
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
                    Icon(Icons.check_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Simpan Perubahan',
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