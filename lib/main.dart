import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/routes/app_pages.dart';
import 'app/services/face_embedding_service.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  _preloadFaceModel();

  // Langsung jalankan aplikasi tanpa cek token di sini
  runApp(const MyApp());
}

void _preloadFaceModel() {
  FaceEmbeddingService.init().catchError((e) {
    // Gagal preload bukan fatal untuk keseluruhan app — FaceScanController
    // akan mencoba lagi lewat init()-nya sendiri saat halaman scan dibuka.
    debugPrint('Gagal preload model face recognition: $e');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Simpul App',
      debugShowCheckedModeBanner: false,

      // SELALU mulai dari Splash Screen
      initialRoute: AppPages.INITIAL,

      getPages: AppPages.routes,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
    );
  }
}