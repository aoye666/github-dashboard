import 'package:flutter/material.dart';
import '../models/repository.dart';
import '../services/github_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/glass_card.dart';
import 'package:url_launcher/url_launcher.dart';

class RepoDetailScreen extends StatefulWidget {
  final Repository repo;
  const RepoDetailScreen({super.key, required this.repo});

  @override
  State<RepoDetailScreen> createState() => _RepoDetailScreenState();
}

class _RepoDetailScreenState extends State<RepoDetailScreen> {
  final GitHubService _service = GitHubService();
  Map<String, int> _languages = {};
  List<Map<String, dynamic>> _contributors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final parts = widget.repo.fullName.split('/');
      if (parts.length == 2) {
        final langs = await _service.getRepoLanguages(parts[0], parts[1]);
        final contribs = await _service.getRepoContributors(parts[0], parts[1]);
        if (mounted) {
          setState(() {
            _languages = langs;
            _contributors = contribs;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repo;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalBytes = _languages.values.fold(0, (a, b) => a + b);

    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientDecoration(isDark: isDark),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 顶栏
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(repo.name, style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        icon: Icon(Icons.open_in_browser, color: AppTheme.primaryGreen),
                        onPressed: () => launchUrl(Uri.parse(repo.htmlUrl)),
                      ),
                    ],
                  ),
                ),
              ),

              // 仓库信息卡片
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(repo.private ? Icons.lock_outline : Icons.folder_outlined,
                              color: AppTheme.primaryGreen, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(repo.fullName,
                                style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryGreen)),
                            ),
                          ],
                        ),
                        if (repo.description != null && repo.description!.isNotEmpty) ...[
                          SizedBox(height: 10),
                          Text(repo.description!, style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8))),
                        ],
                        if (repo.topics != null && repo.topics!.isNotEmpty) ...[
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 6, runSpacing: 6,
                            children: repo.topics!.map((t) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                              ),
                              child: Text(t, style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen)),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // 统计数据
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      _StatItem('Stars', repo.stargazersCount, Icons.star_outline, Colors.amber),
                      SizedBox(width: 8),
                      _StatItem('Forks', repo.forksCount, Icons.fork_right, Colors.blueAccent),
                      SizedBox(width: 8),
                      _StatItem('Watchers', repo.watchersCount, Icons.visibility_outlined, Colors.teal),
                      SizedBox(width: 8),
                      _StatItem('Issues', repo.openIssuesCount, Icons.bug_report_outlined, Colors.redAccent),
                    ],
                  ),
                ),
              ),

              // 语言分布
              if (_languages.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('语言分布', style: theme.textTheme.titleMedium),
                          SizedBox(height: 12),
                          // 语言条
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Row(
                              children: _languages.entries.map((e) {
                                final pct = totalBytes > 0 ? e.value / totalBytes : 0.0;
                                return Expanded(
                                  flex: (pct * 1000).toInt().clamp(1, 1000),
                                  child: Container(height: 8, color: _langColor(e.key)),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 16, runSpacing: 8,
                            children: _languages.entries.map((e) {
                              final pct = totalBytes > 0 ? e.value / totalBytes : 0.0;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 10, height: 10,
                                    decoration: BoxDecoration(color: _langColor(e.key), shape: BoxShape.circle)),
                                  SizedBox(width: 4),
                                  Text('${e.key} ${Formatters.formatPercentage(pct)}',
                                    style: TextStyle(fontSize: 12)),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 贡献者
              if (_contributors.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('贡献者 (${_contributors.length})', style: theme.textTheme.titleMedium),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: _contributors.take(20).map((c) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(c['avatar_url'] ?? ''),
                                ),
                                SizedBox(height: 4),
                                SizedBox(
                                  width: 50,
                                  child: Text(c['login'] ?? '', style: TextStyle(fontSize: 9),
                                    overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                                ),
                                Text('${c['contributions'] ?? 0}', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen)),
                              ],
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 元信息
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: GlassCard(
                    child: Column(
                      children: [
                        _InfoRow('默认分支', repo.defaultBranch),
                        _InfoRow('大小', repo.formattedSize),
                        _InfoRow('创建时间', Formatters.formatDate(repo.createdAt)),
                        _InfoRow('最近更新', Formatters.formatRelativeTime(repo.updatedAt)),
                        _InfoRow('最近推送', Formatters.formatRelativeTime(repo.pushedAt)),
                      ],
                    ),
                  ),
                ),
              ),

              // Loading
              if (_loading)
                SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                  )),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _langColor(String lang) {
    final m = {
      'Dart': 0xFF00B4AB, 'JavaScript': 0xFFF1E05A, 'TypeScript': 0xFF2B7489,
      'Python': 0xFF3572A5, 'Java': 0xFFB07219, 'Kotlin': 0xFFA97BFF,
      'Swift': 0xFFF05138, 'Go': 0xFF00ADD8, 'Rust': 0xFFDEA584,
      'C++': 0xFFF34B7D, 'HTML': 0xFFE34C26, 'CSS': 0xFF563D7C,
      'Vue': 0xFF41B883, 'Shell': 0xFF89E051,
    };
    return Color(m[lang] ?? 0xFF999999);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 6),
            Text(Formatters.formatNumber(value), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
