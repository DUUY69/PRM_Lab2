import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab2/models/app_user.dart';
import 'package:lab2/services/openalex_config.dart';
import 'package:lab2/widgets/chart_axis_layout.dart';
import 'package:lab2/widgets/chart_touch_banner.dart';
import 'package:lab2/widgets/scrollable_chart_frame.dart';
import 'package:lab2/widgets/year_volume_bar_chart.dart';
import 'package:lab2/widgets/trend_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppUser', () {
    test('stores identity fields', () {
      const user = AppUser(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Ada',
        photoUrl: 'https://example.com/a.png',
      );
      expect(user.id, 'u1');
      expect(user.email, 'a@b.com');
      expect(user.displayName, 'Ada');
      expect(user.photoUrl, contains('example.com'));
    });
  });

  group('OpenAlexConfig', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('save and clear update apiKey', () async {
      final config = OpenAlexConfig();
      await config.load();
      expect(config.hasSavedKey, isFalse);

      await config.saveKey('test-key-123');
      expect(config.apiKey, 'test-key-123');
      expect(config.hasSavedKey, isTrue);
      expect(config.keySourceLabel, 'Saved in app');

      await config.clearSavedKey();
      expect(config.hasSavedKey, isFalse);
    });
  });

  group('ChartAxisLayout', () {
    testWidgets('fit returns yearly layout with full year labels', (tester) async {
      late ChartAxisLayout layout;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              layout = ChartAxisLayout.fit(
                context,
                pointCount: 10,
                isMonthly: false,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(layout.labelInterval, 1);
      expect(layout.shortYearLabels, isFalse);
      expect(layout.formatYear(2026), '2026');
    });

    testWidgets('fit monthly uses interval when crowded', (tester) async {
      late ChartAxisLayout layout;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              layout = ChartAxisLayout.fit(
                context,
                pointCount: 12,
                isMonthly: true,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(layout.labelInterval, 2);
      expect(layout.rotateLabels, isTrue);
    });

    test('chartAxisLabelAlign edges', () {
      expect(chartAxisLabelAlign(index: 0, count: 5), TextAlign.left);
      expect(chartAxisLabelAlign(index: 4, count: 5), TextAlign.right);
      expect(chartAxisLabelAlign(index: 2, count: 5), TextAlign.center);
      expect(chartAxisLabelAlign(index: 0, count: 1), TextAlign.center);
    });

    testWidgets('buildChartAxisLabel renders text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildChartAxisLabel(text: '2026', rotate: false),
          ),
        ),
      );
      expect(find.text('2026'), findsOneWidget);
    });
  });

  group('ScrollableChartFrame', () {
    testWidgets('contentWidth grows with point count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final narrow = ScrollableChartFrame.contentWidth(
                context,
                pointCount: 3,
                isMonthly: false,
              );
              final wide = ScrollableChartFrame.contentWidth(
                context,
                pointCount: 14,
                isMonthly: false,
              );
              expect(wide, greaterThan(narrow));
              expect(
                ScrollableChartFrame.needsScroll(
                  context,
                  pointCount: 14,
                  isMonthly: false,
                ),
                isTrue,
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('shows scroll hint when scrollable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScrollableChartFrame(
              height: 120,
              scrollable: true,
              child: SizedBox(width: 800, height: 120),
            ),
          ),
        ),
      );
      expect(find.textContaining('Kéo ngang'), findsOneWidget);
    });
  });

  group('ChartTouchBanner', () {
    testWidgets('shows hint when no selection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChartTouchBanner(
              secondaryText: 'Chạm cột để xem số bài theo năm',
            ),
          ),
        ),
      );
      expect(find.textContaining('Chạm cột'), findsOneWidget);
    });

    testWidgets('shows selected year and count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ChartTouchBanner(
              primaryText: '2024',
              secondaryText: '12.3K papers',
            ),
          ),
        ),
      );
      expect(find.byType(ChartTouchBanner), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
    });
  });

  group('Charts smoke', () {
    testWidgets('YearVolumeBarChart renders years', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: YearVolumeBarChart(
                yearlyData: {2022: 100, 2023: 80, 2024: 20},
              ),
            ),
          ),
        ),
      );
      expect(find.text('2022'), findsWidgets);
    });

    testWidgets('TrendChart renders empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendChart(yearlyData: {}),
          ),
        ),
      );
      expect(find.textContaining('No trend'), findsOneWidget);
    });

    testWidgets('TrendChart renders series', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendChart(
              yearlyData: {2022: 100, 2023: 80, 2024: 20},
            ),
          ),
        ),
      );
      expect(find.byType(TrendChart), findsOneWidget);
    });
  });
}
