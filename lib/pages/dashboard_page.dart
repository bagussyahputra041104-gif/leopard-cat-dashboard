import 'package:flutter/material.dart';

import '../data/event_data.dart';
import '../data/individual_data.dart';
import '../theme/app_colors.dart';
import '../widgets/activity_chart.dart';
import '../widgets/project_summary.dart';
import '../widgets/recent_events.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        final bool isMobile = width < 650;
        final bool isTablet = width >= 650 && width <= 950;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 28,
            isMobile ? 18 : 26,
            isMobile ? 16 : 28,
            isMobile ? 110 : 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desktop / tablet only.
                  // Mobile already has the AppBar from AppShell.
                  if (!isMobile) ...[
                    _buildHeader(),
                    const SizedBox(height: 22),
                  ],

                  _buildResearchBanner(isMobile: isMobile),

                  const SizedBox(height: 24),

                  _buildStats(
                    totalEvents: totalEvents,
                    leopardCatEvents: leopardCatEvents,
                    nullEvents: nullEvents,
                    candidateIndividuals: candidateIndividuals,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),

                  const SizedBox(height: 24),

                  _buildAnalyticsSection(isMobile: isMobile),

                  const SizedBox(height: 24),

                  const RecentEvents(),

                  const SizedBox(height: 24),

                  _buildFooter(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        _buildBrandIcon(size: 48),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wildlife Intelligence',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Leopard Cat Camera Trap Research',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildBrandIcon({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Icon(
        Icons.forest_rounded,
        color: AppColors.primary,
        size: size * 0.48,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Research Dataset',
                style: TextStyle(color: AppColors.textMuted, fontSize: 8),
              ),
              SizedBox(height: 2),
              Text(
                '135 events · 405 photos',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESEARCH BANNER
  // ============================================================

  Widget _buildResearchBanner({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 15 : 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfaceLight, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 42 : 42,
            height: isMobile ? 42 : 42,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Camera Trap Research Overview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Classification, event analysis, and individual re-identification overview.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    height: 1.35,
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
  // STATISTICS
  // ============================================================

  Widget _buildStats({
    required int totalEvents,
    required int leopardCatEvents,
    required int nullEvents,
    required int candidateIndividuals,
    required bool isMobile,
    required bool isTablet,
  }) {
    final List<StatCard> cards = [
      StatCard(
        title: 'Total Events',
        value: '$totalEvents',
        description: 'Camera trap events',
        icon: Icons.camera_alt_rounded,
        accentColor: AppColors.event,
      ),
      StatCard(
        title: 'Leopard Cat',
        value: '$leopardCatEvents',
        description: 'Detected events',
        icon: Icons.pets_rounded,
        accentColor: AppColors.leopard,
      ),
      StatCard(
        title: 'Null Events',
        value: '$nullEvents',
        description: 'No target detected',
        icon: Icons.visibility_off_rounded,
        accentColor: AppColors.nullEvent,
      ),
      StatCard(
        title: 'Re-ID Candidates',
        value: '$candidateIndividuals',
        description: 'Candidate individuals',
        icon: Icons.groups_rounded,
        accentColor: AppColors.reid,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (int index = 0; index < cards.length; index++) ...[
            cards[index],
            if (index < cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    if (isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3.3,
        ),
        itemBuilder: (context, index) {
          return cards[index];
        },
      );
    }

    return Row(
      children: [
        for (int index = 0; index < cards.length; index++) ...[
          Expanded(child: cards[index]),
          if (index < cards.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  // ============================================================
  // ANALYTICS
  // ============================================================

  Widget _buildAnalyticsSection({required bool isMobile}) {
    if (isMobile) {
      return const Column(
        children: [ActivityChart(), SizedBox(height: 16), ProjectSummary()],
      );
    }

    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: ActivityChart()),
        SizedBox(width: 18),
        Expanded(flex: 3, child: ProjectSummary()),
      ],
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.science_outlined, color: AppColors.textMuted, size: 13),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              'Leopard Cat Camera Trap Research Dashboard',
              style: TextStyle(color: AppColors.textMuted, fontSize: 9),
            ),
          ),
          Text(
            '2017–2018 · 135 events',
            style: TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
