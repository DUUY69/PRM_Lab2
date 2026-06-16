import 'package:flutter/material.dart';

import '../models/publication.dart';
import '../models/research_insight.dart';
import '../theme/app_theme.dart';
import '../utils/count_format.dart';
import '../utils/research_insights.dart';
import 'app_logo.dart';
import 'insight_widgets.dart';
import 'load_more_footer.dart';
import 'publication_card.dart';
import 'ranked_list_widgets.dart';
import 'trend_chart.dart';

class EntityStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;

  const EntityStatColumn({
    super.key,
    required this.label,
    required this.value,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        if (hint != null)
          Text(
            hint!,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9,
            ),
          ),
      ],
    );
  }
}

class EntityStatsCard extends StatelessWidget {
  final int totalCount;
  final double avgCitations;
  final int loadedCount;

  const EntityStatsCard({
    super.key,
    required this.totalCount,
    required this.avgCitations,
    required this.loadedCount,
  });

  @override
  Widget build(BuildContext context) {
    return MockupCard(
      child: Row(
        children: [
          Expanded(
            child: EntityStatColumn(
              label: 'Publications',
              value: formatOpenAlexCount(totalCount),
            ),
          ),
          Expanded(
            child: EntityStatColumn(
              label: 'Avg Citations',
              value: avgCitations.toStringAsFixed(0),
              hint: 'loaded papers',
            ),
          ),
          Expanded(
            child: EntityStatColumn(
              label: 'Loaded',
              value: '$loadedCount',
              hint: 'on screen',
            ),
          ),
        ],
      ),
    );
  }
}

class EntityGrowthInsightCard extends StatelessWidget {
  final TrendInsight insight;
  final String growthLabel;

  const EntityGrowthInsightCard({
    super.key,
    required this.insight,
    this.growthLabel = 'Publication growth',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        MockupCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ResearchInsights.formatGrowth(insight.periodGrowthPercent),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      growthLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              MomentumBadge(level: insight.momentum),
            ],
          ),
        ),
      ],
    );
  }
}

class EntityTrendSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Map<int, int> trend;
  final String emptyMessage;

  const EntityTrendSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trend,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        ScreenSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        MockupCard(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
          child: trend.isEmpty
              ? Text(
                  emptyMessage,
                  style: const TextStyle(color: AppColors.textSecondary),
                )
              : TrendChart(yearlyData: trend),
        ),
      ],
    );
  }
}

class EntityPapersSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Publication> papers;
  final int totalCount;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final String emptyMessage;

  const EntityPapersSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.papers,
    required this.totalCount,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        ScreenSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 8),
        if (papers.isEmpty)
          Text(emptyMessage)
        else ...[
          ...papers.map((paper) => PublicationCard(publication: paper)),
          LoadMoreFooter(
            loadedCount: papers.length,
            totalCount: totalCount,
            isLoading: isLoadingMore,
            hasMore: hasMore,
            onLoadMore: onLoadMore,
          ),
        ],
      ],
    );
  }
}

class EntityDetailErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const EntityDetailErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
