import 'package:flutter_test/flutter_test.dart';
import 'package:lab2/services/openalex_service.dart';

void main() {
  group('OpenAlexService static helpers', () {
    test('shortOpenAlexId extracts trailing id', () {
      expect(
        OpenAlexService.shortOpenAlexId('https://openalex.org/W123456789'),
        'W123456789',
      );
      expect(OpenAlexService.shortOpenAlexId('W999'), 'W999');
    });

    test('parseGroupByYear ignores invalid years', () {
      final trend = OpenAlexService.parseGroupByYear({
        'group_by': [
          {'key': '2022', 'count': 10},
          {'key': 'invalid', 'count': 5},
        ],
      });

      expect(trend, {2022: 10});
    });
  });
}
