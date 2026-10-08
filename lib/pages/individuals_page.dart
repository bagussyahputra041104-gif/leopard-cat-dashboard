import 'package:flutter/material.dart';

import '../data/event_data.dart';
import '../models/camera_trap_event.dart';
import '../theme/app_colors.dart';

class IndividualsPage extends StatelessWidget {
  const IndividualsPage({super.key});

  // ============================================================
  // FINAL RE-ID GROUPING
  // ============================================================

  static const List<String> ind01Strong = [
    'EVT_0002',
    'EVT_0013',
    'EVT_0014',
    'EVT_0015',
    'EVT_0020',
    'EVT_0024',
    'EVT_0025',
    'EVT_0035',
    'EVT_0057',
    'EVT_0058',
    'EVT_0060',
    'EVT_0007',
    'EVT_0010',
    'EVT_0017',
    'EVT_0038',
    'EVT_0046',
    'EVT_0048',
  ];

  static const List<String> ind01Possible = [
    'EVT_0003',
    'EVT_0012',
    'EVT_0056',
  ];

  static const List<String> ind03Strong = ['EVT_0026', 'EVT_0037'];

  static const List<String> uncertainEvents = [
    'EVT_0005',
    'EVT_0016',
    'EVT_0023',
    'EVT_0042',
    'EVT_0045',
    'EVT_0055',
    'EVT_0061',
  ];

  @override
  Widget build(BuildContext context) {
    const int candidateIndividuals = 2;
    final int strongMatches = ind01Strong.length + ind03Strong.length;
    final int possibleMatches = ind01Possible.length;
    final int uncertainCount = uncertainEvents.length;

    final int leopardCatEvents = eventData
        .where((event) => event.isLeopardCat)
        .length;

    final int reidEvidenceEvents =
        strongMatches + possibleMatches + uncertainCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),

          const SizedBox(height: 22),

          _buildOverview(
            candidateIndividuals: candidateIndividuals,
            strongMatches: strongMatches,
            possibleMatches: possibleMatches,
            uncertainCount: uncertainCount,
          ),

          const SizedBox(height: 18),

          _buildCoverageCard(
            leopardCatEvents: leopardCatEvents,
            evidenceEvents: reidEvidenceEvents,
          ),

          const SizedBox(height: 22),

          _buildIndividualSection(
            candidateId: 'IND_01',
            title: 'Observed Leopard Cat — Individual 01',
            strongIds: ind01Strong,
            possibleIds: ind01Possible,
          ),

          const SizedBox(height: 18),

          _buildIndividualSection(
            candidateId: 'IND_03',
            title: 'Observed Leopard Cat — Individual 03',
            strongIds: ind03Strong,
            possibleIds: const [],
          ),

          const SizedBox(height: 22),

          _buildUncertainSection(),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildPageHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observed Candidate Individuals',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Re-identification results based on visual similarity, '
          'cross-event matching, and manual visual review.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview({
    required int candidateIndividuals,
    required int strongMatches,
    required int possibleMatches,
    required int uncertainCount,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 900;

        final cards = [
          _buildOverviewCard(
            icon: Icons.pets_rounded,
            title: 'Candidate Individuals',
            value: '$candidateIndividuals',
            subtitle: 'candidate individuals',
            color: AppColors.reid,
          ),
          _buildOverviewCard(
            icon: Icons.verified_rounded,
            title: 'Strong Matches',
            value: '$strongMatches',
            subtitle: 'events',
            color: Colors.green,
          ),
          _buildOverviewCard(
            icon: Icons.compare_arrows_rounded,
            title: 'Possible Matches',
            value: '$possibleMatches',
            subtitle: 'events',
            color: Colors.orange,
          ),
          _buildOverviewCard(
            icon: Icons.help_outline_rounded,
            title: 'Uncertain',
            value: '$uncertainCount',
            subtitle: 'events',
            color: AppColors.textMuted,
          ),
        ];

        if (compact) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 10),
              cards[1],
              const SizedBox(height: 10),
              cards[2],
              const SizedBox(height: 10),
              cards[3],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
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
            const SizedBox(width: 11),
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
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8,
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
  // RE-ID EVIDENCE COVERAGE
  // ============================================================

  Widget _buildCoverageCard({
    required int leopardCatEvents,
    required int evidenceEvents,
  }) {
    final double coverage = leopardCatEvents == 0
        ? 0
        : (evidenceEvents / leopardCatEvents).clamp(0.0, 1.0);

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
              const Icon(
                Icons.analytics_outlined,
                color: AppColors.reid,
                size: 18,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Re-ID Evidence Coverage',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(coverage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.reid,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: coverage,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.reid),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$evidenceEvents of $leopardCatEvents leopard cat events '
            'have usable Re-ID evidence for individual grouping.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INDIVIDUAL SECTION
  // ============================================================

  Widget _buildIndividualSection({
    required String candidateId,
    required String title,
    required List<String> strongIds,
    required List<String> possibleIds,
  }) {
    final strongEvents = strongIds
        .map(_findEvent)
        .whereType<CameraTrapEvent>()
        .toList();

    final possibleEvents = possibleIds
        .map(_findEvent)
        .whereType<CameraTrapEvent>()
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.reid.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.reid.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Text(
                    candidateId,
                    style: const TextStyle(
                      color: AppColors.reid,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildStatusChip(
                  label: '${strongEvents.length} Strong',
                  color: Colors.green,
                  icon: Icons.verified_rounded,
                ),
                _buildStatusChip(
                  label: '${possibleEvents.length} Possible',
                  color: Colors.orange,
                  icon: Icons.help_outline_rounded,
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (strongEvents.isNotEmpty) ...[
              const Text(
                'STRONG EVIDENCE',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 9),
              _buildEventGrid(strongEvents),
            ],

            if (possibleEvents.isNotEmpty) ...[
              const SizedBox(height: 17),
              const Text(
                'POSSIBLE EVIDENCE',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 9),
              _buildEventGrid(possibleEvents, possible: true),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // UNCERTAIN
  // ============================================================

  Widget _buildUncertainSection() {
    final events = uncertainEvents
        .map(_findEvent)
        .whereType<CameraTrapEvent>()
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uncertain Events',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Not assigned to an observed candidate individual',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${events.length} events',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'These events were reviewed but did not have enough '
                'visual evidence to confidently assign them to IND_01 '
                'or IND_03.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 14),

            _buildEventGrid(events),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EVENT GRID
  // ============================================================

  Widget _buildEventGrid(
    List<CameraTrapEvent> events, {
    bool possible = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth < 700 ? 165 : 175;

        return Wrap(
          spacing: 10,
          runSpacing: 12,
          children: [
            for (final event in events)
              _buildEventPreview(event, width: cardWidth, possible: possible),
          ],
        );
      },
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LIGHTWEIGHT EVENT PREVIEW
  // ============================================================

  Widget _buildEventPreview(
    CameraTrapEvent event, {
    required double width,
    bool possible = false,
  }) {
    final Color statusColor = possible ? Colors.orange : AppColors.reid;

    final String? firstPhoto = event.photoPaths.isNotEmpty
        ? event.photoPaths.first
        : null;

    return Container(
      width: width,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: possible
              ? Colors.orange.withValues(alpha: 0.30)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.eventId,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                possible ? Icons.help_outline_rounded : Icons.pets_rounded,
                color: statusColor,
                size: 12,
              ),
            ],
          ),

          const SizedBox(height: 3),

          Text(
            event.timestamp,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 7.5),
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: firstPhoto == null
                ? Container(
                    height: 58,
                    width: double.infinity,
                    color: AppColors.surfaceLight,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textMuted,
                      size: 15,
                    ),
                  )
                : Image.asset(
                    firstPhoto,
                    height: 58,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    cacheWidth: 350,
                    cacheHeight: 116,
                    filterQuality: FilterQuality.low,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return Container(
                            height: 58,
                            color: AppColors.surfaceLight,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textMuted,
                              size: 15,
                            ),
                          );
                        },
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIND EVENT
  // ============================================================

  CameraTrapEvent? _findEvent(String eventId) {
    for (final event in eventData) {
      if (event.eventId == eventId) {
        return event;
      }
    }

    return null;
  }
}
