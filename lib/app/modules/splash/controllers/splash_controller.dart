import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart'; 

class SplashController extends GetxController {
  
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // 1. Berikan jeda waktu agar Splash Screen (logo simpul) terlihat jelas
    await Future.delayed(const Duration(seconds: 3)); 

    // 2. Buka penyimpanan lokal untuk mengambil data
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');
    
    // Mengecek apakah ini adalah momen pertama kali aplikasi dibuka seumur hidup
    // Jika data 'is_first_time' belum ada, kita anggap nilainya true (benar pertama kali)
    final bool isFirstTime = prefs.getBool('is_first_time') ?? true;

    // 3. Arahkan rute secara otomatis dan cerdas
    if (token != null && token.isNotEmpty) {
      // KONDISI A: User sudah login sebelumnya -> Langsung ke Beranda
      Get.offAllNamed(Routes.HOME); 
      
    } else if (isFirstTime) {
      // KONDISI B: User belum login DAN ini pertama kali buka aplikasi -> Ke Onboarding
      // Kita ubah statusnya menjadi false agar Onboarding tidak muncul lagi di masa depan
      await prefs.setBool('is_first_time', false);
      Get.offAllNamed(Routes.ONBOARDING); 
      
    } else {
      // KONDISI C: User belum/tidak login, TAPI sudah pernah melewati Onboarding -> Ke Login
      Get.offAllNamed(Routes.LOGIN); 
    }
  }
}