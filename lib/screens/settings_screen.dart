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
              padding: EdgeInsets.all(20),
              children: [
                Text('设置', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                SizedBox(height: 20),

                // Token 输入
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GitHub Token', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8),
                      Text('输入 Personal Access Token 以获取完整数据', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 12),
                      _TokenField(
                        token: github.token,
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
                SizedBox(height: 16),

                // 用户名输入
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('用户名（无需 Token）', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8),
                      Text('输入 GitHub 用户名查看公开数据', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 12),
                      _UsernameField(
                        username: github.username,
                        onSaved: (username) {
                          if (username != null && username.isNotEmpty) {
                            github.setCredentials(github.token, username);
                            github.loadUserData();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // 主题切换
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dark_mode_outlined, color: AppTheme.primaryGreen),
                          SizedBox(width: 12),
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
                SizedBox(height: 16),

                // 退出登录
                GlassCard(
                  onTap: () => github.setCredentials(null, null),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('清除数据', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // 关于
                Center(
                  child: Column(
                    children: [
                      Text('GitHub Dashboard v1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 4),
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
}

class _TokenField extends StatefulWidget {
  final String? token;
  final Function(String?) onSaved;
  const _TokenField({this.token, required this.onSaved});

  @override
  State<_TokenField> createState() => _TokenFieldState();
}

class _TokenFieldState extends State<_TokenField> {
  late TextEditingController _controller;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.token ?? '');
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
            obscureText: _obscure,
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ghp_xxxxxxxxxxxx',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => widget.onSaved(_controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('保存'),
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
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: '输入 GitHub 用户名',
              hintStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => widget.onSaved(_controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('查看'),
        ),
      ],
    );
  }
}
