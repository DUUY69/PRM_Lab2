import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/count_format.dart';

class _TrendChartScale {
  const _TrendChartScale({
    required this.years,
    required this.spots,
    required this.chartMinY,
    required this.chartMaxY,
    required this.yInterval,
    required this.labelInterval,
  });

  final List<int> years;
  final List<FlSpot> spots;
  final double chartMinY;
  final double chartMaxY;
  final double yInterval;
  final int labelInterval;
}

/// Line chart — trục X theo thứ tự năm, tooltip khi chạm điểm
class TrendChart extends StatelessWidget {
  final Map<int, int> yearlyData;

  const TrendChart({
    super.key,
    required this.yearlyData,
  });

  @override
  Widget build(BuildContext context) {
    final scale = _buildScale(yearlyData);
    if (scale == null) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No trend data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: LineChart(_buildChartData(scale)),
    );
  }

  _TrendChartScale? _buildScale(Map<int, int> data) {
    final years = data.keys.toList()..sort();
    if (years.isEmpty) {
      return null;
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < years.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[years[i]]!.toDouble()));
    }

    final maxY = data.values.reduce((a, b) => a > b ? a : b).toDouble();
    final minY = data.values.reduce((a, b) => a < b ? a : b).toDouble();
    final yPadding = (maxY - minY) * 0.15;
    final chartMaxY = maxY + (yPadding > 0 ? yPadding : maxY * 0.1);
    final chartMinY = (minY - yPadding).clamp(0, minY).toDouble();

    return _TrendChartScale(
      years: years,
      spots: spots,
      chartMinY: chartMinY,
      chartMaxY: chartMaxY,
      yInterval: _niceInterval(chartMaxY - chartMinY),
      labelInterval: years.length <= 6 ? 1 : (years.length / 5).ceil(),
    );
  }

  LineChartData _buildChartData(_TrendChartScale scale) {
    return LineChartData(
      minX: 0,
      maxX: (scale.years.length - 1).toDouble(),
      minY: scale.chartMinY,
      maxY: scale.chartMaxY,
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: scale.yInterval,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: AppColors.border,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final index = spot.x.toInt();
              if (index < 0 || index >= scale.years.length) {
                return null;
              }
              return LineTooltipItem(
                '${scale.years[index]}\n${formatOpenAlexCount(spot.y.toInt())}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: scale.spots,
          isCurved: scale.years.length > 2,
          curveSmoothness: 0.2,
          color: AppColors.textPrimary,
          barWidth: 2.5,
          dotData: FlDotData(
            show: scale.years.length <= 12,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 3.5,
              color: AppColors.textPrimary,
              strokeWidth: 0,
            ),
          ),
        ),
      ],
      titlesData: _buildTitles(scale),
    );
  }

  FlTitlesData _buildTitles(_TrendChartScale scale) {
    return FlTitlesData(
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 ||
                index >= scale.years.length ||
                index % scale.labelInterval != 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${scale.years[index]}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          interval: scale.yInterval,
          getTitlesWidget: (value, meta) {
            if (value < scale.chartMinY || value > scale.chartMaxY) {
              return const SizedBox.shrink();
            }
            return Text(
              formatOpenAlexCount(value.toInt()),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            );
          },
        ),
      ),
    );
  }

  double _niceInterval(double range) {
    if (range <= 0) return 1;
    final raw = range / 4;
    final magnitude =
        _pow10(raw.floor().toString().length - 1).clamp(1, 1000000000);
    final normalized = raw / magnitude;
    double nice;
    if (normalized <= 1) {
      nice = 1;
    } else if (normalized <= 2) {
      nice = 2;
    } else if (normalized <= 5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * magnitude;
  }

  double _pow10(int exponent) {
    var value = 1.0;
    for (var i = 0; i < exponent; i++) {
      value *= 10;
    }
    return value;
  }
}
