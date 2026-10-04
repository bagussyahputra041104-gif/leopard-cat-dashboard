import 'package:flutter/material.dart';

import '../data/event_data.dart';
import '../models/camera_trap_event.dart';
import '../theme/app_colors.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String searchQuery = '';
  String selectedFilter = 'All';

  List<CameraTrapEvent> get filteredEvents {
    final query = searchQuery.trim().toLowerCase();

    return eventData.where((event) {
      final matchesSearch =
          query.isEmpty ||
          event.eventId.toLowerCase().contains(query) ||
          event.label.toLowerCase().contains(query) ||
          event.timestamp.toLowerCase().contains(query);

      final matchesFilter = switch (selectedFilter) {
        'Leopard Cat' => event.isLeopardCat,
        'Null' => event.isNullEvent,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final events = filteredEvents;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(events.length),

          const SizedBox(height: 24),

          _buildToolbar(),

          const SizedBox(height: 20),

          Expanded(
            child: events.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == events.length - 1 ? 0 : 16,
                        ),
                        child: _EventCard(event: events[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int eventCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Events',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$eventCount camera trap events',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search event, label, or timestamp...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        _FilterButton(
          label: 'All',
          selected: selectedFilter == 'All',
          onTap: () {
            setState(() {
              selectedFilter = 'All';
            });
          },
        ),

        const SizedBox(width: 8),

        _FilterButton(
          label: 'Leopard Cat',
          selected: selectedFilter == 'Leopard Cat',
          onTap: () {
            setState(() {
              selectedFilter = 'Leopard Cat';
            });
          },
        ),

        const SizedBox(width: 8),

        _FilterButton(
          label: 'Null',
          selected: selectedFilter == 'Null',
          onTap: () {
            setState(() {
              selectedFilter = 'Null';
            });
          },
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryDark : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CameraTrapEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      event.eventId,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StatusBadge(
                      label: event.isLeopardCat ? 'Leopard Cat' : 'Null',
                      isLeopardCat: event.isLeopardCat,
                    ),
                  ],
                ),
              ),

              Text(
                event.timestamp,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(child: _PhotoCard(path: event.photoPaths[0])),

                const SizedBox(width: 10),

                Expanded(child: _PhotoCard(path: event.photoPaths[1])),

                const SizedBox(width: 10),

                Expanded(child: _PhotoCard(path: event.photoPaths[2])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String path;

  const _PhotoCard({required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: AppColors.surfaceLight,
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return const _PhotoError();
          },
        ),
      ),
    );
  }
}

class _PhotoError extends StatelessWidget {
  const _PhotoError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textMuted,
            size: 28,
          ),
          SizedBox(height: 8),
          Text(
            'Image unavailable',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isLeopardCat;

  const _StatusBadge({required this.label, required this.isLeopardCat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isLeopardCat ? AppColors.primaryDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isLeopardCat ? AppColors.leopard : AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'No events found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try another search or filter.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
