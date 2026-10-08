import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/ai_analysis_storage.dart';
import '../theme/app_colors.dart';

class AiTestPage extends StatefulWidget {
  const AiTestPage({super.key});

  @override
  State<AiTestPage> createState() => _AiTestPageState();
}

class _AiTestPageState extends State<AiTestPage> {
  // ============================================================
  // API
  // ============================================================

  static const String apiUrl = 'http://127.0.0.1:5000/predict';

  // ============================================================
  // IMAGE
  // ============================================================

  Uint8List? imageBytes;
  String? fileName;

  // ============================================================
  // CLASSIFICATION
  // ============================================================

  String? classification;
  double? classificationConfidence;

  double? leopardCatProbability;
  double? nullProbability;

  // ============================================================
  // ORIENTATION
  // ============================================================

  String? orientation;
  double? orientationConfidence;

  // ============================================================
  // STATE
  // ============================================================

  bool isLoading = false;
  String? errorMessage;

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (files.isEmpty) {
        return;
      }

      final PlatformFile file = files.first;

      final Uint8List bytes = await file.xFile.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        imageBytes = bytes;
        fileName = file.name;

        classification = null;
        classificationConfidence = null;

        leopardCatProbability = null;
        nullProbability = null;

        orientation = null;
        orientationConfidence = null;

        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = 'Gagal memilih gambar:\n$e';
      });
    }
  }

  // ============================================================
  // ANALYZE IMAGE
  // ============================================================

  Future<void> analyzeImage() async {
    if (imageBytes == null) {
      setState(() {
        errorMessage = 'Silakan pilih gambar terlebih dahulu.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(apiUrl),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes!,
          filename: fileName ?? 'image.jpg',
        ),
      );

      final http.StreamedResponse streamedResponse = await request.send();

      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}\n'
          '${response.body}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Response API tidak valid.');
      }

      if (decoded['status'] == 'error') {
        throw Exception(
          decoded['error']?.toString() ?? 'Terjadi kesalahan pada API.',
        );
      }

      // ----------------------------------------------------------
      // CLASSIFICATION
      // ----------------------------------------------------------

      final String? newClassification = decoded['classification']?.toString();

      final double newClassificationConfidence = readDouble(
        decoded['classification_confidence'],
      );

      // ----------------------------------------------------------
      // PROBABILITY
      // ----------------------------------------------------------

      final double newLeopardCatProbability = readDouble(
        decoded['leopard_cat_probability'],
      );

      final double newNullProbability = readDouble(decoded['null_probability']);

      // ----------------------------------------------------------
      // ORIENTATION
      // ----------------------------------------------------------

      final String? newOrientation = decoded['orientation']?.toString();

      final double newOrientationConfidence = readDouble(
        decoded['orientation_confidence'],
      );

      if (newClassification == null || newClassification.isEmpty) {
        throw Exception('Classification tidak ditemukan.');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        classification = newClassification;

        classificationConfidence = newClassificationConfidence;

        leopardCatProbability = newLeopardCatProbability;

        nullProbability = newNullProbability;

        orientation = newOrientation;

        orientationConfidence = newOrientationConfidence;
      });

      // ----------------------------------------------------------
      // SAVE RESULT
      // ----------------------------------------------------------

      await AiAnalysisStorage.saveAnalysis(
        fileName: fileName ?? 'unknown',

        classification: newClassification,

        classificationConfidence: newClassificationConfidence,

        orientation: newOrientation,

        orientationConfidence: newOrientationConfidence,

        imageBytes: imageBytes,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = 'Gagal melakukan analisis.\n\n$e';
      });
    }

    // ----------------------------------------------------------
    // STOP LOADING
    // ----------------------------------------------------------

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // READ DOUBLE
  // ============================================================

  double readDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  // ============================================================
  // FORMAT PERCENT
  // ============================================================

  String formatPercent(double value) {
    return '${value.toStringAsFixed(2)}%';
  }

  // ============================================================
  // FORMAT LABEL
  // ============================================================

  String formatLabel(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }

    switch (value) {
      case 'leopard_cat':
        return 'LEOPARD CAT';

      case 'null':
        return 'NULL';

      case 'depan':
        return 'DEPAN';

      case 'belakang':
        return 'BELAKANG';

      case 'kiri':
        return 'KIRI';

      case 'kanan':
        return 'KANAN';

      case 'tidak_yakin':
        return 'TIDAK YAKIN';

      default:
        return value.toUpperCase();
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  void resetPage() {
    setState(() {
      imageBytes = null;
      fileName = null;

      classification = null;
      classificationConfidence = null;

      leopardCatProbability = null;
      nullProbability = null;

      orientation = null;
      orientationConfidence = null;

      errorMessage = null;
      isLoading = false;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),

            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: buildImageCard()),

                      const SizedBox(width: 24),

                      Expanded(flex: 4, child: buildResultCard()),
                    ],
                  );
                }

                return Column(
                  children: [
                    buildImageCard(),

                    const SizedBox(height: 24),

                    buildResultCard(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Test',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Uji model AI menggunakan gambar camera trap.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 9, color: Colors.green),

              SizedBox(width: 8),

              Text(
                'LOCAL AI API',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget buildImageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INPUT IMAGE',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          buildImagePreview(),

          const SizedBox(height: 16),

          if (fileName != null)
            Row(
              children: [
                const Icon(Icons.image_outlined, size: 18),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    fileName!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : pickImage,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Pilih Foto'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: imageBytes != null && !isLoading
                      ? analyzeImage
                      : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    isLoading ? 'Menganalisis...' : 'Analyze With AI',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isLoading ? null : resetPage,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget buildImagePreview() {
    if (imageBytes == null) {
      return Container(
        height: 360,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_search_rounded, size: 64, color: Colors.grey),

            SizedBox(height: 14),

            Text(
              'Belum ada gambar',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
            ),

            SizedBox(height: 6),

            Text(
              'Pilih gambar untuk memulai pengujian AI',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 360,
        width: double.infinity,
        color: Colors.black12,
        child: Image.memory(imageBytes!, fit: BoxFit.contain),
      ),
    );
  }

  // ============================================================
  // RESULT CARD
  // ============================================================

  Widget buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI ANALYSIS RESULT',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 18),

          if (errorMessage != null) buildError(),

          if (errorMessage != null) const SizedBox(height: 16),

          buildClassification(),

          const SizedBox(height: 16),

          buildProbability(),

          const SizedBox(height: 16),

          buildOrientation(),

          const SizedBox(height: 20),

          buildInfo(),
        ],
      ),
    );
  }

  // ============================================================
  // CLASSIFICATION
  // ============================================================

  Widget buildClassification() {
    final bool hasResult = classification != null;

    final bool isLeopard = classification == 'leopard_cat';

    final Color resultColor = !hasResult
        ? Colors.grey
        : isLeopard
        ? Colors.green
        : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: resultColor.withValues(alpha: 0.06),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: resultColor.withValues(alpha: 0.12),
            ),
            child: Icon(
              isLeopard
                  ? Icons.pets_rounded
                  : Icons.remove_circle_outline_rounded,
              color: resultColor,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CLASSIFICATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  hasResult ? formatLabel(classification) : 'Belum dianalisis',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          if (classificationConfidence != null)
            Text(
              formatPercent(classificationConfidence!),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PROBABILITY
  // ============================================================

  Widget buildProbability() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CLASSIFICATION PROBABILITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 14),

          buildProbabilityRow(
            'Leopard Cat',
            leopardCatProbability,
            Icons.pets_rounded,
          ),

          const SizedBox(height: 12),

          buildProbabilityRow(
            'NULL',
            nullProbability,
            Icons.remove_circle_outline,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROBABILITY ROW
  // ============================================================

  Widget buildProbabilityRow(String label, double? value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        Text(
          value == null ? '-' : formatPercent(value),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  // ============================================================
  // ORIENTATION
  // ============================================================

  Widget buildOrientation() {
    IconData orientationIcon;

    switch (orientation) {
      case 'depan':
        orientationIcon = Icons.arrow_upward_rounded;
        break;

      case 'belakang':
        orientationIcon = Icons.arrow_downward_rounded;
        break;

      case 'kiri':
        orientationIcon = Icons.arrow_back_rounded;
        break;

      case 'kanan':
        orientationIcon = Icons.arrow_forward_rounded;
        break;

      default:
        orientationIcon = Icons.pets_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.blue.withValues(alpha: 0.10),
            ),
            child: Icon(orientationIcon, color: Colors.blue),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ORIENTATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  orientation == null
                      ? 'Belum dianalisis'
                      : formatLabel(orientation),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          if (orientationConfidence != null)
            Text(
              formatPercent(orientationConfidence!),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              errorMessage ?? '',
              style: const TextStyle(color: Colors.red, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget buildInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Colors.blue),

              SizedBox(width: 8),

              Text(
                'Catatan Pengujian',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),

          SizedBox(height: 10),

          Text(
            'Hasil AI merupakan prediksi model dan tetap perlu diverifikasi secara visual.',
            style: TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }
}
