import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqView extends GetView {
  const FaqView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);

  @override
  Widget build(BuildContext context) {
    // Data Dummy FAQ sesuai kebutuhan aplikasi pernikahan Simpul
    final List<Map<String, String>> faqData = [
      {
        'tanya': 'Bagaimana cara mengundang pasangan saya?',
        'jawab': 'Kamu dapat pergi ke halaman Profil, lalu klik tombol "Hubungkan Pasangan" dan masukkan email atau kode unik pasangan Kamu untuk sinkronisasi data.'
      },
      {
        'tanya': 'Apakah data checklist To-Do otomatis sinkron?',
        'jawab': 'Ya, setiap tugas checklist pernikahan yang Kamu atau pasangan Kamu perbarui akan langsung tersinkronisasi secara real-time di kedua perangkat.'
      },
      {
        'tanya': 'Bagaimana cara menghubungi vendor yang terdaftar?',
        'jawab': 'Buka menu Vendor, pilih vendor yang Kamu inginkan, lalu klik tombol "Hubungi Vendor" di bagian bawah halaman detail untuk terhubung via WhatsApp.'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text('Pusat Bantuan (FAQ)', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: primaryGreen,
                textColor: primaryGreen,
                title: Text(
                  faqData[index]['tanya']!,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                      faqData[index]['jawab']!,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}