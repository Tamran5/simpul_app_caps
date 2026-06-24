import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/article_model.dart';
import '../../../core/values/api_config.dart';

class BookmarkController extends GetxController {
  var bookmarkedArticles = <Article>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookmarks();
  }

  // Mengambil daftar artikel yang dibookmark
  void fetchBookmarks() async {
    try {
      isLoading(true);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // TEMBAK API MENGGUNAKAN API CONFIG
      var url = Uri.parse(ApiConfig.bookmarks); 
      
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var jsonResult = json.decode(response.body);
        var dataList = jsonResult['data'] as List;
        bookmarkedArticles.value = dataList.map((e) => Article.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat artikel tersimpan.');
    } finally {
      isLoading(false);
    }
  }

  // Fungsi untuk hit API Toggle Bookmark
  Future<void> toggleBookmark(int articleId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      // GABUNGKAN API CONFIG DENGAN ID ARTIKEL
      var url = Uri.parse('${ApiConfig.toggleBookmark}/$articleId'); 
      
      var response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        var result = json.decode(response.body);
        Get.snackbar('Bookmark', result['message'], snackPosition: SnackPosition.BOTTOM);
        
        // Refresh daftar bookmark jika sedang di halaman Bookmark
        fetchBookmarks(); 
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses bookmark');
    }
  }
}