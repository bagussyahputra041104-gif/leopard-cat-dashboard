import 'package:flutter/material.dart';

import '../data/event_data.dart';
import '../theme/app_colors.dart';

class OccurrencePage extends StatelessWidget {
  const OccurrencePage({super.key});

  // Final Re-ID summary
  static const int candidateIndividuals = 2;
  static const int strongMatches = 19;
  static const int possibleMatches = 3;

  @override
  Widget build(BuildContext context) {
    final int totalEvents = eventData.length;

    final int leopardCatEvents = eventData
        .where((event) => event.isLeopardCat)
        .length;

    final int nullEvents = eventData.where((event) => event.isNullEvent).length;

    final double leopardPercentage = totalEvents == 0
        ? 0
        : leopardCatEvents / totalEvents;

    final double nullPercentage = totalEvents == 0
        ? 0
        : nullEvents / totalEvents;

    final monthlyData = _buildMonthlyData();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 22),

          _buildStats(
            totalEvents: totalEvents,
            leopardCatEvents: leopardCatEvents,
            nullEvents: nullEvents,
          ),

          const SizedBox(height: 18),

          _buildReidSummary(),

          const SizedBox(height: 20),

          _buildDistribution(
            leopardCatEvents: leopardCatEvents,
            nullEvents: nullEvents,
            leopardPercentage: leopardPercentage,
            nullPercentage: nullPercentage,
          ),

          const SizedBox(height: 18),

          _buildTimeline(monthlyData),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Occurrence',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Occurrence summary based on camera trap research events.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN EVENT STATISTICS
  // ============================================================

  Widget _buildStats({
    required int totalEvents,
    required int leopardCatEvents,
    required int nullEvents,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 850;

        final cards = [
          _buildStat(
            title: 'Total Research Events',
            value: '$totalEvents',
            icon: Icons.camera_alt_rounded,
            color: AppColors.event,
          ),
          _buildStat(
            title: 'Leopard Cat Events',
            value: '$leopardCatEvents',
            icon: Icons.pets_rounded,
            color: AppColors.leopard,
          ),
          _buildStat(
            title: 'Null Events',
            value: '$nullEvents',
            icon: Icons.visibility_off_rounded,
            color: AppColors.nullEvent,
          ),
        ];

        if (compact) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 12),
              cards[1],
              const SizedBox(height: 12),
              cards[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
            const SizedBox(width: 14),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _buildStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RE-ID SUMMARY
  // ============================================================

  Widget _buildReidSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets_rounded, color: AppColors.reid, size: 18),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Re-ID Summary',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                'Candidate-based',
                style: TextStyle(color: AppColors.textMuted, fontSize: 8.5),
              ),
            ],
          ),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 650;

              final items = [
                _buildReidMetric(
                  title: 'Candidate Individuals',
                  value: '$candidateIndividuals',
                  icon: Icons.groups_rounded,
                  color: AppColors.reid,
                ),
                _buildReidMetric(
                  title: 'Strong Matches',
                  value: '$strongMatches',
                  icon: Icons.verified_rounded,
                  color: Colors.green,
                ),
                _buildReidMetric(
                  title: 'Possible Matches',
                  value: '$possibleMatches',
                  icon: Icons.help_outline_rounded,
                  color: Colors.orange,
                ),
              ];

              if (compact) {
                return Column(
                  children: [
                    items[0],
                    const SizedBox(height: 8),
                    items[1],
                    const SizedBox(height: 8),
                    items[2],
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: items[0]),
                  const SizedBox(width: 10),
                  Expanded(child: items[1]),
                  const SizedBox(width: 10),
                  Expanded(child: items[2]),
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          const Text(
            'Re-identification results represent candidate individuals '
            'derived from visual similarity and manual review. '
            'They should not be interpreted as absolute population size.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReidMetric({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
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

  // ============================================================
  // EVENT DISTRIBUTION
  // ============================================================

  Widget _buildDistribution({
    required int leopardCatEvents,
    required int nullEvents,
    required double leopardPercentage,
    required double nullPercentage,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Distribution',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Distribution of recorded research events by classification.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
            const SizedBox(height: 18),
            _buildDistributionRow(
              label: 'Leopard Cat Events',
              count: leopardCatEvents,
              percentage: leopardPercentage,
              color: AppColors.leopard,
            ),
            const SizedBox(height: 14),
            _buildDistributionRow(
              label: 'Null Events',
              count: nullEvents,
              percentage: nullPercentage,
              color: AppColors.nullEvent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionRow({
    required String label,
    required int count,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count events',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
            ),
            const SizedBox(width: 8),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 7,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildTimeline(List<_MonthlyOccurrence> monthlyData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Occurrence Timeline',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Monthly distribution of recorded camera trap events '
              'based on event timestamps.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
            const SizedBox(height: 14),
            _buildLegend(),
            const SizedBox(height: 16),
            SizedBox(height: 250, child: _MonthlyBarChart(data: monthlyData)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(color: AppColors.leopard, label: 'Leopard Cat Events'),
        const SizedBox(width: 18),
        _legendItem(color: AppColors.nullEvent, label: 'Null Events'),
      ],
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
        ),
      ],
    );
  }

  // ============================================================
  // MONTHLY DATA
  // ============================================================

  List<_MonthlyOccurrence> _buildMonthlyData() {
    final Map<String, _MonthlyOccurrence> grouped = {};

    for (final event in eventData) {
      final DateTime? date = DateTime.tryParse(
        event.timestamp.replaceFirst(' ', 'T'),
      );

      if (date == null) {
        continue;
      }

      final String key = '${date.year}-${date.month}';

      grouped.putIfAbsent(
        key,
        () => _MonthlyOccurrence(year: date.year, month: date.month),
      );

      if (event.isLeopardCat) {
        grouped[key]!.leopardCat++;
      } else {
        grouped[key]!.nullEvents++;
      }
    }

    final result = grouped.values.toList()
      ..sort((a, b) {
        if (a.year != b.year) {
          return a.year.compareTo(b.year);
        }

        return a.month.compareTo(b.month);
      });

    return result;
  }
}

// ============================================================
// MONTHLY MODEL
// ============================================================

class _MonthlyOccurrence {
  final int year;
  final int month;

  int leopardCat = 0;
  int nullEvents = 0;

  _MonthlyOccurrence({required this.year, required this.month});

  String get label {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[month - 1]} ${year.toString().substring(2)}';
  }

  int get maximum {
    return leopardCat > nullEvents ? leopardCat : nullEvents;
  }
}

// ============================================================
// MONTHLY BAR CHART
// ============================================================

class _MonthlyBarChart extends StatelessWidget {
  final List<_MonthlyOccurrence> data;

  const _MonthlyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No occurrence data available.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      );
    }

    int maximum = 0;

    for (final item in data) {
      if (item.maximum > maximum) {
        maximum = item.maximum;
      }
    }

    if (maximum == 0) {
      maximum = 1;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final item in data)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildMonth(item, maximum),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonth(_MonthlyOccurrence item, int maximum) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBar(
                value: item.leopardCat,
                maximum: maximum,
                color: AppColors.leopard,
              ),
              const SizedBox(width: 5),
              _buildBar(
                value: item.nullEvents,
                maximum: maximum,
                color: AppColors.nullEvent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Text(
          item.label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildBar({
    required int value,
    required int maximum,
    required Color color,
  }) {
    final double normalized = value / maximum;

    return FractionallySizedBox(
      heightFactor: normalized == 0 ? 0.01 : normalized,
      child: Container(
        width: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        ),
      ),
    );
  }
}
