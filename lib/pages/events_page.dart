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
      final matchesSearch = query.isEmpty ||
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

  void _openPhotoViewer(
    BuildContext context,
    CameraTrapEvent event,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (context) {
        return _PhotoViewerDialog(
          event: event,
          initialIndex: initialIndex,
        );
      },
    );
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
                        child: _EventCard(
                          event: events[index],
                          onPhotoTap: (photoIndex) {
                            _openPhotoViewer(
                              context,
                              events[index],
                              photoIndex,
                            );
                          },
                        ),
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
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
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
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search event, label, or timestamp...',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
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
  final ValueChanged<int> onPhotoTap;

  const _EventCard({
    required this.event,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
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
            height: event.isLeopardCat ? 222 : 180,
            child: Row(
              children: [
                Expanded(
                  child: _PhotoCard(
                    path: event.photoPaths[0],
                    orientation:
                        event.isLeopardCat ? event.orientationAt(0) : null,
                    photoNumber: 1,
                    onTap: () => onPhotoTap(0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PhotoCard(
                    path: event.photoPaths[1],
                    orientation:
                        event.isLeopardCat ? event.orientationAt(1) : null,
                    photoNumber: 2,
                    onTap: () => onPhotoTap(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PhotoCard(
                    path: event.photoPaths[2],
                    orientation:
                        event.isLeopardCat ? event.orientationAt(2) : null,
                    photoNumber: 3,
                    onTap: () => onPhotoTap(2),
                  ),
                ),
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
  final String? orientation;
  final int photoNumber;
  final VoidCallback onTap;

  const _PhotoCard({
    required this.path,
    required this.photoNumber,
    required this.onTap,
    this.orientation,
  });

  @override
  Widget build(BuildContext context) {
    final hasOrientation =
        orientation != null && orientation!.trim().isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: Tooltip(
            message: 'Klik untuk melihat foto',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.surfaceLight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          path,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const _PhotoError();
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(
                                alpha: 0.65,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Foto $photoNumber  •  🔍',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasOrientation) ...[
          const SizedBox(height: 7),
          _OrientationBadge(
            orientation: orientation!,
          ),
        ],
      ],
    );
  }
}

class _PhotoViewerDialog extends StatefulWidget {
  final CameraTrapEvent event;
  final int initialIndex;

  const _PhotoViewerDialog({
    required this.event,
    required this.initialIndex,
  });

  @override
  State<_PhotoViewerDialog> createState() => _PhotoViewerDialogState();
}

class _PhotoViewerDialogState extends State<_PhotoViewerDialog> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  String get currentPath => widget.event.photoPaths[currentIndex];

  String? get currentOrientation {
    if (!widget.event.isLeopardCat) {
      return null;
    }

    return widget.event.orientationAt(currentIndex);
  }

  void _previousPhoto() {
    setState(() {
      currentIndex = (currentIndex - 1 + widget.event.photoPaths.length) %
          widget.event.photoPaths.length;
    });
  }

  void _nextPhoto() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.event.photoPaths.length;
    });
  }

  void _savePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Untuk menyimpan foto, klik kanan pada foto '
          'lalu pilih "Save image as..."',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = currentOrientation;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1180,
          maxHeight: 820,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          widget.event.eventId,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StatusBadge(
                          label: widget.event.isLeopardCat
                              ? 'Leopard Cat'
                              : 'Null',
                          isLeopardCat: widget.event.isLeopardCat,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 15,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.event.timestamp,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Foto ${currentIndex + 1} dari '
                    '${widget.event.photoPaths.length}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 5,
                    child: Center(
                      child: Image.asset(
                        currentPath,
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const _PhotoError();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Foto sebelumnya',
                    onPressed: _previousPhoto,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        if (orientation != null &&
                            orientation.trim().isNotEmpty)
                          _OrientationBadge(
                            orientation: orientation,
                          ),
                        const SizedBox(height: 5),
                        Text(
                          currentPath.split('/').last,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Foto berikutnya',
                    onPressed: _nextPhoto,
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textPrimary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _savePhoto,
                    icon: const Icon(
                      Icons.download_rounded,
                      size: 18,
                    ),
                    label: const Text('Simpan Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrientationBadge extends StatelessWidget {
  final String orientation;

  const _OrientationBadge({
    required this.orientation,
  });

  String get displayLabel {
    switch (orientation.toLowerCase()) {
      case 'depan':
        return 'Depan';
      case 'belakang':
        return 'Belakang';
      case 'kiri':
        return 'Kiri';
      case 'kanan':
        return 'Kanan';
      case 'tidak_yakin':
        return 'Tidak Yakin';
      case 'null':
        return 'Tidak Ada Satwa';
      default:
        return orientation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        displayLabel,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
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
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isLeopardCat;

  const _StatusBadge({
    required this.label,
    required this.isLeopardCat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
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
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
