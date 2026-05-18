import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../splash/controllers/splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Memanggil controller agar logika penundaan waktu berjalan
    Get.put(SplashController());

    const Color primaryGreen = Color(0xFF87A092);
    const Color textDark = Color(0xFF333333);
    const Color bgColor = Color(0xFFFBFBFB);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 24),
            const Text(
              'Simpul',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: primaryGreen,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Menyimpul Janji, Memulai\nPerjalanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textDark,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}