import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../data/ai_analysis_storage.dart';
import '../theme/app_colors.dart';

class AiHistoryPage extends StatefulWidget {
  const AiHistoryPage({super.key});

  @override
  State<AiHistoryPage> createState() => _AiHistoryPageState();
}

class _AiHistoryPageState extends State<AiHistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await AiAnalysisStorage.loadHistory();

    if (!mounted) return;

    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear AI History?'),
          content: const Text(
            'Semua hasil pengujian AI yang tersimpan di browser akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await AiAnalysisStorage.clearHistory();
    await _loadHistory();
  }

  String _formatDate(String? value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    String twoDigits(int number) {
      return number.toString().padLeft(2, '0');
    }

    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  Uint8List? _getImageBytes(Map<String, dynamic> item) {
    final base64Image = item['image_base64']?.toString();

    if (base64Image == null || base64Image.isEmpty) {
      return null;
    }

    try {
      return base64Decode(base64Image);
    } catch (_) {
      return null;
    }
  }

  void _showImagePreview(Uint8List imageBytes, String fileName) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Image.memory(imageBytes, fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.55),
                  ),
                  tooltip: 'Tutup',
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTests = _history.length;

    final leopardCount = _history
        .where((item) => item['classification'] == 'leopard_cat')
        .length;

    final nullCount = _history
        .where((item) => item['classification'] == 'null')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 700;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 28),

                      _buildStatistics(
                        totalTests,
                        leopardCount,
                        nullCount,
                        isMobile,
                      ),

                      const SizedBox(height: 28),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_history.isEmpty)
                        _buildEmptyState()
                      else
                        _buildHistoryList(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Analysis History',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Riwayat pengujian foto menggunakan AI.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        if (_history.isNotEmpty)
          OutlinedButton.icon(
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear History'),
          ),
      ],
    );
  }

  Widget _buildStatistics(
    int totalTests,
    int leopardCount,
    int nullCount,
    bool isMobile,
  ) {
    if (isMobile) {
      return Column(
        children: [
          _buildStatCard(
            'Total Tests',
            totalTests.toString(),
            Icons.analytics_rounded,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Leopard Cat',
            leopardCount.toString(),
            Icons.pets_rounded,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Null',
            nullCount.toString(),
            Icons.visibility_off_rounded,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Tests',
            totalTests.toString(),
            Icons.analytics_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Leopard Cat',
            leopardCount.toString(),
            Icons.pets_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Null',
            nullCount.toString(),
            Icons.visibility_off_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'Belum ada riwayat analisis',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hasil pengujian dari AI Test akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      children: [for (final item in _history) _buildHistoryItem(item)],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final classification = item['classification']?.toString() ?? '-';

    final classificationConfidence = (item['classification_confidence'] as num?)
        ?.toDouble();

    final orientation = item['orientation']?.toString();

    final orientationConfidence = (item['orientation_confidence'] as num?)
        ?.toDouble();

    final fileName = item['file_name']?.toString() ?? '-';

    final timestamp = item['timestamp']?.toString();

    final imageBytes = _getImageBytes(item);

    final isLeopardCat = classification == 'leopard_cat';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;

          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageThumbnail(imageBytes, fileName),
                const SizedBox(height: 16),
                _buildHistoryDetails(
                  fileName,
                  timestamp,
                  classification,
                  classificationConfidence,
                  orientation,
                  orientationConfidence,
                  isLeopardCat,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageThumbnail(imageBytes, fileName),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHistoryDetails(
                  fileName,
                  timestamp,
                  classification,
                  classificationConfidence,
                  orientation,
                  orientationConfidence,
                  isLeopardCat,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryDetails(
    String fileName,
    String? timestamp,
    String classification,
    double? classificationConfidence,
    String? orientation,
    double? orientationConfidence,
    bool isLeopardCat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _buildClassificationBadge(classification, isLeopardCat),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          _formatDate(timestamp),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),

        const SizedBox(height: 18),

        Wrap(
          spacing: 28,
          runSpacing: 14,
          children: [
            _buildResultValue(
              'Classification',
              classificationConfidence != null
                  ? '${classificationConfidence.toStringAsFixed(2)}%'
                  : '-',
            ),

            _buildResultValue(
              'Orientation',
              orientation != null ? _formatOrientation(orientation) : '-',
            ),

            if (isLeopardCat)
              _buildResultValue(
                'Orientation Confidence',
                orientationConfidence != null
                    ? '${orientationConfidence.toStringAsFixed(2)}%'
                    : '-',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(Uint8List? imageBytes, String fileName) {
    return GestureDetector(
      onTap: imageBytes == null
          ? null
          : () {
              _showImagePreview(imageBytes, fileName);
            },
      child: Container(
        width: 180,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(imageBytes, fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.zoom_in_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textMuted,
                    size: 28,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Foto tidak tersedia',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildClassificationBadge(String classification, bool isLeopardCat) {
    final badgeColor = isLeopardCat ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isLeopardCat ? 'LEOPARD CAT' : classification.toUpperCase(),
        style: TextStyle(
          color: badgeColor.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatOrientation(String value) {
    switch (value) {
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

      case 'null':
        return 'NULL';

      default:
        return value.toUpperCase();
    }
  }

  Widget _buildResultValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
