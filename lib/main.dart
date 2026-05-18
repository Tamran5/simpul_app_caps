import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/splash/views/splash_view.dart';
import 'app/modules/onboarding/views/onboarding_view.dart';
import 'dart:ui';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Simpul App',
      debugShowCheckedModeBanner: false, // Menghilangkan pita debug
      initialRoute: '/splash',

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse, // Mengizinkan mouse
          PointerDeviceKind.touch, // Mengizinkan sentuhan jari (di HP)
        },
      ),

      getPages: [
        GetPage(name: '/splash', page: () => const SplashView()), 
        GetPage(name: '/onboarding', page: () => const OnboardingView()),
      ],
    );
  }
}
