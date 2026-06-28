import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends GetxController {
  static const String supportEmail = 'halo@simpul.app';

  final RxString appVersion = ''.obs;
  final RxBool isLoadingVersion = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = info.version;
    } catch (_) {
      appVersion.value = '1.0.0';
    } finally {
      isLoadingVersion.value = false;
    }
  }

  Future<void> openSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=${Uri.encodeComponent('Masukan untuk Simpul')}',
    );
    try {
      final launched = await launchUrl(uri);
      if (!launched) _showError();
    } catch (_) {
      _showError();
    }
  }

  void _showError() {
    Get.snackbar(
      'Tidak dapat membuka tautan',
      'Periksa koneksi internet kamu dan coba lagi.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

/// Konten Syarat & Ketentuan, ditampilkan langsung di dalam aplikasi.
/// Ini draf awal yang wajar untuk aplikasi baru — sesuaikan isinya
/// dengan kebutuhan dan ketentuan hukum yang berlaku sebelum dipublikasikan.
const String kTermsAndConditionsText = '''
Terakhir diperbarui: Juni 2026

1. Tentang Simpul
Simpul adalah aplikasi yang membantu pasangan merencanakan pernikahan, termasuk fitur checklist tugas, daftar vendor, dan sinkronisasi data antar pasangan.

2. Penggunaan Aplikasi
Dengan menggunakan Simpul, kamu setuju untuk menggunakan aplikasi ini sesuai tujuannya dan tidak menyalahgunakan fitur yang tersedia, termasuk fitur sinkronisasi data pasangan.

3. Akun Pengguna
Kamu bertanggung jawab menjaga kerahasiaan informasi akun kamu, termasuk kode unik yang digunakan untuk menghubungkan akun dengan pasangan.

4. Data Vendor
Informasi vendor yang ditampilkan di aplikasi disediakan untuk membantu proses pencarian. Simpul tidak bertanggung jawab atas transaksi yang terjadi langsung antara pengguna dan vendor.

5. Perubahan Layanan
Karena Simpul masih dalam pengembangan aktif, fitur dan ketentuan ini dapat berubah dari waktu ke waktu. Perubahan akan diinformasikan melalui aplikasi.

6. Kontak
Jika ada pertanyaan terkait ketentuan ini, silakan hubungi kami melalui halaman Tentang Simpul.
''';

/// Konten Kebijakan Privasi, ditampilkan langsung di dalam aplikasi.
const String kPrivacyPolicyText = '''
Terakhir diperbarui: Juni 2026

1. Data yang Kami Kumpulkan
Simpul mengumpulkan data dasar seperti nama, email, dan progres checklist pernikahan kamu untuk menjalankan fitur aplikasi.

2. Penggunaan Data
Data yang kamu masukkan digunakan untuk menyinkronkan informasi antara kamu dan pasangan, serta menampilkan progres perencanaan pernikahan di dalam aplikasi.

3. Berbagi Data
Kami tidak menjual atau membagikan data pribadi kamu kepada pihak ketiga untuk tujuan pemasaran. Data hanya dibagikan dengan pasangan yang terhubung melalui fitur sinkronisasi.

4. Keamanan Data
Kami berupaya menjaga keamanan data kamu, namun seperti aplikasi pada umumnya, tidak ada sistem yang sepenuhnya bebas risiko. Gunakan kata sandi yang kuat dan jangan membagikan kode unik akunmu.

5. Hak Pengguna
Kamu dapat meminta penghapusan akun dan data terkait dengan menghubungi kami melalui halaman Tentang Simpul.

6. Perubahan Kebijakan
Karena Simpul masih dalam pengembangan aktif, kebijakan ini dapat diperbarui. Perubahan akan diinformasikan melalui aplikasi.
''';