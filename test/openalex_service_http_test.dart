import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab2/services/openalex_config.dart';
import 'package:lab2/services/openalex_exception.dart';
import 'package:lab2/services/openalex_service.dart';

void main() {
  group('OpenAlexService HTTP', () {
    test('fetchWorksTotalCount parses meta count', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'api.openalex.org');
        return http.Response(
          jsonEncode({'meta': {'count': 42}, 'results': []}),
          200,
        );
      });

      final service = OpenAlexService(OpenAlexConfig(), httpClient: client);
      final count = await service.fetchWorksTotalCount(search: 'ras');

      expect(count, 42);
    });

    test('maps HTTP 401 to OpenAlexException', () async {
      final client = MockClient((request) async {
        return http.Response('unauthorized', 401);
      });

      final service = OpenAlexService(OpenAlexConfig(), httpClient: client);

      expect(
        () => service.fetchWorksTotalCount(search: 'ras'),
        throwsA(isA<OpenAlexException>()),
      );
    });

    test('searchPublications maps work json to publications', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'meta': {'count': 1},
            'results': [
              {
                'id': 'https://openalex.org/W1',
                'title': 'Sample paper',
                'publication_year': 2024,
                'cited_by_count': 12,
                'type': 'article',
                'primary_location': {
                  'source': {'display_name': 'Nature'},
                },
                'authorships': [],
                'abstract_inverted_index': null,
              },
            ],
          }),
          200,
        );
      });

      final service = OpenAlexService(OpenAlexConfig(), httpClient: client);
      final result = await service.searchPublications('ras');

      expect(result.totalOnOpenAlex, 1);
      expect(result.publications.single.title, 'Sample paper');
      expect(result.publications.single.citations, 12);
    });
  });
}
