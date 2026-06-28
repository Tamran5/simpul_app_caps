import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqController extends GetxController {
  // Ganti dengan nomor WhatsApp resmi tim support Simpul.
  // Format internasional tanpa "+", "0" di awal, atau spasi/strip.
  // Contoh: 081234567890 -> 6281234567890
  static const String _supportWhatsappNumber = '6281234567890';
  static const String _supportDefaultMessage =
      'Halo tim Simpul, saya butuh bantuan terkait aplikasi.';

  String searchQuery = '';
  String selectedCategory = 'Semua';

  final List<String> categories = ['Semua', 'Pasangan', 'Checklist', 'Vendor'];

  final List<FaqItem> _allFaq = [
    FaqItem(
      tanya: 'Bagaimana cara mengundang pasangan saya?',
      jawab:
          'Kamu dapat pergi ke halaman Profil, lalu klik tombol "Hubungkan Pasangan" dan masukkan email atau kode unik pasangan Kamu untuk sinkronisasi data.',
      category: 'Pasangan',
      icon: Icons.favorite_border_rounded,
      color: const Color(0xFFD85A30),
    ),
    FaqItem(
      tanya: 'Apakah data checklist To-Do otomatis sinkron?',
      jawab:
          'Ya, setiap tugas checklist pernikahan yang Kamu atau pasangan Kamu perbarui akan langsung tersinkronisasi secara real-time di kedua perangkat.',
      category: 'Checklist',
      icon: Icons.sync_rounded,
      color: const Color(0xFF1D9E75),
    ),
    FaqItem(
      tanya: 'Bagaimana cara menghubungi vendor yang terdaftar?',
      jawab:
          'Buka menu Vendor, pilih vendor yang Kamu inginkan, lalu klik tombol "Hubungi Vendor" di bagian bawah halaman detail untuk terhubung via WhatsApp.',
      category: 'Vendor',
      icon: Icons.storefront_outlined,
      color: const Color(0xFF378ADD),
    ),
  ];

  void updateSearch(String value) {
    searchQuery = value;
    update();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    update();
  }

  List<FaqCategoryGroup> get filteredGroups {
    final query = searchQuery.trim().toLowerCase();

    final filtered = _allFaq.where((item) {
      final matchesCategory =
          selectedCategory == 'Semua' || item.category == selectedCategory;
      final matchesSearch = query.isEmpty ||
          item.tanya.toLowerCase().contains(query) ||
          item.jawab.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    final Map<String, List<FaqItem>> grouped = {};
    for (final item in filtered) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return grouped.entries
        .map((e) => FaqCategoryGroup(category: e.key, items: e.value))
        .toList();
  }

  /// Membuka WhatsApp menuju nomor tim support dengan pesan default.
  /// Mencoba scheme "whatsapp://" dulu (langsung buka app),
  /// fallback ke "wa.me" (bekerja di web/browser maupun saat app tidak terpasang).
  Future<void> contactSupportViaWhatsapp({String? message}) async {
    final text = Uri.encodeComponent(message ?? _supportDefaultMessage);

    final waAppUri = Uri.parse(
      'whatsapp://send?phone=$_supportWhatsappNumber&text=$text',
    );
    final waWebUri = Uri.parse(
      'https://wa.me/$_supportWhatsappNumber?text=$text',
    );

    try {
      final canOpenApp = await canLaunchUrl(waAppUri);
      if (canOpenApp) {
        await launchUrl(waAppUri);
        return;
      }
      await launchUrl(waWebUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        'Gagal membuka WhatsApp',
        'Pastikan WhatsApp terpasang di perangkat kamu atau coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// ===================== MODEL =====================

class FaqItem {
  final String tanya;
  final String jawab;
  final String category;
  final IconData icon;
  final Color color;

  FaqItem({
    required this.tanya,
    required this.jawab,
    required this.category,
    required this.icon,
    required this.color,
  });
}

class FaqCategoryGroup {
  final String category;
  final List<FaqItem> items;

  FaqCategoryGroup({required this.category, required this.items});
}