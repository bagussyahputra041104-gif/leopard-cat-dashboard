import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String description;
  final IconData icon;
  final Color accentColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 650;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        child: Card(
          elevation: _hovered ? 6 : 0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 18,
              vertical: isMobile ? 13 : 18,
            ),
            child: Row(
              children: [
                _buildIcon(isMobile),
                SizedBox(width: isMobile ? 11 : 14),
                Expanded(child: _buildContent(isMobile)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isMobile) {
    final size = isMobile ? 40.0 : 44.0;
    final iconSize = isMobile ? 18.0 : 20.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.25)),
      ),
      child: Icon(widget.icon, color: widget.accentColor, size: iconSize),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: isMobile ? 10.5 : 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 22 : 24,
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: isMobile ? 9 : 9.5,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
