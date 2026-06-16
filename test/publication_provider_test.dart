import 'package:flutter_test/flutter_test.dart';
import 'package:lab2/models/research_insight.dart';
import 'package:lab2/providers/publication_provider.dart';
import 'package:lab2/services/openalex_config.dart';

void main() {
  group('PublicationProvider computed values', () {
    late PublicationProvider provider;

    setUp(() {
      provider = PublicationProvider(config: OpenAlexConfig());
    });

    test('trendInsight uses loaded yearly data', () {
      provider.yearlyTrendFromOpenAlex = {
        2020: 10,
        2021: 20,
        2022: 40,
      };
      provider.scope = AnalysisScope.topic;
      provider.currentTopic = 'Machine Learning';

      final insight = provider.trendInsight;

      expect(insight.peakYear, 2022);
      expect(insight.headline, contains('Machine Learning'));
    });

    test('topicSnapshot is null in global scope', () {
      provider.scope = AnalysisScope.global;
      provider.currentTopic = PublicationProvider.globalTopicLabel;

      expect(provider.topicSnapshot, isNull);
    });

    test('topicSnapshot is populated in topic scope', () {
      provider.scope = AnalysisScope.topic;
      provider.currentTopic = 'ras';
      provider.totalOnOpenAlex = 500;
      provider.yearlyTrendFromOpenAlex = {2022: 10, 2023: 20};

      final snapshot = provider.topicSnapshot;

      expect(snapshot, isNotNull);
      expect(snapshot!.topic, 'ras');
      expect(snapshot.totalPublications, 500);
    });

    test('landscapePulse uses dashboard totals', () {
      provider.totalOnOpenAlex = 1000;
      provider.yearlyTrendFromOpenAlex = {2022: 100, 2023: 150};
      provider.averageCitationOpenAlex = 12.5;

      final pulse = provider.landscapePulse;

      expect(pulse.peakYear, 2023);
      expect(pulse.yoyGrowthPercent, greaterThan(0));
    });
  });
}
