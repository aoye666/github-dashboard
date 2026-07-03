import 'package:flutter/material.dart';
import '../models/repository.dart';
import '../models/contribution_stats.dart';
import '../utils/formatters.dart';
import 'glass_card.dart';

/// 仓库卡片组件
class RepoCard extends StatelessWidget {
  final Repository repo;
  final VoidCallback? onTap;

  const RepoCard({
    super.key,
    required this.repo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      margin: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 仓库名称 + 私有标记
          Row(
            children: [
              Icon(
                repo.private ? Icons.lock_outline : Icons.folder_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  repo.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (repo.fork)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Fork',
                    style: TextStyle(fontSize: 10, color: Colors.orange),
                  ),
                ),
              if (repo.archived)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Archived',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
            ],
          ),
          
          // 描述
          if (repo.description != null && repo.description!.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              repo.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          SizedBox(height: 12),
          
          // 统计信息行
          Row(
            children: [
              // 语言
              if (repo.language != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: LanguageStats.getColor(repo.language!),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  repo.language!,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                SizedBox(width: 16),
              ],
              
              // Stars
              Icon(Icons.star_outline, size: 14, color: Colors.amber),
              SizedBox(width: 4),
              Text(
                Formatters.formatNumber(repo.stargazersCount),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
              SizedBox(width: 16),
              
              // Forks
              Icon(Icons.fork_right, size: 14, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6)),
              SizedBox(width: 4),
              Text(
                Formatters.formatNumber(repo.forksCount),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
              SizedBox(width: 16),
              
              // Issues
              if (repo.openIssuesCount > 0) ...[
                Icon(Icons.bug_report_outlined, size: 14, color: Colors.redAccent),
                SizedBox(width: 4),
                Text(
                  repo.openIssuesCount.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
              
              Spacer(),
              
              // 更新时间
              Text(
                Formatters.formatRelativeTime(repo.updatedAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
