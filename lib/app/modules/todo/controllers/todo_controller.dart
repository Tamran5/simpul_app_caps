import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JourneyStep {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String description;
  final List<String> requirements;
  
  final bool requiresDocument;
  final String targetInstitution; 
  RxString uploadedFileName;
  RxString documentStatus; 

  RxBool isDone;

  JourneyStep({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.requirements,
    this.requiresDocument = false,
    this.targetInstitution = '',
    String fileName = '',
    String status = 'empty',
    bool done = false,
  })  : isDone = done.obs,
        uploadedFileName = fileName.obs,
        documentStatus = status.obs;
}

class TodoController extends GetxController {
  var journeySteps = <JourneyStep>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadJourney();
  }

  void _loadJourney() {
    journeySteps.addAll([
      JourneyStep(
        id: '1',
        category: 'Legal',
        title: 'N1 - N4 Documents',
        subtitle: 'Pengurusan surat pengantar nikah RT/RW hingga Kelurahan.',
        description: 'Pastikan Anda telah meminta surat pengantar dari RT/RW setempat.',
        requirements: ['Surat Pengantar RT/RW', 'Fotokopi KTP & KK', 'Pas Foto 3x4 (4 lembar)'],
        requiresDocument: true,
        targetInstitution: 'Kelurahan & Disdukcapil',
        done: false,
      ),
      JourneyStep(
        id: '2',
        category: 'Religius',
        title: 'Pendaftaran KUA',
        subtitle: 'Mendaftarkan jadwal akad nikah dan menyerahkan berkas.',
        description: 'Bawa seluruh berkas N1-N4 yang telah dilegalisir ke KUA kecamatan tempat akad berlangsung.',
        requirements: ['Berkas N1-N4 Lengkap', 'Sertifikat Suscatin', 'Fotokopi KTP Saksi'],
        requiresDocument: true,
        targetInstitution: 'KUA',
        fileName: 'Berkas_N1_N4_RezaSari.pdf',
        status: 'uploaded', // Sudah diunggah
        done: true,
      ),
      JourneyStep(
        id: '3',
        category: 'Religius',
        title: 'Suscatin',
        subtitle: 'Kursus Calon Pengantin untuk pembekalan pernikahan.',
        description: 'Program pembekalan wajib dari Kementerian Agama.',
        requirements: ['Fotokopi KTP', 'Fotokopi KK'],
        done: false,
      ),
      JourneyStep(
        id: '4',
        category: 'Resepsi',
        title: 'Booking Gedung',
        subtitle: 'Finalisasi DP dan pemilihan vendor dekorasi gedung.',
        description: 'Melakukan pembayaran Down Payment (DP) untuk mengunci tanggal.',
        requirements: ['Kuitansi DP Vendor', 'Kontrak Sewa'],
        requiresDocument: true,
        targetInstitution: 'Vendor Management',
        done: false,
      ),
    ]);
  }

  void toggleStep(JourneyStep step) {
    step.isDone.value = !step.isDone.value;
  }

  // Fungsi Simulasi Unggah Dokumen untuk Konsep Proyek
  void uploadDocument(JourneyStep step) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF596E63))),
      barrierDismissible: false,
    );

    // Simulasi proses unggah file secara lokal (1.5 detik)
    await Future.delayed(const Duration(milliseconds: 1500));
    Get.back(); 

    step.uploadedFileName.value = 'Dokumen_Syarat_${step.title.replaceAll(" ", "_")}.pdf';
    step.documentStatus.value = 'uploaded'; // Diubah jadi "uploaded" bukan verified
    step.isDone.value = true; // Centang otomatis karena tugas di aplikasi sudah selesai
    
    // Snackbar yang menjelaskan visi proyek akhir
    Get.snackbar(
      'Dokumen Tersimpan Lokal',
      'Pada tahap pengembangan selanjutnya, sistem dirancang agar dapat disinkronkan langsung melalui API ${step.targetInstitution}.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE8F0EE),
      colorText: const Color(0xFF3D6B5F),
      icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3D6B5F)),
      duration: const Duration(seconds: 4), // Diberi waktu lebih lama agar bisa dibaca saat presentasi
      margin: const EdgeInsets.all(16),
    );
  }

  void showStepInfo(JourneyStep step) {
    Get.snackbar(
      'Informasi',
      step.description,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF596E63),
      colorText: const Color(0xFFFFFFFF),
    );
  }
}