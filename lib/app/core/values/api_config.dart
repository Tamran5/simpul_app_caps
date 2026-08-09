class ApiConfig {
  // static const String rootUrl = "https://toxophilitic-carin-typographically.ngrok-free.dev";
  static const String rootUrl = "https://web-simpul.vercel.app";
  static const String baseUrl = "$rootUrl/api";
  // static const String baseUrl = "http://192.168.18.6:5000/api";

  // ─── Auth ──────────────────────────────────────────────────────────
  static const String login = "$baseUrl/auth/login";
  static const String googleLogin = "$baseUrl/auth/google-login";
  static const String register = "$baseUrl/auth/register";
  static const String verifyRegisterOtp = "$baseUrl/auth/verify-register-otp";
  static const String resendRegisterOtp = "$baseUrl/auth/resend-register-otp";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String logout = "$baseUrl/auth/logout";

  // ─── Profile ───────────────────────────────────────────────────────
  static const String profile = "$baseUrl/profile";
  static const String updateProfile = "$baseUrl/profile/update";
  static const String profilePhoto = "$baseUrl/profile/photo";
  static const String changePassword = "$baseUrl/profile/password";

  // ─── Pair / Sync ───────────────────────────────────────────────────
  static const String pairStatus = "$baseUrl/pair/status";
  static const String pairRequest = "$baseUrl/pair/request";
  static const String pairRespond = "$baseUrl/pair/respond";
  static const String pairUnlink = "$baseUrl/pair/unlink";

  // ─── Wedding ───────────────────────────────────────────────────────
  static const String weddingDate = "$baseUrl/wedding-date";

  // ─── Home ──────────────────────────────────────────────────────────
  static const String homeData = "$baseUrl/home";

  // ─── Notifications ─────────────────────────────────────────────────
  static const String notifList = "$baseUrl/notifications";
  static const String notifUnreadCount = "$baseUrl/notifications/unread-count";
  static const String notifMarkAllRead = "$baseUrl/notifications/read-all";
  static String notifMarkRead(String id) => "$baseUrl/notifications/$id/read";

  // ─── Articles / Edukasi ────────────────────────────────────────────
  static const String articles = "$baseUrl/articles";
  static const String bookmarks = "$baseUrl/articles/bookmarks";
  // BUG FIX 4: toggleBookmark harus berupa fungsi karena butuh article ID
  static String toggleBookmark(String articleId) =>
      "$baseUrl/articles/$articleId/bookmark";

  // ─── Vendors ───────────────────────────────────────────────────────
  static const String vendors = "$baseUrl/vendors";
  static const String favoriteVendors = "$baseUrl/vendors/favorites";

  // ─── Face Recognition ──────────────────────────────────────────────
  static const String faceLogin = '$baseUrl/face/login';
  static const String faceRegister = "$baseUrl/face/register";
  static const String faceUpdate = "$baseUrl/face/update";

  // ─── Journey / Legal Roadmap ───────────────────────────────────────
  static const String journeyList = "$baseUrl/journey";
  static const String journeyPartner = "$baseUrl/journey/partner";
  static String journeyToggle(String stepKey) =>
      "$baseUrl/journey/$stepKey/toggle";
  static String journeyUpload(String stepKey) =>
      "$baseUrl/journey/$stepKey/upload";
  static String journeyInfo(String stepKey) => "$baseUrl/journey/$stepKey/info";

  static String resolvePhotoUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('http')) return rawUrl;
    return '$rootUrl$rawUrl';   // pakai rootUrl, BUKAN baseUrl
  }

  static String journeyDocument(String stepKey) =>
    "$baseUrl/journey/$stepKey/document";
}