import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/event_data.dart';
import '../theme/app_colors.dart';

class ActivityChart extends StatelessWidget {
  const ActivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _buildMonthlyData();

    final int totalEvents = eventData.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(totalEvents),
            const SizedBox(height: 18),
            _buildLegend(),
            const SizedBox(height: 14),
            SizedBox(
              height: 260,
              child: CustomPaint(
                painter: _OccurrenceChartPainter(monthlyData: monthlyData),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int totalEvents) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Occurrence',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Monthly camera trap event distribution',
                style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$totalEvents events',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendItem(color: AppColors.leopard, label: 'Leopard Cat'),
        const SizedBox(width: 18),
        _legendItem(color: AppColors.nullEvent, label: 'Null'),
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
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5),
        ),
      ],
    );
  }

  List<_MonthlyEventData> _buildMonthlyData() {
    final Map<String, _MonthlyEventData> grouped = {};

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
        () => _MonthlyEventData(year: date.year, month: date.month),
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

class _MonthlyEventData {
  final int year;
  final int month;
  int leopardCat = 0;
  int nullEvents = 0;

  _MonthlyEventData({required this.year, required this.month});

  int get total => leopardCat + nullEvents;

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
}

class _OccurrenceChartPainter extends CustomPainter {
  final List<_MonthlyEventData> monthlyData;

  _OccurrenceChartPainter({required this.monthlyData});

  @override
  void paint(Canvas canvas, Size size) {
    if (monthlyData.isEmpty) {
      return;
    }

    const double leftPadding = 30;
    const double rightPadding = 8;
    const double topPadding = 8;
    const double bottomPadding = 30;

    final double chartWidth = size.width - leftPadding - rightPadding;

    final double chartHeight = size.height - topPadding - bottomPadding;

    final int maximumValue = monthlyData.fold<int>(
      0,
      (maximum, item) => math.max(maximum, item.total),
    );

    final double maxValue = maximumValue == 0 ? 1 : maximumValue.toDouble();

    final Paint gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.55)
      ..strokeWidth = 1;

    final Paint leopardPaint = Paint()
      ..color = AppColors.leopard
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final Paint nullPaint = Paint()
      ..color = AppColors.nullEvent
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final Paint leopardPointPaint = Paint()..color = AppColors.leopard;

    final Paint nullPointPaint = Paint()..color = AppColors.nullEvent;

    final Paint labelPaint = Paint()
      ..color = AppColors.textMuted
      ..style = PaintingStyle.fill;

    _drawGrid(
      canvas,
      size,
      chartWidth,
      chartHeight,
      leftPadding,
      topPadding,
      maxValue,
      gridPaint,
      labelPaint,
    );

    final List<Offset> leopardPoints = [];
    final List<Offset> nullPoints = [];

    for (int index = 0; index < monthlyData.length; index++) {
      final double x = monthlyData.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (chartWidth * index / (monthlyData.length - 1));

      final double leopardY =
          topPadding +
          chartHeight -
          (monthlyData[index].leopardCat / maxValue) * chartHeight;

      final double nullY =
          topPadding +
          chartHeight -
          (monthlyData[index].nullEvents / maxValue) * chartHeight;

      leopardPoints.add(Offset(x, leopardY));
      nullPoints.add(Offset(x, nullY));
    }

    _drawLine(canvas, leopardPoints, leopardPaint);

    _drawLine(canvas, nullPoints, nullPaint);

    for (final point in leopardPoints) {
      canvas.drawCircle(point, 3.5, leopardPointPaint);
    }

    for (final point in nullPoints) {
      canvas.drawCircle(point, 3.5, nullPointPaint);
    }

    _drawMonthLabels(canvas, monthlyData, leopardPoints, size, labelPaint);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double chartWidth,
    double chartHeight,
    double leftPadding,
    double topPadding,
    double maxValue,
    Paint gridPaint,
    Paint labelPaint,
  ) {
    const int divisions = 4;

    for (int index = 0; index <= divisions; index++) {
      final double ratio = index / divisions;

      final double y = topPadding + chartHeight * ratio;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );

      final double value = maxValue * (1 - ratio);

      _drawText(canvas, value.round().toString(), Offset(2, y - 6), labelPaint);
    }
  }

  void _drawLine(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) {
      if (points.length == 1) {
        canvas.drawCircle(points.first, 2, paint);
      }

      return;
    }

    final Path path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int index = 1; index < points.length; index++) {
      path.lineTo(points[index].dx, points[index].dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawMonthLabels(
    Canvas canvas,
    List<_MonthlyEventData> data,
    List<Offset> points,
    Size size,
    Paint paint,
  ) {
    for (int index = 0; index < data.length; index++) {
      final String label = data[index].label;

      final double x = points[index].dx;

      _drawText(canvas, label, Offset(x - 17, size.height - 17), paint);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, Paint paint) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: paint.color,
          fontSize: 8,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _OccurrenceChartPainter oldDelegate) {
    return oldDelegate.monthlyData != monthlyData;
  }
}
