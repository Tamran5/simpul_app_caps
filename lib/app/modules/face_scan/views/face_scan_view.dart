import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/face_scan_controller.dart';

class FaceScanView extends StatelessWidget {
  const FaceScanView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color textDark = Color(0xFF333333);
  static const Color textGrey = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FaceScanController());

    return Scaffold(
      backgroundColor: Colors.black87, // Latar belakang gelap untuk fokus kamera
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Face Recognition',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Teks Instruksi Dinamis
            Obx(() => Text(
              controller.instructionText.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            )),
            
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Pastikan pencahayaan cukup dan wajah Anda tidak tertutup aksesori.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
              ),
            ),
            
            const Spacer(),

            // Area Bingkai Kamera (Viewfinder)
            Center(
              child: Obx(() {
                final progress = controller.scanProgress.value;
                final step = controller.scanStep.value;
                
                return SizedBox(
                  width: 280,
                  height: 350,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lingkaran Progress Bar di luar bingkai
                      SizedBox(
                        width: 280,
                        height: 350,
                        child: CircularProgressIndicator(
                          value: progress > 0 ? progress : null, // Null = loading berputar jika belum mulai
                          strokeWidth: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                        ),
                      ),
                      
                      // Area "Kamera" (Simulasi dengan gambar)
                      Container(
                        width: 250,
                        height: 320,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(150), // Bentuk Oval
                          border: Border.all(color: Colors.white12, width: 2),
                        ),
                        child: Center(
                          // Mengganti ikon berdasarkan tahap pemindaian
                          child: Icon(
                            step == 2 ? Icons.face_retouching_natural : Icons.face,
                            size: 120,
                            color: step == 3 ? primaryGreen : Colors.white24,
                          ),
                        ),
                      ),
                      
                      // Efek Overlay Scan saat proses berjalan
                      if (step == 1 || step == 2)
                        Positioned(
                          top: 40 + (240 * progress), // Simulasi garis scan turun naik
                          child: Container(
                            width: 200,
                            height: 4,
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryGreen.withOpacity(0.6),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
            
            const Spacer(),

            // Tombol Mulai / Ulangi
            Obx(() {
              final step = controller.scanStep.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: step == 0 ? () => controller.startScanning() : 
                               step == 3 ? () => controller.resetScan() : null, // Disable saat sedang scan
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      disabledBackgroundColor: primaryGreen.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      step == 0 ? 'Mulai Pindai Wajah' : 
                      step == 3 ? 'Ulangi Pemindaian' : 'Memindai...',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}