import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contribution_stats.dart';
import '../models/repository.dart';
import '../models/user_event.dart';
import '../providers/github_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GitHubProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final languageStats = provider.languageStats;

        return Container(
          decoration: AppTheme.gradientDecoration(isDark: isDark),
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Text('活跃度统计', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                SizedBox(height: 20),

                // 语言分布
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('语言分布', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 16),
                      ...languageStats.entries.map((e) => _LanguageBar(
                        language: e.key,
                        count: e.value,
                        total: provider.repos.length,
                      )),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // 提交热力图
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('提交热力图', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 16),
                      _HeatMap(events: provider.events),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // 仓库更新频率柱状图
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('仓库更新频率（月）', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 16),
                      _MonthlyBarChart(repos: provider.repos),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Top 仓库排行 (Stars)
                _TopRankSection(
                  title: 'Top 仓库 (Stars)',
                  repos: provider.repos,
                  sort: RepoSort.stars,
                  icon: Icons.star,
                  color: Colors.amber,
                  getValue: (r) => r.stargazersCount,
                  provider: provider,
                ),
                SizedBox(height: 16),

                // Top 仓库排行 (Forks)
                _TopRankSection(
                  title: 'Top 仓库 (Forks)',
                  repos: provider.repos,
                  sort: RepoSort.forks,
                  icon: Icons.fork_right,
                  color: Colors.blueAccent,
                  getValue: (r) => r.forksCount,
                  provider: provider,
                ),
                SizedBox(height: 16),

                // 总览卡片
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('总览', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          _OverviewItem('仓库', provider.repos.length.toString(), AppTheme.primaryGreen),
                          _OverviewItem('Stars', Formatters.formatNumber(provider.totalStars), Colors.amber),
                          _OverviewItem('Forks', Formatters.formatNumber(provider.totalForks), Colors.blueAccent),
                          _OverviewItem('关注者', Formatters.formatNumber(provider.user?.followers ?? 0), Colors.purpleAccent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 语言分布条
class _LanguageBar extends StatelessWidget {
  final String language;
  final int count;
  final int total;

  const _LanguageBar({required this.language, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;
    final color = LanguageStats.getColor(language);

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  SizedBox(width: 8),
                  Text(language, style: TextStyle(fontSize: 13)),
                ],
              ),
              Text('${count} (${Formatters.formatPercentage(percentage)})', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// 热力图
class _HeatMap extends StatelessWidget {
  final List<UserEvent> events;
  const _HeatMap({required this.events});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 最近12周（84天）
    final totalDays = 84;
    final days = List.generate(totalDays, (i) => now.subtract(Duration(days: totalDays - 1 - i)));
    
    // 按周排列（7行 x 12列）
    final weeks = <List<DateTime>>[];
    for (int w = 0; w < 12; w++) {
      final week = <DateTime>[];
      for (int d = 0; d < 7; d++) {
        final idx = w * 7 + d;
        if (idx < days.length) week.add(days[idx]);
      }
      weeks.add(week);
    }

    return Column(
      children: [
        // 星期标签 + 热力图
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 星期标签
            Column(
              children: ['一', '二', '三', '四', '五', '六', '日'].map((d) =>
                Container(height: 14, alignment: Alignment.center,
                  child: Text(d, style: TextStyle(fontSize: 9, color: Colors.grey)))
              ).toList(),
            ),
            SizedBox(width: 4),
            // 热力图网格
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.map((week) {
                    return Column(
                      children: week.map((day) {
                        final count = events.where((e) =>
                          e.createdAt.year == day.year &&
                          e.createdAt.month == day.month &&
                          e.createdAt.day == day.day
                        ).length;
                        final opacity = count == 0 ? 0.08 : (count.clamp(1, 5) / 5.0).clamp(0.2, 1.0);
                        return Container(
                          width: 14, height: 14,
                          margin: EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(opacity),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // 图例
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('少 ', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ...List.generate(5, (i) => Container(
              width: 12, height: 12, margin: EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(i == 0 ? 0.08 : i * 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            Text(' 多', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

/// 月度更新柱状图
class _MonthlyBarChart extends StatelessWidget {
  final List<Repository> repos;
  const _MonthlyBarChart({required this.repos});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // 最近6个月
    final months = List.generate(6, (i) {
      final m = now.month - 5 + i;
      final y = m <= 0 ? now.year - 1 : now.year;
      final month = m <= 0 ? m + 12 : m;
      return DateTime(y, month);
    });

    final monthNames = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    
    final counts = months.map((m) {
      return repos.where((r) =>
        r.updatedAt.year == m.year && r.updatedAt.month == m.month
      ).length;
    }).toList();

    final maxCount = counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(months.length, (i) {
          final ratio = counts[i] / maxCount;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 数值
                  Text('${counts[i]}', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  // 柱子
                  Container(
                    width: double.infinity,
                    height: (80 * ratio).clamp(4, 80),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  SizedBox(height: 6),
                  // 月份
                  Text(monthNames[months[i].month - 1], style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Top 仓库排行组件（单次排序缓存）
class _TopRankSection extends StatelessWidget {
  final String title;
  final List<Repository> repos;
  final RepoSort sort;
  final IconData icon;
  final Color color;
  final int Function(Repository) getValue;
  final GitHubProvider provider;

  const _TopRankSection({
    required this.title,
    required this.repos,
    required this.sort,
    required this.icon,
    required this.color,
    required this.getValue,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = provider.sortRepos(repos, sort);
    final top = sorted.take(5).toList();
    final maxValue = sorted.isEmpty ? 0 : getValue(sorted.first);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 16),
          if (top.isEmpty)
            Text('暂无数据', style: TextStyle(color: Colors.grey, fontSize: 13))
          else
            ...top.map((r) => _RankItem(
              name: r.name,
              value: getValue(r),
              icon: icon,
              color: color,
              maxValue: maxValue,
            )),
        ],
      ),
    );
  }
}

/// 排行项（带进度条）
class _RankItem extends StatelessWidget {
  final String name;
  final int value;
  final IconData icon;
  final Color color;
  final int maxValue;

  const _RankItem({required this.name, required this.value, required this.icon, required this.color, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue > 0 ? value / maxValue : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 6),
              Expanded(child: Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              Text(Formatters.formatNumber(value), style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
            ],
          ),
          SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(color.withOpacity(0.7)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

/// 总览项
class _OverviewItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _OverviewItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: color)),
          SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
