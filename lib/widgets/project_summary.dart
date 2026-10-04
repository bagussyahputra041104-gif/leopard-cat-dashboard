import 'package:flutter/material.dart';

import '../data/event_data.dart';
import '../data/individual_data.dart';
import '../theme/app_colors.dart';

class ProjectSummary extends StatelessWidget {
  const ProjectSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final int totalEvents = eventData.length;

    final int leopardCatEvents = eventData
        .where((event) => event.label == 'leopard_cat')
        .length;

    final int nullEvents = eventData
        .where((event) => event.label == 'null')
        .length;

    final int candidateIndividuals = individualCandidates.length;

    int assignedEvents = 0;

    for (final candidate in individualCandidates) {
      assignedEvents += candidate.eventCount;
    }

    final int unassignedEvents = leopardCatEvents - assignedEvents;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildMetric(
              icon: Icons.camera_alt_rounded,
              label: 'Total events',
              value: '$totalEvents',
              accent: AppColors.leopard,
            ),
            _buildMetric(
              icon: Icons.pets_rounded,
              label: 'Leopard cat',
              value: '$leopardCatEvents',
              accent: AppColors.leopard,
            ),
            _buildMetric(
              icon: Icons.visibility_off_rounded,
              label: 'Null events',
              value: '$nullEvents',
              accent: AppColors.nullEvent,
            ),
            const SizedBox(height: 6),
            _buildDivider(),
            const SizedBox(height: 6),
            _buildMetric(
              icon: Icons.groups_rounded,
              label: 'Candidate individuals',
              value: '$candidateIndividuals',
              accent: AppColors.leopard,
            ),
            _buildMetric(
              icon: Icons.link_rounded,
              label: 'Assigned events',
              value: '$assignedEvents',
              accent: AppColors.leopard,
            ),
            _buildMetric(
              icon: Icons.help_outline_rounded,
              label: 'Unassigned events',
              value: '$unassignedEvents',
              accent: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Summary',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Current research dataset',
          style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
        ),
      ],
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.65),
    );
  }
}
