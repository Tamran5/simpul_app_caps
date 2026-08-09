import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/api_config.dart';

class SplashController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Jeda agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 3));

    final prefs      = await SharedPreferences.getInstance();
    final String? token    = prefs.getString('access_token');
    final bool isFirstTime = prefs.getBool('is_first_time') ?? true;

    // ── Tidak ada token → tidak perlu ke server ────────────────────
    if (token == null || token.isEmpty) {
      if (isFirstTime) {
        await prefs.setBool('is_first_time', false);
        Get.offAllNamed(Routes.ONBOARDING);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
      return;
    }

    // ── Ada token → validasi ke server dulu ───────────────────────
    // Jika token expired/invalid, server akan balas 401
    // Jika server tidak bisa diakses, amannya ke login
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.homeData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Token masih valid → lanjut ke home
        Get.offAllNamed(Routes.HOME);
      } else {
        // 401 expired, 403 banned, dll → hapus token & ke login
        await _clearTokens(prefs);
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (_) {
      // Tidak ada koneksi atau timeout → ke login untuk keamanan
      // Token TIDAK dihapus supaya bisa login ulang saat online kembali
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _clearTokens(SharedPreferences prefs) async {
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}