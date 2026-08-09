import 'package:get/get.dart';

import '../../data/models/article_model.dart';
import '../modules/RegisterOtp/bindings/register_otp_binding.dart';
import '../modules/RegisterOtp/views/register_otp_view.dart';
import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/article_detail/bindings/article_detail_binding.dart';
import '../modules/article_detail/views/article_detail_view.dart';
import '../modules/bookmark/bindings/bookmark_binding.dart';
import '../modules/bookmark/views/bookmark_view.dart';
import '../modules/changepassword/bindings/changepassword_binding.dart';
import '../modules/changepassword/views/changepassword_view.dart';
import '../modules/connectPartner/bindings/connect_partner_binding.dart';
import '../modules/connectPartner/views/connect_partner_view.dart';
import '../modules/editProfile/bindings/edit_profile_binding.dart';
import '../modules/editProfile/views/edit_profile_view.dart';
import '../modules/edukasi/bindings/edukasi_binding.dart';
import '../modules/edukasi/views/edukasi_view.dart';
import '../modules/face_scan/bindings/face_scan_binding.dart';
import '../modules/face_scan/views/face_scan_view.dart';
import '../modules/faq/bindings/faq_binding.dart';
import '../modules/faq/views/faq_view.dart';
import '../modules/favorite_vendor/bindings/favorite_vendor_binding.dart';
import '../modules/favorite_vendor/views/favorite_vendor_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/legal_detail/bindings/legal_detail_binding.dart';
import '../modules/legal_detail/views/legal_detail_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/todo/bindings/todo_binding.dart';
import '../modules/todo/views/todo_view.dart';
import '../modules/vendor/bindings/vendor_binding.dart';
import '../modules/vendor/views/vendor_view.dart';
import '../modules/vendorDetail/bindings/vendor_detail_binding.dart';
import '../modules/vendorDetail/views/vendor_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // 1. Mengubah halaman pertama kali terbuka ke Splash Screen
  // static const INITIAL = Routes.HOME;
  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.FACE_SCAN,
      page: () => const FaceScanView(),
      binding: FaceScanBinding(),
    ),
    GetPage(
      name: _Paths.TODO,
      page: () => const TodoView(),
      binding: TodoBinding(),
    ),
    GetPage(
      name: _Paths.VENDOR,
      page: () => const VendorView(),
      binding: VendorBinding(),
    ),
    GetPage(
      name: _Paths.VENDOR_DETAIL,
      page: () => const VendorDetailView(),
      binding: VendorDetailBinding(),
    ),
    GetPage(
      name: _Paths.EDUKASI,
      page: () => EdukasiView(), // <--- Hapus kata 'const' di sini
      binding: EdukasiBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqView(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: _Paths.CONNECT_PARTNER,
      page: () => const ConnectPartnerView(),
      binding: ConnectPartnerBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.ARTICLE_DETAIL,
      page: () => ArticleDetailView(article: Get.arguments as Article),
      binding: ArticleDetailBinding(),
    ),
    GetPage(
      name: _Paths.BOOKMARK,
      page: () => const BookmarkView(),
      binding: BookmarkBinding(),
    ),
    GetPage(
      name: _Paths.FAVORITE_VENDOR,
      page: () => const FavoriteVendorView(),
      binding: FavoriteVendorBinding(),
    ),
    GetPage(
      name: _Paths.CHANGEPASSWORD,
      page: () => const ChangepasswordView(),
      binding: ChangepasswordBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER_OTP,
      page: () => const RegisterOtpView(),
      binding: RegisterOtpBinding(),
    ),
  ];
}
