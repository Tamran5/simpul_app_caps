// views/connect_partner_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connect_partner_controller.dart';

class ConnectPartnerView extends GetView<ConnectPartnerController> {
  const ConnectPartnerView({Key? key}) : super(key: key);

  // ── Design tokens (sama dengan HomeView) ─────────────────────────────────
  static const _cForest    = Color(0xFF2D5A4E);
  static const _cForestMid = Color(0xFF3D6B5F);
  static const _cFog       = Color(0xFFEBF2F0);
  static const _cGold      = Color(0xFFC8A96A);
  static const _cBg        = Color(0xFFF5F6F5);
  static const _cSurface   = Colors.white;
  static const _cInk       = Color(0xFF111827);
  static const _cSubtext   = Color(0xFF6B7280);
  static const _cBorder    = Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildMyCodeCard(),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildPartnerInputCard(),
              const SizedBox(height: 36),
              _buildConnectButton(),
              const SizedBox(height: 14),
              _buildSkipButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: _cFog,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite_rounded, color: _cForestMid, size: 34),
        ),
        const SizedBox(height: 20),
        const Text(
          'Satu Langkah Lagi!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _cInk,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Bagikan kode unikmu kepada pasangan,\natau masukkan kode mereka untuk mulai merencanakan bersama.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: _cSubtext, height: 1.6),
        ),
      ],
    );
  }

  // ── Kartu Kode Unik Saya ─────────────────────────────────────────────────

  Widget _buildMyCodeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cFog, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D6B5F).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'KODE UNIK KAMU',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _cSubtext,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final code = controller.myCode.value;

            // Loading state — kode belum tersedia dari server
            if (code.isEmpty) {
              return const SizedBox(
                height: 36,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: _cForestMid,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _cForestMid,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: controller.salinKode,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _cFog,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: _cForestMid,
                      size: 18,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 10),
          const Text(
            'Kirim kode ini ke pasanganmu via WhatsApp atau pesan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: _cSubtext, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── Pemisah ───────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'atau masukkan kode pasanganmu',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  // ── Kartu Input Kode Pasangan ─────────────────────────────────────────────

  Widget _buildPartnerInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KODE PASANGANMU',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _cSubtext,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.partnerCodeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
              color: _cInk,
            ),
            decoration: InputDecoration(
              hintText: '- - - - - -',
              hintStyle: TextStyle(
                letterSpacing: 5,
                color: Colors.grey.shade300,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              counterText: '',
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.favorite_rounded, color: _cGold, size: 22),
              ),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _cBorder, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _cForestMid, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tombol Hubungkan ──────────────────────────────────────────────────────

  Widget _buildConnectButton() {
    return Obx(() => SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.prosesHubungkan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _cForestMid,
          disabledBackgroundColor: _cForestMid.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Hubungkan Akun Pasangan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
      ),
    ));
  }

  // ── Tombol Lewati ─────────────────────────────────────────────────────────

  Widget _buildSkipButton() {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: controller.lewatiSementara,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _cBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Lewati, Masuk ke Beranda',
          style: TextStyle(
            color: _cSubtext,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}