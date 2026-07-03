import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_user.dart';
import '../models/repository.dart';
import '../models/user_event.dart';

/// GitHub API 服务
class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'GitHub-Dashboard',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'token $_token';
    }
    return headers;
  }

  /// 获取用户信息
  Future<GitHubUser> getUser(String username) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$username'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return GitHubUser.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load user: ${response.statusCode}');
  }

  /// 获取当前认证用户
  Future<GitHubUser> getAuthenticatedUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return GitHubUser.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load user: ${response.statusCode}');
  }

  /// 获取用户仓库列表
  Future<List<Repository>> getUserRepos(String username, {int page = 1, int perPage = 100}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$username/repos?page=$page&per_page=$perPage&sort=updated'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Repository.fromJson(json)).toList();
    }
    throw Exception('Failed to load repos: ${response.statusCode}');
  }

  /// 获取认证用户仓库列表
  Future<List<Repository>> getAuthenticatedUserRepos({int page = 1, int perPage = 100}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/repos?page=$page&per_page=$perPage&sort=updated'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Repository.fromJson(json)).toList();
    }
    throw Exception('Failed to load repos: ${response.statusCode}');
  }

  /// 获取用户事件
  Future<List<UserEvent>> getUserEvents(String username, {int page = 1, int perPage = 30}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$username/events/public?page=$page&per_page=$perPage'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserEvent.fromJson(json)).toList();
    }
    throw Exception('Failed to load events: ${response.statusCode}');
  }

  /// 获取仓库语言统计
  Future<Map<String, int>> getRepoLanguages(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/languages'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load languages: ${response.statusCode}');
  }

  /// 获取仓库贡献者
  Future<List<Map<String, dynamic>>> getRepoContributors(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/contributors'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load contributors: ${response.statusCode}');
  }

  /// 获取提交活动（最近一年）
  Future<List<int>> getCommitActivity(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/stats/commit_activity'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<int> weeklyCommits = [];
      for (final week in data) {
        final days = week['total'] ?? 0;
        weeklyCommits.add(days as int);
      }
      return weeklyCommits;
    }
    return [];
  }

  /// 获取每周提交频率
  Future<List<int>> getWeeklyCommitFrequency(String owner, String repo) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/repos/$owner/$repo/stats/participation'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final all = data['all'] as List? ?? [];
      return all.cast<int>();
    }
    return [];
  }
}
