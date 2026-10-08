import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class AiAnalysisStorage {
  static const String _storageKey = 'ai_analysis_history';

  static Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_storageKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(savedData);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> saveAnalysis({
    required String fileName,
    required String classification,
    required double classificationConfidence,
    String? orientation,
    double? orientationConfidence,
    Uint8List? imageBytes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();

    history.insert(0, {
      'file_name': fileName,
      'classification': classification,
      'classification_confidence': classificationConfidence,
      'orientation': orientation,
      'orientation_confidence': orientationConfidence,
      'image_base64': imageBytes != null ? base64Encode(imageBytes) : null,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_storageKey, jsonEncode(history));
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
