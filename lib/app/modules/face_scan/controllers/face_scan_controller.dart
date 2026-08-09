// controllers/face_scan_controller.dart

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/face_recognition_service.dart';
import '../../../services/face_embedding_service.dart';

class FaceScanController extends GetxController {
  var scanStep = 0.obs;
  var instructionText = "Arahkan wajah Anda ke dalam bingkai".obs;
  var scanProgress = 0.0.obs;
  var isCameraReady = false.obs;
  var isModelReady = false.obs;   // status load model TFLite
  var showLoginOption = false.obs;

  CameraController? cameraController;

  // ── Error yang bisa dicoba ulang (ringan/user-fixable) ────────────────────
  // Error di luar daftar ini dianggap fatal → redirect login (mode login)
  // Catatan: pesan "Wajah tidak terdeteksi" & "Lebih dari satu wajah terdeteksi"
  // sekarang datang dari FaceEmbeddingService (proses on-device), bukan lagi
  // dari respons server.
  static const _retryableErrors = {
    'Wajah tidak cocok. Silakan coba lagi.',
    'Gambar tidak valid. Pastikan pencahayaan cukup.',
    'Kamera belum siap. Tunggu sebentar lalu coba lagi.',
    'Kamera sedang sibuk. Silakan coba lagi.',
    'Gagal mengambil gambar kamera.',
    'Gagal mengambil gambar. Pastikan kamera tidak digunakan aplikasi lain.',
    'Wajah tidak terdeteksi. Pastikan wajah terlihat jelas.',
    'Lebih dari satu wajah terdeteksi.',
  };

  @override
  void onInit() {
    super.onInit();
    _initCamera();
    _initModel();
  }

  /// Load model TFLite di awal (sekali saja per lifecycle controller).
  /// Dilakukan paralel dengan init kamera supaya user tidak menunggu 2x.
  Future<void> _initModel() async {
    try {
      await FaceEmbeddingService.init();
      isModelReady.value = true;
    } catch (e) {
      _handleError("Gagal memuat model pengenalan wajah. Restart aplikasi.");
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _handleError("Kamera tidak ditemukan di perangkat ini.");
        return;
      }

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras[0],
      );

      cameraController = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();
      await Future.delayed(const Duration(milliseconds: 500));

      isCameraReady.value = true;
      update();
    } catch (e) {
      _handleError("Gagal membuka kamera: ${e.toString()}");
    }
  }

  Future<void> startScanning() async {
    if (!isCameraReady.value ||
        cameraController == null ||
        !cameraController!.value.isInitialized) {
      _handleError("Kamera belum siap. Tunggu sebentar lalu coba lagi.");
      return;
    }

    if (!isModelReady.value) {
      _handleError("Model pengenalan wajah belum siap. Tunggu sebentar lalu coba lagi.");
      return;
    }

    scanStep.value = 1;
    instructionText.value = "Hadap lurus ke depan...";

    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 150));
      scanProgress.value = i / 100;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    XFile? photo;
    try {
      if (!cameraController!.value.isInitialized ||
          cameraController!.value.isTakingPicture) {
        _handleError("Kamera sedang sibuk. Silakan coba lagi.");
        return;
      }
      photo = await cameraController!.takePicture();
    } catch (e) {
      _handleError(
        "Gagal mengambil gambar. Pastikan kamera tidak digunakan aplikasi lain.",
      );
      return;
    }

    if (photo == null) {
      _handleError("Gagal mengambil gambar kamera.");
      return;
    }

    final imageFile = File(photo.path);
    final fileSize = await imageFile.length();

    if (fileSize < 5000) {
      if (await imageFile.exists()) await imageFile.delete();
      _handleError("Gambar tidak valid. Pastikan pencahayaan cukup.");
      return;
    }

    // Label langkah diperbarui: deteksi + ekstraksi embedding kini terjadi
    // di perangkat (on-device), sebelum data dikirim ke server.
    scanStep.value = 2;
    instructionText.value = "Memproses data wajah di perangkat...";

    final args = Get.arguments as Map<String, dynamic>?;
    final mode = args?['mode'] ?? 'register';

    Map<String, dynamic> result;

    try {
      if (mode == 'update') {
        result = await FaceRecognitionService.updateFace(imageFile: imageFile);
      } else if (mode == 'login') {
        result = await FaceRecognitionService.loginFace(imageFile: imageFile);
      } else {
        result = await FaceRecognitionService.registerFace(
          imageFile: imageFile,
        );
      }
    } catch (e) {
      if (await imageFile.exists()) await imageFile.delete();
      _handleError("Koneksi ke server gagal. Periksa jaringan Anda.");
      return;
    }

    if (await imageFile.exists()) await imageFile.delete();

    if (result['success'] == true) {
      _handleSuccess(mode: mode);
    } else {
      // Pesan bisa berasal dari FaceEmbeddingService (deteksi wajah gagal,
      // di-throw sebagai Exception lalu ditangkap di FaceRecognitionService)
      // maupun dari respons server (wajah tidak dikenali, dsb).
      _handleError(result['message'] ?? 'Terjadi kesalahan pada server.');
    }
  }

  void _handleSuccess({required String mode}) {
    showLoginOption.value = false;

    scanStep.value = 3;
    instructionText.value = "Pemindaian Selesai!";

    final args = Get.arguments as Map<String, dynamic>?;
    final origin = args?['origin'] ?? 'onboarding';

    Future.delayed(const Duration(seconds: 1), () {
      if (mode == 'register') {
        if (origin == 'settings') {
          Get.back(result: true);
          _showSnackbar('Berhasil', 'Wajah berhasil didaftarkan.');
        } else {
          Get.offAllNamed('/connect-partner');
          _showSnackbar(
            'Selamat Datang!',
            'Wajah berhasil didaftarkan. Akun Anda siap digunakan.',
          );
        }
      } else if (mode == 'login') {
        Get.offAllNamed('/home');
        _showSnackbar('Login Berhasil', 'Selamat datang kembali!');
      } else if (mode == 'update') {
        Get.back(result: true);
        _showSnackbar('Berhasil', 'Data wajah berhasil diperbarui.');
      }
    });
  }

  void _handleError(String message) {
    scanStep.value = 4;
    instructionText.value = message;
    _showSnackbar('Gagal', message, isError: true);

    final args = Get.arguments as Map<String, dynamic>?;
    final mode = args?['mode'] ?? 'register';

    final bool canRetry = _retryableErrors.contains(message);

    if (canRetry) {
      showLoginOption.value = false;
      Future.delayed(const Duration(seconds: 2), () => resetScan());
      return;
    }

    if (mode == 'login') {
      showLoginOption.value = true;
    } else {
      showLoginOption.value = false;
      Future.delayed(const Duration(seconds: 2), () => resetScan());
    }
  }

  Future<void> goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    Get.offAllNamed('/login');
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red : const Color(0xFF596E63),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }

  void resetScan() {
    scanStep.value = 0;
    scanProgress.value = 0.0;
    showLoginOption.value = false;
    instructionText.value = "Arahkan wajah Anda ke dalam bingkai";
  }

  @override
  void onClose() {
    cameraController?.dispose();
    // Model TFLite TIDAK di-dispose di sini karena bersifat singleton
    // (di-share lintas layar). Dispose hanya dilakukan saat app benar-benar
    // ditutup, misal lewat FaceEmbeddingService.dispose() di app lifecycle.
    super.onClose();
  }
}