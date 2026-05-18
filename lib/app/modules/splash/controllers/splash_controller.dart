import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Menunggu selama 3 detik
    await Future.delayed(const Duration(seconds: 3));
    
    // Berpindah ke halaman Home dan menghapus Splash Screen dari riwayat (tidak bisa di-back)
    Get.offAllNamed('/onboarding'); 
  }
}