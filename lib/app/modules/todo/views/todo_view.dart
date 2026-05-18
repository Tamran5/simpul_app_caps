import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';

class TodoView extends StatelessWidget {
  const TodoView({Key? key}) : super(key: key);

  static const Color primaryGreen = Color(0xFF596E63);
  static const Color bgGreen = Color(0xFFF2F5F4);
  static const Color textDark = Color(0xFF333333);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderGrey = Color(0xFFE8E8E8);
  static const Color goldAccent = Color(0xFFC8A96A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TodoController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Simpul',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Wedding Journey', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textDark)),
                SizedBox(height: 8),
                Text('Lengkapi dan sinkronkan dokumen legal Anda.', style: TextStyle(fontSize: 14, color: textGrey)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final steps = controller.journeySteps;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                physics: const BouncingScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final step = steps[index];
                  final isLast = index == steps.length - 1;
                  return _buildJourneyStep(step, isLast, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyStep(JourneyStep step, bool isLast, TodoController controller) {
    return Obx(() {
      final isDone = step.isDone.value;

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom Timeline Kiri
            Column(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isDone ? primaryGreen : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDone ? primaryGreen : borderGrey, width: 2),
                  ),
                  child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: isDone ? primaryGreen : borderGrey)),
              ],
            ),
            const SizedBox(width: 16),
            
            // Kolom Konten Kanan
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDone ? primaryGreen.withOpacity(0.3) : borderGrey),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Kartu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleStep(step),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0, top: 2.0),
                              child: Icon(
                                isDone ? Icons.check_box : Icons.check_box_outline_blank,
                                color: isDone ? primaryGreen : textGrey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${step.category}: ${step.title}',
                                  style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold,
                                    color: isDone ? textGrey : textDark,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(step.subtitle, style: const TextStyle(fontSize: 13, color: textGrey, height: 1.4)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: textGrey),
                            onPressed: () => controller.showStepInfo(step),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      
                      // AREA UNGGAH DOKUMEN (Jika Diperlukan)
                      if (step.requiresDocument) ...[
                        const SizedBox(height: 16),
                        _buildDocumentSection(step, controller),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Widget Khusus Area Dokumen
 // Widget Khusus Area Dokumen
  Widget _buildDocumentSection(JourneyStep step, TodoController controller) {
    final status = step.documentStatus.value;
    final isUploaded = status != 'empty';

    return Container(
      decoration: BoxDecoration(
        color: isUploaded ? bgGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? primaryGreen.withOpacity(0.5) : borderGrey,
          style: BorderStyle.solid, 
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rencana Integrasi: ${step.targetInstitution}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen, letterSpacing: 0.5),
              ),
              if (isUploaded)
                const Icon(Icons.cloud_done_outlined, color: primaryGreen, size: 14),
            ],
          ),
          const SizedBox(height: 12),

          // Tampilan Berdasarkan Status
          if (!isUploaded)
            GestureDetector(
              onTap: () => controller.uploadDocument(step),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderGrey), // Dashed border styling
                ),
                child: Column(
                  children: const [
                    Icon(Icons.upload_file, color: textGrey, size: 28),
                    SizedBox(height: 8),
                    Text('Unggah Dokumen (PDF/JPG)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textDark)),
                  ],
                ),
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.uploadedFileName.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      const Text(
                        'Tersimpan di aplikasi (Siap sinkronisasi API)',
                        style: TextStyle(
                          fontSize: 11,
                          color: primaryGreen,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}