import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/repository.dart';
import '../providers/github_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/repo_card.dart';
import 'repo_detail_screen.dart';

class ReposScreen extends StatefulWidget {
  const ReposScreen({super.key});

  @override
  State<ReposScreen> createState() => _ReposScreenState();
}

class _ReposScreenState extends State<ReposScreen> {
  String _searchQuery = '';
  RepoSort _sort = RepoSort.updated;

  @override
  Widget build(BuildContext context) {
    return Consumer<GitHubProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final repos = provider.searchRepos(_searchQuery);
        final sorted = provider.sortRepos(repos, _sort);

        return Container(
          decoration: AppTheme.gradientDecoration(isDark: isDark),
          child: SafeArea(
            child: Column(
              children: [
                // 标题
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('仓库', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),

                // 搜索栏
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: GlassCard(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: InputDecoration(
                              hintText: '搜索仓库...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 排序按钮
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _SortChip('最近更新', RepoSort.updated, Icons.access_time),
                        _SortChip('最多 Star', RepoSort.stars, Icons.star_outline),
                        _SortChip('最多 Fork', RepoSort.forks, Icons.fork_right),
                        _SortChip('最多 Issue', RepoSort.issues, Icons.bug_report_outlined),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12),

                // 仓库列表
                Expanded(
                  child: provider.isLoading
                    ? Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        itemCount: sorted.length,
                        itemBuilder: (context, index) {
                          return RepoCard(
                            repo: sorted[index],
                            onTap: () => _showRepoDetail(sorted[index]),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _SortChip(String label, RepoSort sort, IconData icon) {
    final isActive = _sort == sort;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isActive,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? AppTheme.primaryGreen : Colors.grey),
            SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
        onSelected: (_) => setState(() => _sort = sort),
        selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _showRepoDetail(Repository repo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RepoDetailScreen(repo: repo)),
    );
  }
}
