// Isi file api_config.dart
class ApiConfig {
  // CUKUP UBAH IP DI SINI SAJA JIKA GANTI WI-FI
  static const String baseUrl = "http://192.168.18.6:5000/api";
  
  // Kamu juga bisa menambahkan endpoint spesifik di sini agar lebih rapi
  static const String login = "$baseUrl/auth/login";
  static const String googleLogin = "$baseUrl/auth/google-login";
  static const String register = "$baseUrl/auth/register";
  static const String bookmarks = "$baseUrl/mobile/bookmarks"; 
  static const String toggleBookmark = "$baseUrl/mobile/bookmarks/toggle";
  static const String articles = "$baseUrl/mobile/articles";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String updateProfile = "$baseUrl/auth/update-profile";
  static const String profile = "$baseUrl/auth/profile"; 
  static const String connectPartner = "$baseUrl/auth/connect-partner"; 
  static const String respondPartner = "$baseUrl/auth/respond-partner";
}