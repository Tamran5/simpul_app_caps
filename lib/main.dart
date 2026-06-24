import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/routes/app_pages.dart';
import 'dart:ui';

void main() async {
  // 1. Wajib dipanggil jika menggunakan async/await di dalam fungsi main()
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // 2. Buka penyimpanan lokal dan cari token JWT
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('access_token');

  // 3. Tentukan rute awal secara cerdas (Logika Auto-Login)
  String startingRoute;
  if (token != null && token.isNotEmpty) {
    // Jika token ADA: User sudah login sebelumnya, langsung tendang ke Beranda
    startingRoute = Routes.HOME; //Ganti dengan nama rute Beranda kamu, misal: '/home'
  } else {
    // Jika token KOSONG: User belum login atau sudah logout, arahkan ke Splash Screen/Login
    startingRoute = AppPages.INITIAL; 
  }

  // 4. Jalankan aplikasi dan kirimkan rute awalnya
  runApp(MyApp(initialRoute: startingRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute; // Variabel untuk menerima rute dinamis dari main()

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Simpul App',
      debugShowCheckedModeBanner: false,
      
      // Gunakan rute dinamis hasil pengecekan token di sini
      initialRoute: initialRoute, 
      
      getPages: AppPages.routes,      
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        },
      ),
    );
  }
}