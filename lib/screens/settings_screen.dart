import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/github_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<GitHubProvider, ThemeProvider>(
      builder: (context, github, theme, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: AppTheme.gradientDecoration(isDark: isDark),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('设置', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),

                // Token 输入
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GitHub Token', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('输入 Personal Access Token 以获取完整数据', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      _TokenField(
                        hasToken: github.hasToken,
                        onSaved: (token) {
                          if (token != null && token.isNotEmpty) {
                            github.setCredentials(token, github.username);
                            github.loadUserData();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 用户名输入
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('用户名（无需 Token）', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('输入 GitHub 用户名查看公开数据', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      _UsernameField(
                        username: github.username,
                        onSaved: (username) {
                          if (username != null && username.isNotEmpty) {
                            github.setCredentials(github.hasToken ? null : null, username);
                            github.loadUserData();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 主题切换
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dark_mode_outlined, color: AppTheme.primaryGreen),
                          const SizedBox(width: 12),
                          Text('深色模式', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      Switch(
                        value: theme.isDark,
                        onChanged: (_) => theme.toggleTheme(),
                        activeColor: AppTheme.primaryGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 退出登录
                GlassCard(
                  onTap: () => _showClearConfirm(context, github),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      const Text('清除数据', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 关于
                Center(
                  child: Column(
                    children: [
                      const Text('GitHub Dashboard v1.1.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('https://github.com/aoye666')),
                        child: Text('by aoye666', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
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

  Future<void> _showClearConfirm(BuildContext context, GitHubProvider github) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除数据'),
        content: const Text('此操作将清除本地保存的 Token 和用户名，确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      github.setCredentials(null, null);
    }
  }
}

class _TokenField extends StatefulWidget {
  final bool hasToken;
  final Function(String?) onSaved;
  const _TokenField({required this.hasToken, required this.onSaved});

  @override
  State<_TokenField> createState() => _TokenFieldState();
}

class _TokenFieldState extends State<_TokenField> {
  late TextEditingController _controller;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.hasToken) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
                const SizedBox(width: 8),
                Text('已保存 Token', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('如需更换 Token，请输入新的 Token 后点击保存',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                obscureText: _obscure,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'ghp_xxxxxxxxxxxx',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => widget.onSaved(_controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ],
    );
  }
}

class _UsernameField extends StatefulWidget {
  final String? username;
  final Function(String?) onSaved;
  const _UsernameField({this.username, required this.onSaved});

  @override
  State<_UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<_UsernameField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.username ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: '输入 GitHub 用户名',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => widget.onSaved(_controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('查看'),
        ),
      ],
    );
  }
}
