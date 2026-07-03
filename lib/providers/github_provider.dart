import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/github_user.dart';
import '../models/repository.dart';
import '../models/user_event.dart';
import '../services/github_service.dart';

/// GitHub 数据状态管理
class GitHubProvider extends ChangeNotifier {
  final GitHubService _service = GitHubService();
  
  GitHubUser? _user;
  List<Repository> _repos = [];
  List<UserEvent> _events = [];
  String? _token;
  String? _username;
  bool _isLoading = false;
  String? _error;

  // Getters
  GitHubUser? get user => _user;
  List<Repository> get repos => _repos;
  List<UserEvent> get events => _events;
  String? get token => _token;
  String? get username => _username;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

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

  GitHubProvider() {
    _loadSavedToken();
  }

  /// 加载保存的 Token
  Future<void> _loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('github_token');
    _username = prefs.getString('github_username');
    _service.setToken(_token);
    if (_username != null) {
      await loadUserData();
    }
    notifyListeners();
  }

  /// 设置 Token 和用户名
  Future<void> setCredentials(String? token, String? username) async {
    _token = token;
    _username = username;
    _service.setToken(token);
    
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('github_token', token);
    } else {
      await prefs.remove('github_token');
    }
    if (username != null) {
      await prefs.setString('github_username', username);
    } else {
      await prefs.remove('github_username');
    }
    
    notifyListeners();
  }

  /// 加载用户数据
  Future<void> loadUserData() async {
    if (_username == null && !isAuthenticated) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 获取用户信息
      if (isAuthenticated) {
        _user = await _service.getAuthenticatedUser();
        _username = _user!.login;
      } else if (_username != null) {
        _user = await _service.getUser(_username!);
      }

      // 获取仓库列表
      if (isAuthenticated) {
        _repos = await _service.getAuthenticatedUserRepos(perPage: 100);
      } else if (_username != null) {
        _repos = await _service.getUserRepos(_username!, perPage: 100);
      }

      // 获取事件
      if (_username != null) {
        _events = await _service.getUserEvents(_username!, perPage: 50);
      }
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
}

enum RepoSort { updated, stars, forks, issues }
