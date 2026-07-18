import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../utils/overview_time_range.dart';
import 'chart_axis_layout.dart';
import 'chart_touch_banner.dart';
import 'scrollable_chart_frame.dart';

/// Cột dọc theo năm — cuộn ngang khi nhiều năm, nhãn đủ 2026.
class YearVolumeBarChart extends StatefulWidget {
  final Map<int, int> yearlyData;
  final int maxYears;
  final bool isMonthly;
  final void Function(int year)? onYearTap;

  const YearVolumeBarChart({
    super.key,
    required this.yearlyData,
    this.maxYears = 14,
    this.isMonthly = false,
    this.onYearTap,
  });

  @override
  State<YearVolumeBarChart> createState() => _YearVolumeBarChartState();
}

class _YearChartSlice {
  const _YearChartSlice({
    required this.keys,
    required this.values,
    required this.maxY,
  });

  final List<int> keys;
  final List<int> values;
  final double maxY;
}

class _YearVolumeBarChartState extends State<YearVolumeBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.yearlyData.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No ${widget.isMonthly ? 'monthly' : 'yearly'} data',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final slice = _sliceData();
    final scrollable = ScrollableChartFrame.needsScroll(
      context,
      pointCount: slice.keys.length,
      isMonthly: widget.isMonthly,
    );
    final layout = scrollable
        ? _scrollLayout(slice.keys.length, widget.isMonthly)
        : ChartAxisLayout.fit(
            context,
            pointCount: slice.keys.length,
            isMonthly: widget.isMonthly,
          );
    final chartHeight = 240.0 + (layout.rotateLabels ? 16.0 : 0.0);
    final chartWidth = scrollable
        ? ScrollableChartFrame.contentWidth(
            context,
            pointCount: slice.keys.length,
            isMonthly: widget.isMonthly,
          )
        : ChartAxisLayout.viewportWidth(context);
    final chart = _buildBarChart(
      slice: slice,
      layout: layout,
      chartWidth: chartWidth,
      chartHeight: chartHeight,
      scrollable: scrollable,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChartTouchBanner(
          primaryText: _bannerPrimary(slice.keys),
          secondaryText: _bannerSecondary(slice.values),
        ),
        if (scrollable)
          ScrollableChartFrame(
            height: chartHeight,
            scrollable: true,
            scrollToEnd: true,
            child: chart,
          )
        else
          SizedBox(height: chartHeight, child: chart),
        if (_shouldShowDeclineNote(slice.values)) ...[
          const SizedBox(height: 6),
          Text(
            'Chạm cột để xem số bài — năm gần đây thấp hơn đỉnh 2017–2020 nhưng vẫn có dữ liệu',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textTertiary.withValues(alpha: 0.95),
              height: 1.3,
            ),
          ),
        ],
        if (scrollable) const SizedBox(height: 2),
      ],
    );
  }

  _YearChartSlice _sliceData() {
    final sorted = widget.yearlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final List<MapEntry<int, int>> slice;
    if (widget.isMonthly || sorted.length <= widget.maxYears) {
      slice = sorted;
    } else {
      slice = sorted.sublist(sorted.length - widget.maxYears);
    }
    final values = slice.map((e) => e.value).toList();
    return _YearChartSlice(
      keys: slice.map((e) => e.key).toList(),
      values: values,
      maxY: values.reduce((a, b) => a > b ? a : b).toDouble(),
    );
  }

  String? _bannerPrimary(List<int> keys) {
    final index = _selectedIndex;
    if (index == null || index < 0 || index >= keys.length) return null;
    return '${keys[index]}';
  }

  String _bannerSecondary(List<int> values) {
    final index = _selectedIndex;
    if (index == null || index < 0 || index >= values.length) {
      return 'Chạm cột để xem số bài theo năm';
    }
    return '${formatOpenAlexCount(values[index])} papers';
  }

  Widget _buildBarChart({
    required _YearChartSlice slice,
    required ChartAxisLayout layout,
    required double chartWidth,
    required double chartHeight,
    required bool scrollable,
  }) {
    return SizedBox(
      width: chartWidth,
      height: chartHeight,
      child: BarChart(
        BarChartData(
          maxY: slice.maxY * 1.15,
          alignment: BarChartAlignment.spaceBetween,
          groupsSpace: layout.groupsSpace,
          barTouchData: _barTouchData(slice.keys),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: slice.maxY > 0 ? slice.maxY / 4 : 1,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.border,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: _titlesData(slice, layout, scrollable),
          barGroups: [
            for (var i = 0; i < slice.values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: slice.values[i].toDouble(),
                    width: layout.barWidth,
                    color: _selectedIndex == i
                        ? AppColors.chartPrimary.withValues(alpha: 0.85)
                        : AppColors.chartPrimary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  BarTouchData _barTouchData(List<int> keys) {
    return BarTouchData(
      enabled: true,
      handleBuiltInTouches: false,
      touchTooltipData: const BarTouchTooltipData(),
      touchCallback: (event, response) {
        if (!event.isInterestedForInteractions) return;
        final index = response?.spot?.touchedBarGroupIndex;
        if (index == null || index < 0 || index >= keys.length) return;
        setState(() => _selectedIndex = index);
        widget.onYearTap?.call(keys[index]);
      },
    );
  }

  FlTitlesData _titlesData(
    _YearChartSlice slice,
    ChartAxisLayout layout,
    bool scrollable,
  ) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: layout.leftAxisSize,
          interval: slice.maxY > 0 ? slice.maxY / 4 : 1,
          getTitlesWidget: (value, meta) => Text(
            formatOpenAlexCount(value.toInt()),
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: layout.bottomReserved,
          interval: 1,
          getTitlesWidget: (value, meta) =>
              _bottomTitle(value, slice.keys, layout, scrollable),
        ),
      ),
    );
  }

  Widget _bottomTitle(
    double value,
    List<int> keys,
    ChartAxisLayout layout,
    bool scrollable,
  ) {
    final index = value.toInt();
    if (index < 0 ||
        index >= keys.length ||
        index % layout.labelInterval != 0) {
      return const SizedBox.shrink();
    }
    final label = widget.isMonthly
        ? monthShortLabel(keys[index])
        : '${keys[index]}';
    final isEdge = index == 0 || index == keys.length - 1;
    final double labelWidth;
    if (isEdge) {
      labelWidth = 60;
    } else if (scrollable) {
      labelWidth = 52;
    } else {
      labelWidth = 36;
    }
    return buildChartAxisLabel(
      text: label,
      rotate: layout.rotateLabels,
      labelWidth: labelWidth,
      textAlign: chartAxisLabelAlign(index: index, count: keys.length),
    );
  }

  static ChartAxisLayout _scrollLayout(int pointCount, bool isMonthly) {
    if (isMonthly) {
      return ChartAxisLayout(
        leftAxisSize: 40,
        barWidth: 14,
        groupsSpace: 10,
        labelInterval: pointCount > 8 ? 2 : 1,
        rotateLabels: false,
        shortYearLabels: false,
        bottomReserved: 38,
      );
    }
    return const ChartAxisLayout(
      leftAxisSize: 40,
      barWidth: 22,
      groupsSpace: 14,
      labelInterval: 1,
      rotateLabels: false,
      shortYearLabels: false,
      bottomReserved: 40,
    );
  }

  static bool _shouldShowDeclineNote(List<int> values) {
    if (values.length < 4) return false;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return false;
    final tail = values.sublist(values.length - 3);
    final tailMax = tail.reduce((a, b) => a > b ? a : b);
    return tailMax > 0 && tailMax < maxVal * 0.08;
  }
}
