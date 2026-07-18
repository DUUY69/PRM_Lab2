import 'package:flutter_test/flutter_test.dart';
import 'package:lab2/services/recent_searches_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('add prepends unique topics and caps at maxItems', () async {
    final service = RecentSearchesService();

    await service.add('AI');
    await service.add('ras');
    await service.add('ai'); // duplicate case-insensitive

    final items = await service.load();
    expect(items.first, 'ai');
    expect(items.where((e) => e.toLowerCase() == 'ai').length, 1);
    expect(items.length, 2);

    for (var i = 0; i < 10; i++) {
      await service.add('topic-$i');
    }
    final capped = await service.load();
    expect(capped.length, RecentSearchesService.maxItems);
  });

  test('clear removes all topics', () async {
    final service = RecentSearchesService();
    await service.add('quantum');
    expect(await service.clear(), isEmpty);
    expect(await service.load(), isEmpty);
  });

  test('add ignores blank topic', () async {
    final service = RecentSearchesService();
    expect(await service.add('   '), isEmpty);
  });
}
