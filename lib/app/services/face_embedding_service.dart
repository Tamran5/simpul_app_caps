// services/face_embedding_service.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceEmbeddingService {
  static Interpreter? _interpreter;
  static const int _inputSize = 112;      // sesuai MobileFaceNet
  static const int _embeddingDim = 192;   // sesuai output model

  static final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.2,
    ),
  );

  /// Load model sekali saja (panggil di awal app, misal main.dart / binding)
  static Future<void> init() async {
    _interpreter ??= await Interpreter.fromAsset(
      'assets/models/mobilefacenet.tflite',
    );
  }

  /// Proses penuh: file gambar -> embedding vector
  /// Melempar Exception kalau wajah tidak terdeteksi / lebih dari satu wajah
  static Future<List<double>> extractEmbedding(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Model belum di-load. Panggil FaceEmbeddingService.init() dulu.');
    }

    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _detector.processImage(inputImage);

    if (faces.isEmpty) {
      throw Exception('Wajah tidak terdeteksi. Pastikan wajah terlihat jelas.');
    }
    if (faces.length > 1) {
      throw Exception('Lebih dari satu wajah terdeteksi.');
    }

    final face = faces.first;
    final rawBytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw Exception('Gagal membaca file gambar.');
    }

    // Crop sesuai bounding box wajah (dengan sedikit padding)
    final box = face.boundingBox;
    final padding = box.width * 0.15;
    final cropped = img.copyCrop(
      decoded,
      x: (box.left - padding).clamp(0, decoded.width.toDouble()).toInt(),
      y: (box.top - padding).clamp(0, decoded.height.toDouble()).toInt(),
      width: (box.width + padding * 2).clamp(0, decoded.width.toDouble()).toInt(),
      height: (box.height + padding * 2).clamp(0, decoded.height.toDouble()).toInt(),
    );

    // Resize ke input model & normalisasi
    final resized = img.copyResize(cropped, width: _inputSize, height: _inputSize);
    final input = _imageToNestedInput(resized);

    // output HARUS berupa nested List juga, bukan flat List/TypedData,
    // karena tflite_flutter mencocokkan struktur input/output dengan shape
    // tensor model secara nested, bukan lewat flat buffer.
    final output = List.generate(1, (_) => List.filled(_embeddingDim, 0.0));
    _interpreter!.run(input, output);

    // L2 normalize embedding (penting untuk cosine distance yang konsisten)
    final vector = List<double>.from(output[0]);
    final norm = _l2Norm(vector);
    return vector.map((v) => v / norm).toList();
  }

  /// Bangun input 4D nested list [1, H, W, 3] secara langsung — JANGAN
  /// pakai `.reshape()` pada Float32List lalu cast ke Float32List lagi,
  /// karena `.reshape()` selalu mengembalikan nested List<dynamic>, bukan
  /// TypedData, sehingga cast tersebut selalu gagal di runtime.
  static List _imageToNestedInput(img.Image image) {
    return [
      List.generate(_inputSize, (y) {
        return List.generate(_inputSize, (x) {
          final pixel = image.getPixel(x, y);
          // Normalisasi ke [-1, 1], standar untuk kebanyakan model FaceNet-style
          return [
            (pixel.r - 127.5) / 128.0,
            (pixel.g - 127.5) / 128.0,
            (pixel.b - 127.5) / 128.0,
          ];
        });
      }),
    ];
  }

  /// L2 norm = akar kuadrat dari jumlah kuadrat tiap elemen.
  /// (Versi sebelumnya salah: langsung return jumlah kuadrat tanpa sqrt(),
  /// sehingga hasil normalisasi embedding tidak benar-benar unit vector.)
  static double _l2Norm(List<double> v) {
    double sumOfSquares = 0;
    for (final x in v) {
      sumOfSquares += x * x;
    }
    return sumOfSquares > 0 ? math.sqrt(sumOfSquares) : 1.0;
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _detector.close();
  }
}