import 'package:flutter/material.dart';

import '../models/openalex_impact_profile.dart';
import '../models/openalex_ranked_entity.dart';
import '../viewmodels/publication_viewmodel.dart';
import '../screens/author_detail_screen.dart';
import '../screens/domain_detail_screen.dart';
import '../screens/institution_detail_screen.dart';
import '../screens/journal_detail_screen.dart';
import '../screens/year_detail_screen.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';
import 'expandable_ranked_chart.dart';
import 'journal_bar_chart.dart';
import 'keyword_bar_chart.dart';
import 'open_access_donut_chart.dart';
import 'trend_chart.dart';
import 'productivity_scatter_chart.dart';
import 'year_volume_bar_chart.dart';

/// Dữ liệu chung cho biểu đồ Overview và Explore.
class AnalyticsChartsData {
  final Map<int, int> volumeTrend;
  final Map<int, int>? citationTrend;
  final bool isMonthly;
  final String rangeLabel;
  final int openAccessCount;
  final int closedAccessCount;
  final List<OpenAlexRankedEntity> topics;
  final List<OpenAlexRankedEntity> institutions;
  final List<OpenAlexRankedEntity> worksByType;
  final List<OpenAlexRankedEntity> journals;
  final List<OpenAlexRankedEntity> authors;
  final List<OpenAlexRankedEntity> authorsByCitations;
  final List<OpenAlexRankedEntity> institutionsByCitations;
  final List<OpenAlexRankedEntity> countries;
  final List<OpenAlexRankedEntity> authorsByHIndex;
  final List<OpenAlexImpactProfile> authorImpactProfiles;
  const AnalyticsChartsData({
    required this.volumeTrend,
    required this.rangeLabel,
    this.citationTrend,
    this.isMonthly = false,
    this.openAccessCount = 0,
    this.closedAccessCount = 0,
    this.topics = const [],
    this.institutions = const [],
    this.worksByType = const [],
    this.journals = const [],
    this.authors = const [],
    this.authorsByCitations = const [],
    this.institutionsByCitations = const [],
    this.countries = const [],
    this.authorsByHIndex = const [],
    this.authorImpactProfiles = const [],
  });
}

/// Bộ biểu đồ analytics — dùng chung Overview và Explore.
class AnalyticsChartsPanel extends StatelessWidget {
  final AnalyticsChartsData data;
  final String sectionTitle;
  final bool isLoading;
  final PublicationViewModel? provider;

  const AnalyticsChartsPanel({
    super.key,
    required this.data,
    this.sectionTitle = 'Publication Analytics',
    this.isLoading = false,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && data.volumeTrend.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(sectionTitle),
        const SizedBox(height: 4),
        Text(
          'Khoảng: ${data.rangeLabel} · OpenAlex',
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        ..._buildChartSections(context),
      ],
    );
  }

  List<Widget> _buildChartSections(BuildContext context) {
    final sections = <Widget>[
      _volumeCard(context),
      const SizedBox(height: 14),
      _trendCard(),
    ];

    _appendOptional(sections, _openAccessCard());
    _appendOptional(sections, _rankedKeywordCard(
      title: 'Topic',
      subtitle: 'Top research topics',
      items: data.topics,
      onTap: (name) => _openTopicByName(context, name),
    ));
    _appendOptional(sections, _rankedKeywordCard(
      title: 'Institution',
      subtitle: 'Top publishing institutions',
      items: data.institutions,
      onTap: provider == null
          ? null
          : (name) => _openInstitutionByName(context, name),
    ));
    _appendOptional(sections, _worksByTypeCard());
    _appendOptional(sections, _journalsCard(context));
    _appendOptional(sections, _rankedKeywordCard(
      title: 'Research Leaders',
      subtitle: 'Authors with most publications',
      items: data.authors,
      onTap: provider == null
          ? null
          : (name) => _openAuthorByName(context, name),
    ));
    _appendOptional(
      sections,
      _rankedKeywordCard(
        title: 'Citation Leaders',
        subtitle: data.topics.isNotEmpty
            ? 'Authors in matched topics · career citations'
            : 'Authors ranked by citations in search results',
        items: data.authorsByCitations,
        minItems: 2,
        valueLabel: 'citations',
        onTap: provider == null
            ? null
            : (name) => _openAuthorByName(
                  context,
                  name,
                  data.authorsByCitations,
                ),
      ),
    );
    _appendOptional(
      sections,
      _rankedKeywordCard(
        title: 'Institution Impact',
        subtitle: 'Institutions ranked by total citations',
        items: data.institutionsByCitations,
        minItems: 2,
        valueLabel: 'citations',
        onTap: provider == null
            ? null
            : (name) => _openInstitutionByName(
                  context,
                  name,
                  data.institutionsByCitations,
                ),
      ),
    );
    _appendOptional(sections, _rankedKeywordCard(
      title: 'Countries',
      subtitle: 'Works by author country in scope',
      items: data.countries,
    ));
    _appendOptional(
      sections,
      _rankedKeywordCard(
        title: 'H-Index Leaders',
        subtitle: data.topics.isNotEmpty
            ? 'Career h-index · authors in matched topics'
            : 'Career h-index from OpenAlex summary_stats',
        items: data.authorsByHIndex,
        minItems: 2,
        valueLabel: 'h-index',
        onTap: provider == null
            ? null
            : (name) => _openAuthorByName(
                  context,
                  name,
                  data.authorsByHIndex,
                ),
      ),
    );
    _appendOptional(sections, _productivityCard(context));
    _appendOptional(sections, _domainsCard(context));
    return sections;
  }

  void _appendOptional(List<Widget> sections, Widget? card) {
    if (card == null) return;
    sections
      ..add(const SizedBox(height: 14))
      ..add(card);
  }

  Widget _volumeCard(BuildContext context) {
    final isMonthly = data.isMonthly;
    return _chartCard(
      title: isMonthly ? 'Month' : 'Year',
      subtitle: isMonthly
          ? 'Publication volume by month · ${data.rangeLabel}'
          : 'Publication volume by year · ${data.rangeLabel}',
      child: YearVolumeBarChart(
        yearlyData: data.volumeTrend,
        isMonthly: isMonthly,
        onYearTap: provider == null || isMonthly
            ? null
            : (year) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => YearDetailScreen(
                      year: year,
                      provider: provider!,
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _trendCard() {
    final citationTrend = data.citationTrend;
    final isMonthly = data.isMonthly;
    return _chartCard(
      title: 'Publication Trend',
      subtitle: isMonthly
          ? 'Monthly volume · ${data.rangeLabel}'
          : 'Volume with citation overlay · ${data.rangeLabel}',
      child: TrendChart(
        yearlyData: data.volumeTrend,
        overlayYearlyData:
            citationTrend == null || citationTrend.isEmpty ? null : citationTrend,
        isMonthly: isMonthly,
      ),
    );
  }

  Widget? _openAccessCard() {
    if (data.openAccessCount + data.closedAccessCount <= 0) return null;
    return _chartCard(
      title: 'Open Access',
      subtitle: 'Share of works in scope',
      child: OpenAccessDonutChart(
        openAccessCount: data.openAccessCount,
        closedCount: data.closedAccessCount,
      ),
    );
  }

  Widget? _worksByTypeCard() {
    if (data.worksByType.isEmpty) return null;
    return MockupCard(
      child: ExpandableRankedChart(
        title: 'Type',
        subtitle: 'Works by document type',
        items: data.worksByType
            .map((e) => MapEntry(_formatTypeName(e.name), e.count))
            .toList(),
        chartBuilder: (items) => KeywordBarChart(
          title: '',
          showFooter: false,
          items: items,
        ),
      ),
    );
  }

  Widget? _journalsCard(BuildContext context) {
    if (data.journals.isEmpty) return null;
    return MockupCard(
      child: ExpandableRankedChart(
        title: 'Publication Sources',
        subtitle: 'Top journals and venues',
        items: _toEntries(data.journals),
        chartBuilder: (items) => JournalBarChart(
          showHeader: false,
          journals: items,
          onJournalTap: provider == null
              ? null
              : (name) => _openJournalByName(context, name),
        ),
      ),
    );
  }

  Widget? _rankedKeywordCard({
    required String title,
    required String subtitle,
    required List<OpenAlexRankedEntity> items,
    int minItems = 1,
    String valueLabel = 'publications',
    void Function(String name)? onTap,
  }) {
    if (items.length < minItems) return null;
    return MockupCard(
      child: ExpandableRankedChart(
        title: title,
        subtitle: subtitle,
        items: _toEntries(items),
        chartBuilder: (chartItems) => KeywordBarChart(
          title: '',
          showFooter: false,
          items: chartItems,
          valueLabel: valueLabel,
          onItemTap: onTap,
        ),
      ),
    );
  }

  Widget? _productivityCard(BuildContext context) {
    if (data.authorImpactProfiles.length < 3) return null;
    return _chartCard(
      title: 'Productivity vs Impact',
      subtitle: 'Works count vs total citations · tap a point',
      child: ProductivityScatterChart(
        profiles: data.authorImpactProfiles,
        onPointTap: provider == null
            ? null
            : (profile) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthorDetailScreen(
                      author: OpenAlexRankedEntity(
                        id: profile.id,
                        name: profile.name,
                        count: profile.worksCount,
                      ),
                      provider: provider!,
                    ),
                  ),
                ),
      ),
    );
  }

  Widget? _domainsCard(BuildContext context) {
    if (data.topics.length < 2) return null;
    return MockupCard(
      child: ExpandableRankedChart(
        title: 'Research Domains',
        subtitle: 'Distribution among top fields',
        items: _toEntries(data.topics),
        chartBuilder: (items) => DomainDonutChart(
          domains: _domainsForEntries(items),
          onDomainTap: provider == null
              ? null
              : (domain) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DomainDetailScreen(domain: domain),
                    ),
                  ),
        ),
      ),
    );
  }

  void _openAuthorByName(
    BuildContext context,
    String name, [
    List<OpenAlexRankedEntity>? source,
  ]) {
    final author = _entityByName(source ?? data.authors, name);
    if (author == null || provider == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthorDetailScreen(
          author: author,
          provider: provider!,
        ),
      ),
    );
  }

  void _openJournalByName(BuildContext context, String name) {
    final journal = _entityByName(data.journals, name);
    if (journal == null || provider == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalDetailScreen(
          journal: journal,
          provider: provider!,
        ),
      ),
    );
  }

  void _openInstitutionByName(
    BuildContext context,
    String name, [
    List<OpenAlexRankedEntity>? source,
  ]) {
    final institution = _entityByName(source ?? data.institutions, name);
    if (institution == null || provider == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InstitutionDetailScreen(
          institution: institution,
          provider: provider!,
        ),
      ),
    );
  }

  OpenAlexRankedEntity? _entityByName(
    List<OpenAlexRankedEntity> items,
    String name,
  ) {
    for (final item in items) {
      if (item.name == name) return item;
    }
    return null;
  }

  void _openTopicByName(BuildContext context, String name) {
    OpenAlexRankedEntity? domain;
    for (final item in data.topics) {
      if (item.name == name) {
        domain = item;
        break;
      }
    }
    if (domain == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DomainDetailScreen(domain: domain!)),
    );
  }

  List<OpenAlexRankedEntity> _domainsForEntries(
    List<MapEntry<String, int>> items,
  ) {
    final names = items.map((entry) => entry.key).toSet();
    return data.topics.where((topic) => names.contains(topic.name)).toList();
  }

  List<MapEntry<String, int>> _toEntries(List<OpenAlexRankedEntity> entities) {
    return entities.map((e) => MapEntry(e.name, e.count)).toList();
  }

  String _formatTypeName(String raw) {
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return MockupCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
