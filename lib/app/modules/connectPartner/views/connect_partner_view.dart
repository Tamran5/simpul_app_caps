import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connect_partner_controller.dart';

class ConnectPartnerView extends GetView<ConnectPartnerController> {
  const ConnectPartnerView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Ikon Hati / Kemitraan
              const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  color: primaryGreen,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Satu Langkah Lagi!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bagikan kode unik Kamu atau masukkan kode pasangan Kamu untuk mulai merencanakan pernikahan bersama.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textGrey, height: 1.5),
              ),
              const SizedBox(height: 40),

              // KARTU 1: Bagikan Kode Sendiri
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Column(
                  children: [
                    const Text('KODE UNIK KAMU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textGrey, letterSpacing: 1.1)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => Text(
                              controller.myCode.value,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen, letterSpacing: 1.5),
                            )),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: textGrey, size: 20),
                          onPressed: () => controller.salinKode(),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // KARTU 2: Input Kode Pasangan
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MASUKKAN KODE PASANGAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textGrey, letterSpacing: 1.1)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.partnerCodeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Contoh: SMPL-XXXX',
                        hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
                        prefixIcon: const Icon(Icons.link_rounded, color: primaryGreen),
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryGreen),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // TOMBOL EKSEKUSI
              ElevatedButton(
                onPressed: () => controller.prosesHubungkan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Hubungkan Akun Pasangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const SizedBox(height: 16),
              
              // TOMBOL LEWATI SEMENTARA
              OutlinedButton(
                onPressed: () => controller.lewatiSementara(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE8E8E8)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lewati, Masuk ke Beranda', style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}