import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/github_user.dart';
import '../models/repository.dart';
import '../models/user_event.dart';
import '../services/github_service.dart';

/// GitHub 数据状态管理
class GitHubProvider extends ChangeNotifier {
  final GitHubService _service;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  GitHubUser? _user;
  List<Repository> _repos = [];
  List<UserEvent> _events = [];
  String? _username;
  bool _isLoading = false;
  String? _error;
  bool _hasToken = false;
  bool _initialized = false;

  // Getters
  GitHubUser? get user => _user;
  List<Repository> get repos => _repos;
  List<UserEvent> get events => _events;
  String? get username => _username;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasToken => _hasToken;
  bool get isAuthenticated => _hasToken;
  bool get initialized => _initialized;

  /// 统计数据
  int get totalStars => _repos.fold(0, (sum, r) => sum + r.stargazersCount);
  int get totalForks => _repos.fold(0, (sum, r) => sum + r.forksCount);
  int get totalIssues => _repos.fold(0, (sum, r) => sum + r.openIssuesCount);
  int get totalWatchers => _repos.fold(0, (sum, r) => sum + r.watchersCount);
  int get publicRepos => _repos.where((r) => !r.private).length;
  int get privateRepos => _repos.where((r) => r.private).length;

  /// 语言统计
  Map<String, int> get languageStats {
    final stats = <String, int>{};
    for (final repo in _repos) {
      if (repo.language != null) {
        stats[repo.language!] = (stats[repo.language!] ?? 0) + 1;
      }
    }
    return stats;
  }

  GitHubProvider({GitHubService? service})
      : _service = service ?? GitHubService();

  /// 初始化（加载已保存的 token 和用户名）
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('github_username');
    _hasToken = await _secureStorage.containsKey(key: 'github_token');
    if (_hasToken) {
      final token = await _secureStorage.read(key: 'github_token');
      _service.setToken(token);
    }
    _initialized = true;
    if (_username != null) {
      await loadUserData();
    } else {
      notifyListeners();
    }
  }

  /// 设置 Token 和用户名
  Future<void> setCredentials(String? token, String? username) async {
    _user = null;
    _repos = [];
    _events = [];
    _error = null;

    if (token != null && token.isNotEmpty) {
      _hasToken = true;
      _service.setToken(token);
      await _secureStorage.write(key: 'github_token', value: token);
    } else {
      _hasToken = false;
      _service.setToken(null);
      await _secureStorage.delete(key: 'github_token');
    }

    _username = username;
    final prefs = await SharedPreferences.getInstance();
    if (username != null && username.isNotEmpty) {
      await prefs.setString('github_username', username);
    } else {
      await prefs.remove('github_username');
    }

    notifyListeners();
  }

  /// 加载用户数据
  Future<void> loadUserData() async {
    if (_username == null && !_hasToken) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_hasToken) {
        _user = await _service.getAuthenticatedUser();
        _username = _user!.login;
      } else if (_username != null) {
        _user = await _service.getUser(_username!);
      }

      final reposFuture = _hasToken
          ? _service.getAuthenticatedUserRepos(perPage: 100)
          : (_username != null
              ? _service.getUserRepos(_username!, perPage: 100)
              : null);

      final eventsFuture = _username != null
          ? _service.getUserEvents(_username!, perPage: 50)
          : null;

      final results = await Future.wait([
        reposFuture ?? Future.value(<Repository>[]),
        eventsFuture ?? Future.value(<UserEvent>[]),
      ]);

      _repos = results[0] as List<Repository>;
      _events = results[1] as List<UserEvent>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadUserData();
  }

  /// 按名称搜索仓库
  List<Repository> searchRepos(String query) {
    if (query.isEmpty) return _repos;
    return _repos.where((r) =>
      r.name.toLowerCase().contains(query.toLowerCase()) ||
      (r.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  /// 排序仓库
  List<Repository> sortRepos(List<Repository> repos, RepoSort sort) {
    final sorted = List<Repository>.from(repos);
    switch (sort) {
      case RepoSort.updated:
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case RepoSort.stars:
        sorted.sort((a, b) => b.stargazersCount.compareTo(a.stargazersCount));
        break;
      case RepoSort.forks:
        sorted.sort((a, b) => b.forksCount.compareTo(a.forksCount));
        break;
      case RepoSort.issues:
        sorted.sort((a, b) => b.openIssuesCount.compareTo(a.openIssuesCount));
        break;
    }
    return sorted;
  }

  /// 获取 service 供子页面复用（已配置 token）
  GitHubService get service => _service;
}

enum RepoSort { updated, stars, forks, issues }
