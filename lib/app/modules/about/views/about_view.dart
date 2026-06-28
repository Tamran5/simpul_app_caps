import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/about_controller.dart';
import '../../legal_detail/views/legal_detail_view.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF87A092);
  static const Color bgPage = Color(0xFFFBFBFB);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AboutController>(
      init: AboutController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: bgPage,
          appBar: AppBar(
            title: const Text(
              'Tentang Simpul',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Get.back(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(controller),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Teman digital untuk merencanakan pernikahan '
                        'bersama pasangan, dari checklist hingga vendor, '
                        'dalam satu tempat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8A8A8A),
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionLabel('Informasi'),
                      const SizedBox(height: 8),
                      _buildList([
                        (
                          icon: Icons.description_outlined,
                          label: 'Syarat & ketentuan',
                          onTap: () => Get.to(
                            () => const LegalDetailView(
                              title: 'Syarat & ketentuan',
                              content: kTermsAndConditionsText,
                            ),
                          ),
                        ),
                        (
                          icon: Icons.privacy_tip_outlined,
                          label: 'Kebijakan privasi',
                          onTap: () => Get.to(
                            () => const LegalDetailView(
                              title: 'Kebijakan privasi',
                              content: kPrivacyPolicyText,
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Hubungi kami'),
                      const SizedBox(height: 8),
                      _buildList([
                        (
                          icon: Icons.mail_outline_rounded,
                          label: 'Kirim masukan via email',
                          onTap: controller.openSupportEmail,
                        ),
                      ]),
                      const SizedBox(height: 24),
                      const Text(
                        'Dibuat dengan cinta di Indonesia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB0B0B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AboutController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEFEFEF)),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.all_inclusive,
                color: primaryGreen,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Simpul',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: primaryGreen,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            if (controller.isLoadingVersion.value) {
              return const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: primaryGreen,
                ),
              );
            }
            return Text(
              'Versi ${controller.appVersion.value}',
              style: TextStyle(
                fontSize: 12,
                color: primaryGreen.withOpacity(0.8),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB0B0B0),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildList(
    List<({IconData icon, String label, VoidCallback onTap})> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(
          items.isEmpty ? 0 : items.length * 2 - 1,
          (i) {
            if (i.isOdd) {
              return const Divider(
                height: 1,
                color: Color(0xFFF2F2F2),
                indent: 12,
                endIndent: 12,
              );
            }
            final item = items[i ~/ 2];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 18, color: const Color(0xFF8A8A8A)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFFB0B0B0),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}