class ApiConfig {
  
  static const String baseUrl = "http://192.168.18.6:5000/api";

  
  static const String login = "$baseUrl/auth/login";
  static const String googleLogin = "$baseUrl/auth/google-login";
  static const String register = "$baseUrl/auth/register";
  static const String bookmarks = "$baseUrl/articles/bookmarks";
  static const String toggleBookmark = "$baseUrl/articles";
  static const String articles = "$baseUrl/articles";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String updateProfile = "$baseUrl/profile/update";
  static const String profile = "$baseUrl/profile";
  static const String vendors = "$baseUrl/vendors";
  static const String favoriteVendors = "$baseUrl/vendors/favorites";
  static const String connectPartner = "$baseUrl/auth/connect-partner";
  static const String respondPartner = "$baseUrl/auth/respond-partner";
  static const String pairStatus = "$baseUrl/pair/status";
  static const String pairRequest = "$baseUrl/pair/request";
  static const String pairRespond = "$baseUrl/pair/respond";
  static const String weddingDate = "$baseUrl/wedding-date";
  static const String homeData = "$baseUrl/home";
  static const String notifList = "$baseUrl/notifications";
  static const String notifUnreadCount = "$baseUrl/notifications/unread-count";
  static const String notifMarkAllRead = "$baseUrl/notifications/read-all";
  static const String notifMarkRead = "$baseUrl/notifications";
  static const String profilePhoto = "$baseUrl/profile/photo";
  static const String changePassword = "$baseUrl/profile/password";

  
  static const String journeyList = "$baseUrl/journey";
  static String journeyToggle(String stepKey) => "$baseUrl/journey/$stepKey/toggle";
  static String journeyUpload(String stepKey) => "$baseUrl/journey/$stepKey/upload";
  static String journeyInfo(String stepKey) => "$baseUrl/journey/$stepKey/info";
  static const String journeyPartner = "$baseUrl/journey/partner";
}