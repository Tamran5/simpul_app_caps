import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  var currentIndex = 0.obs;
  var pageController = PageController();

  // Data Slide (Bisa Anda tambah sesuai kebutuhan)
  List<Map<String, String>> onboardingData = [
    {
      "title": "Atur Segalanya Bersama",
      "subtitle":
          "Kolaborasi mudah dengan pasangan dan tim dalam satu platform yang tenang.",
      "image": "assets/images/slide1.jpg" // URL Baru
    },
    {
      "title": "Mulai Perjalanan",
      "subtitle":
          "Wujudkan rencana impian Anda dengan langkah yang lebih terorganisir.",
      "image": "assets/images/slide2.jpg" // URL Baru
    },
  ];

  void nextPath() {
    if (currentIndex.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Jika slide terakhir, pergi ke Home
      Get.offAllNamed('/register');
    }
  }
}