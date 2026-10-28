import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stats/stats.dart';

/// One row of a bar chart.
class ChartEntry {
  final String label;
  final int value;

  const ChartEntry(this.label, this.value);
}

/// Horizontal bars with the label on the left and the number on the right.
/// Reads as a list for screen readers.
class HorizontalBars extends StatelessWidget {
  final List<ChartEntry> entries;
  final Color color;

  const HorizontalBars({super.key, required this.entries, required this.color});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final max = entries.fold<int>(0, (top, e) => math.max(top, e.value));

    return Column(
      children: [
        for (final entry in entries)
          MergeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall,
                    ),
                  ),
                  Expanded(
                    child: ExcludeSemantics(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: max == 0 ? 0 : entry.value / max,
                          minHeight: 12,
                          color: color,
                          backgroundColor: color.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${entry.value}',
                      textAlign: TextAlign.end,
                      style: textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Twelve vertical bars, one per month, with the initials under them.
class MonthBars extends StatelessWidget {
  final List<MonthStat> months;
  final List<String> monthLabels;
  final Color color;
  final String semanticsLabel;

  const MonthBars({
    super.key,
    required this.months,
    required this.monthLabels,
    required this.color,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final max = months.fold<int>(0, (top, m) => math.max(top, m.movies));

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final month in months)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (month.movies > 0)
                        Text('${month.movies}', style: textTheme.labelSmall),
                      const SizedBox(height: 2),
                      Container(
                        height: max == 0 ? 0 : 96 * month.movies / max,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        monthLabels[(month.month - 1).clamp(0, 11)],
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A donut with a legend; slices past [maxSlices] join "others".
class DonutChart extends StatelessWidget {
  static const maxSlices = 6;

  final List<ChartEntry> entries;
  final String othersLabel;
  final List<Color> palette;

  const DonutChart({
    super.key,
    required this.entries,
    required this.othersLabel,
    required this.palette,
  });

  List<ChartEntry> get _slices {
    if (entries.length <= maxSlices) return entries;
    final others = entries
        .skip(maxSlices - 1)
        .fold<int>(0, (t, e) => t + e.value);
    return [...entries.take(maxSlices - 1), ChartEntry(othersLabel, others)];
  }

  @override
  Widget build(BuildContext context) {
    final slices = _slices;
    final total = slices.fold<int>(0, (t, e) => t + e.value);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        ExcludeSemantics(
          child: SizedBox.square(
            dimension: 120,
            child: CustomPaint(
              painter: _DonutPainter(
                [for (final s in slices) s.value.toDouble()],
                palette,
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, slice) in slices.indexed)
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        ExcludeSemantics(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: palette[index % palette.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            slice.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          total == 0
                              ? '0%'
                              : '${(slice.value * 100 / total).round()}%',
                          style: textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> palette;
  final Color empty;

  _DonutPainter(this.values, this.palette, this.empty);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final total = values.fold<double>(0, (t, v) => t + v);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    if (total == 0) {
      canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = empty);
      return;
    }
    var start = -math.pi / 2;
    for (final (index, value) in values.indexed) {
      final sweep = math.pi * 2 * value / total;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        paint..color = palette[index % palette.length],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.empty != empty;
}

/// A year of days as squares, one column per week, darker with more sessions.
class CalendarHeatmap extends StatelessWidget {
  static const _cell = 12.0;
  static const _gap = 3.0;

  final int year;
  final List<CalendarDay> days;
  final Color color;
  final String semanticsLabel;

  const CalendarHeatmap({
    super.key,
    required this.year,
    required this.days,
    required this.color,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year);
    final offset = first.weekday % 7;
    final count = DateTime(year + 1).difference(first).inDays;
    final weeks = ((count + offset) / 7).ceil();
    final byDay = {
      for (final day in days)
        DateTime(day.date.year, day.date.month, day.date.day): day.sessions,
    };
    final max = byDay.values.fold<int>(0, math.max);
    final empty = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: SizedBox(
            width: weeks * (_cell + _gap),
            height: 7 * (_cell + _gap),
            child: CustomPaint(
              painter: _HeatmapPainter(
                first: first,
                offset: offset,
                count: count,
                byDay: byDay,
                max: max,
                color: color,
                empty: empty,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final DateTime first;
  final int offset;
  final int count;
  final Map<DateTime, int> byDay;
  final int max;
  final Color color;
  final Color empty;

  _HeatmapPainter({
    required this.first,
    required this.offset,
    required this.count,
    required this.byDay,
    required this.max,
    required this.color,
    required this.empty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cell = CalendarHeatmap._cell;
    const gap = CalendarHeatmap._gap;
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final day = DateTime(first.year, first.month, first.day + i);
      final slot = i + offset;
      final sessions = byDay[day] ?? 0;
      paint.color = sessions == 0
          ? empty
          : color.withValues(alpha: 0.35 + 0.65 * sessions / math.max(max, 1));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (slot ~/ 7) * (cell + gap),
            (slot % 7) * (cell + gap),
            cell,
            cell,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter oldDelegate) =>
      oldDelegate.byDay != byDay || oldDelegate.color != color;
}
