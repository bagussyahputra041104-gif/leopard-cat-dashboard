import 'package:flutter/material.dart';

import '../data/event_data.dart';
import '../models/camera_trap_event.dart';
import '../theme/app_colors.dart';

class RecentEvents extends StatelessWidget {
  const RecentEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final recentEvents = _getRecentEvents();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(recentEvents.length),
            const SizedBox(height: 16),
            ...recentEvents.map(_buildEventRow),
          ],
        ),
      ),
    );
  }

  List<CameraTrapEvent> _getRecentEvents() {
    final events = [...eventData];

    events.sort((a, b) {
      final DateTime? dateA = _parseTimestamp(a.timestamp);
      final DateTime? dateB = _parseTimestamp(b.timestamp);

      if (dateA == null && dateB == null) {
        return 0;
      }

      if (dateA == null) {
        return 1;
      }

      if (dateB == null) {
        return -1;
      }

      return dateB.compareTo(dateA);
    });

    return events.take(4).toList();
  }

  DateTime? _parseTimestamp(String timestamp) {
    return DateTime.tryParse(timestamp.replaceFirst(' ', 'T'));
  }

  Widget _buildHeader(int count) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Camera Trap Events',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Latest events from the research dataset',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '$count latest',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventRow(CameraTrapEvent event) {
    final bool isLeopard = event.isLeopardCat;

    final Color statusColor = isLeopard
        ? AppColors.leopard
        : AppColors.nullEvent;

    final String label = isLeopard ? 'Leopard Cat' : 'Null';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return _buildCompactEvent(
              event: event,
              label: label,
              statusColor: statusColor,
            );
          }

          return _buildDesktopEvent(
            event: event,
            label: label,
            statusColor: statusColor,
          );
        },
      ),
    );
  }

  Widget _buildDesktopEvent({
    required CameraTrapEvent event,
    required String label,
    required Color statusColor,
  }) {
    return Row(
      children: [
        _buildPhotoStrip(event),
        const SizedBox(width: 14),
        Expanded(
          child: _buildEventInfo(
            event: event,
            label: label,
            statusColor: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactEvent({
    required CameraTrapEvent event,
    required String label,
    required Color statusColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPhotoStrip(event, width: double.infinity),
        const SizedBox(height: 12),
        _buildEventInfo(event: event, label: label, statusColor: statusColor),
      ],
    );
  }

  Widget _buildPhotoStrip(CameraTrapEvent event, {double width = 180}) {
    return SizedBox(
      width: width,
      height: 72,
      child: Row(
        children: [
          for (int index = 0; index < event.photoPaths.length; index++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == event.photoPaths.length - 1 ? 0 : 5,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    event.photoPaths[index],
                    height: 72,
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
                              size: 18,
                            ),
                          );
                        },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventInfo({
    required CameraTrapEvent event,
    required String label,
    required Color statusColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.eventId,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                event.timestamp,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${event.photoPaths.length} photos · Camera trap event',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.18)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: statusColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
