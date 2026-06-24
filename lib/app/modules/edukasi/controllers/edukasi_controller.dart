import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/article_model.dart';
import '../../../core/values/api_config.dart'; 

class EdukasiController extends GetxController {
  var articles = <Article>[].obs;
  var isLoading = true.obs;
  
  // Variabel untuk state filter kategori
  var selectedCategory = 'Terbaru'.obs;
  // Daftar kategori disesuaikan dengan tombol filter horizontal
  final List<String> categories = ['Terbaru', 'Birokrasi', 'Keuangan', 'Konseling', 'Agama'];

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  void fetchArticles() async {
    try {
      isLoading(true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // TEMBAK API MENGGUNAKAN API CONFIG
      var url = Uri.parse(ApiConfig.articles); 
      
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Membawa tiket masuk (JWT)
      });

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        var dataList = jsonResult['data'] as List;
        articles.value = dataList.map((e) => Article.fromJson(e)).toList();
      } else {
        Get.snackbar('Gagal', 'Tidak dapat memuat artikel.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan jaringan.');
    } finally {
      isLoading(false);
    }
  }

  // Getter untuk filter artikel berdasarkan Chips yang dipilih
  List<Article> get filteredArticles {
    if (selectedCategory.value == 'Terbaru') {
      return articles;
    }
    return articles.where((article) => article.kategori.toLowerCase() == selectedCategory.value.toLowerCase()).toList();
  }

  // Getter Artikel Utama (Featured Article yang menonjol di atas)
  Article? get featuredArticle {
    var list = filteredArticles;
    return list.isNotEmpty ? list.first : null;
  }

  // Getter Artikel Reguler (List vertikal ringkas di bawahnya)
  List<Article> get otherArticles {
    var list = filteredArticles;
    return list.length > 1 ? list.sublist(1) : [];
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }
}