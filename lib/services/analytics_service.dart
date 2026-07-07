import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics =
      FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(
      analytics: _analytics,
    );
  }

  // LOGIN
  static Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'google');
  }

  // LOGOUT
  static Future<void> logLogout() async {
    await _analytics.logEvent(
      name: 'logout',
    );
  }

  // SEARCH TOPIC
  static Future<void> logSearchTopic(
    String keyword,
  ) async {
    await _analytics.logEvent(
      name: 'search_topic',
      parameters: {
        'keyword': keyword,
      },
    );
  }

  // VIEW PUBLICATION
  static Future<void> logViewPublication({
    required String title,
    required int year,
  }) async {
    await _analytics.logEvent(
      name: 'view_publication',
      parameters: {
        'publication_title': title,
        'publication_year': year,
      },
    );
  }

  // VIEW JOURNAL
  static Future<void> logViewJournal(
    String journalName,
  ) async {
    await _analytics.logEvent(
      name: 'view_journal',
      parameters: {
        'journal_name': journalName,
      },
    );
  }

  // VIEW KEYWORD
  static Future<void> logViewKeyword(
    String keyword,
  ) async {
    await _analytics.logEvent(
      name: 'view_keyword',
      parameters: {
        'keyword': keyword,
      },
    );
  }

  //Author
  static Future<void> logViewAuthor({
    required String authorName,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'view_author',
      parameters: {
        'author_name': authorName,
      },
    );
  }

  // EXPORT PDF
  static Future<void> logExportPdf(
    String topic,
  ) async {
    await _analytics.logEvent(
      name: 'export_pdf',
      parameters: {
        'topic': topic,
      },
    );
  }

  static Future<void> logOpenPaper({
    required String title,
  }) async {
    await _analytics.logEvent(
      name: 'open_paper',
      parameters: {
        'title': title.length > 100
            ? title.substring(0, 100)
            : title,
      },
    );
  }

  static Future<void> logOpenDoi({
    required String doi,
  }) async {
    await _analytics.logEvent(
      name: 'open_doi',
      parameters: {
        'doi': doi,
      },
    );
  }

  static Future<void> logLoadMorePapers({
    required String source,
    required int currentCount,
  }) async {
    await _analytics.logEvent(
      name: 'load_more_papers',
      parameters: {
        'source': source,
        'current_count': currentCount,
      },
    );
  }
}