import 'package:flutter_test/flutter_test.dart';
import 'package:lab2/utils/count_format.dart';

void main() {
  group('formatOpenAlexCount', () {
    test('returns plain number below 1000', () {
      expect(formatOpenAlexCount(999), '999');
      expect(formatOpenAlexCount(0), '0');
    });

    test('formats thousands and millions', () {
      expect(formatOpenAlexCount(1500), '1.5K');
      expect(formatOpenAlexCount(201700), '201.7K');
      expect(formatOpenAlexCount(1200000), '1.2M');
      expect(formatOpenAlexCount(2500000000), '2.5B');
    });
  });

  group('formatOpenAlexCountFull', () {
    test('adds thousand separators', () {
      expect(formatOpenAlexCountFull(201700), '201,700');
      expect(formatOpenAlexCountFull(1000), '1,000');
    });
  });
}
