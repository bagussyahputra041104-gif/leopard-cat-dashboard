import 'package:flutter/material.dart';

import '../data/event_data.dart';
import '../data/individual_data.dart';
import '../models/camera_trap_event.dart';
import '../models/individual_candidate.dart';
import '../theme/app_colors.dart';

class IndividualsPage extends StatelessWidget {
  const IndividualsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int candidateCount = individualCandidates.length;

    final int assignedEvents = individualCandidates.fold<int>(
      0,
      (total, candidate) => total + candidate.eventCount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          const SizedBox(height: 22),
          _buildOverview(
            candidateCount: candidateCount,
            assignedEvents: assignedEvents,
          ),
          const SizedBox(height: 20),
          ...individualCandidates.map(_buildCandidateCard),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leopard Cat Individuals',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Candidate individuals identified from leopard cat events.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildOverview({
    required int candidateCount,
    required int assignedEvents,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 700;

        final cards = [
          _buildOverviewCard(
            icon: Icons.groups_rounded,
            title: 'Candidate Individuals',
            value: '$candidateCount',
            color: AppColors.reid,
          ),
          _buildOverviewCard(
            icon: Icons.link_rounded,
            title: 'Assigned Events',
            value: '$assignedEvents',
            color: AppColors.reid,
          ),
        ];

        if (compact) {
          return Column(
            children: [cards[0], const SizedBox(height: 12), cards[1]],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard(IndividualCandidate candidate) {
    final events = candidate.eventIds
        .map(_findEvent)
        .whereType<CameraTrapEvent>()
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCandidateHeader(candidate),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final double cardWidth = constraints.maxWidth < 700 ? 170 : 175;

                return Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    for (final event in events)
                      _buildEventPreview(event, width: cardWidth),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateHeader(IndividualCandidate candidate) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.reid.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.reid.withValues(alpha: 0.28)),
          ),
          child: Text(
            candidate.candidateId,
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
            candidate.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${candidate.eventCount} events',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 9.5),
        ),
      ],
    );
  }

  Widget _buildEventPreview(CameraTrapEvent event, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.eventId,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            event.timestamp,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 7.5),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 54,
            child: Row(
              children: [
                for (int index = 0; index < event.photoPaths.length; index++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == event.photoPaths.length - 1 ? 0 : 3,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          event.photoPaths[index],
                          height: 54,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return Container(
                                  color: AppColors.surfaceLight,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.textMuted,
                                    size: 13,
                                  ),
                                );
                              },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  CameraTrapEvent? _findEvent(String eventId) {
    for (final event in eventData) {
      if (event.eventId == eventId) {
        return event;
      }
    }

    return null;
  }
}
