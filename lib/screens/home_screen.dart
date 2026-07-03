import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/github_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../models/github_user.dart';
import '../models/user_event.dart';
import '../widgets/glass_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/repo_card.dart';
import 'repos_screen.dart';
import 'activity_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardPage(),
          ReposScreen(),
          ActivityScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(0, Icons.dashboard_outlined, Icons.dashboard, '仪表盘'),
              _NavItem(1, Icons.folder_outlined, Icons.folder, '仓库'),
              _NavItem(2, Icons.bar_chart_outlined, Icons.bar_chart, '活跃度'),
              _NavItem(3, Icons.settings_outlined, Icons.settings, '设置'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _NavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    final color = isActive ? AppTheme.primaryGreen : Colors.grey;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? activeIcon : icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
        ],
      ),
    );
  }
}

/// 仪表盘主页
class _DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GitHubProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: AppTheme.gradientDecoration(isDark: isDark),
          child: SafeArea(
            child: provider.isLoading && user == null
              ? Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  color: AppTheme.primaryGreen,
                  child: CustomScrollView(
                    slivers: [
                      // 标题
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
                              Text('GitHub Dashboard', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.refresh, color: AppTheme.primaryGreen),
                                onPressed: provider.refresh,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 用户卡片
                      if (user != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: _UserCard(user: user),
                          ),
                        ),

                      // 统计卡片
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              StatCard(title: '仓库总数', value: provider.repos.length.toString(), icon: Icons.folder_outlined, color: AppTheme.primaryGreen),
                              StatCard(title: '总 Stars', value: Formatters.formatNumber(provider.totalStars), icon: Icons.star_outline, color: Colors.amber),
                              StatCard(title: '总 Forks', value: Formatters.formatNumber(provider.totalForks), icon: Icons.fork_right, color: Colors.blueAccent),
                              StatCard(title: 'Open Issues', value: Formatters.formatNumber(provider.totalIssues), icon: Icons.bug_report_outlined, color: Colors.redAccent),
                            ],
                          ),
                        ),
                      ),

                      // 最近活动标题
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Text('最近活动', style: Theme.of(context).textTheme.titleLarge),
                        ),
                      ),

                      // 最近活动列表
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (provider.events.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text('暂无活动数据', style: TextStyle(color: Colors.grey)),
                                ),
                              );
                            }
                            final event = provider.events[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              child: _EventItem(event: event),
                            );
                          },
                          childCount: provider.events.isEmpty ? 1 : provider.events.length.clamp(0, 10),
                        ),
                      ),

                      // 底部间距
                      SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
          ),
        );
      },
    );
  }
}

/// 用户卡片
class _UserCard extends StatelessWidget {
  final GitHubUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      child: Row(
        children: [
          // 头像
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryGreen, width: 2),
              image: DecorationImage(
                image: NetworkImage(user.avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('@${user.login}', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.primaryGreen)),
                if (user.bio != null) ...[
                  SizedBox(height: 4),
                  Text(user.bio!, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    _MiniStat('关注者', user.followers),
                    SizedBox(width: 16),
                    _MiniStat('正在关注', user.following),
                    SizedBox(width: 16),
                    _MiniStat('公开仓库', user.publicRepos),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Formatters.formatNumber(value), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

/// 事件项
class _EventItem extends StatelessWidget {
  final UserEvent event;
  const _EventItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(event.icon, style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(height: 2),
                Text(event.repoName, style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen)),
              ],
            ),
          ),
          Text(Formatters.formatRelativeTime(event.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
