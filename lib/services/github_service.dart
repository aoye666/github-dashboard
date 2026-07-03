import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_user.dart';
import '../models/repository.dart';
import '../models/user_event.dart';

/// GitHub API 异常类型
enum GitHubExceptionType {
  network,
  timeout,
  auth,
  rateLimit,
  notFound,
  server,
  unknown,
}

/// GitHub API 异常
class GitHubException implements Exception {
  final GitHubExceptionType type;
  final int? statusCode;
  final String message;

  GitHubException({
    required this.type,
    this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'GitHubException($type): $message';
}

/// GitHub API 服务
class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const int _maxRetriesFor202 = 3;
  static const Duration _retryDelay202 = Duration(seconds: 2);

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
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// 统一请求方法
  Future<http.Response> _request(
    String path, {
    Map<String, String>? query,
    bool retryOn202 = false,
    int attempt = 1,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: query,
    );

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return response;
      }

      if (response.statusCode == 202 && retryOn202 && attempt <= _maxRetriesFor202) {
        await Future.delayed(_retryDelay202 * attempt);
        return _request(path, query: query, retryOn202: true, attempt: attempt + 1);
      }

      switch (response.statusCode) {
        case 401:
          throw GitHubException(
            type: GitHubExceptionType.auth,
            statusCode: 401,
            message: 'Token 无效或已过期，请重新登录',
          );
        case 403:
          final resetAt = response.headers['x-ratelimit-reset'];
          final remaining = response.headers['x-ratelimit-remaining'];
          throw GitHubException(
            type: GitHubExceptionType.rateLimit,
            statusCode: 403,
            message: remaining == '0' && resetAt != null
                ? 'API 访问已达上限，请于 ${DateTime.fromMillisecondsSinceEpoch(int.parse(resetAt) * 1000).toLocal()} 后重试'
                : '请求被拒绝',
          );
        case 404:
          throw GitHubException(
            type: GitHubExceptionType.notFound,
            statusCode: 404,
            message: '资源不存在',
          );
        case >= 500:
          throw GitHubException(
            type: GitHubExceptionType.server,
            statusCode: response.statusCode,
            message: 'GitHub 服务器错误 (${response.statusCode})',
          );
        default:
          throw GitHubException(
            type: GitHubExceptionType.unknown,
            statusCode: response.statusCode,
            message: '请求失败 (${response.statusCode})',
          );
      }
    } on http.ClientException catch (e) {
      throw GitHubException(
        type: GitHubExceptionType.network,
        message: '网络连接失败：${e.message}',
      );
    } on TimeoutException {
      throw GitHubException(
        type: GitHubExceptionType.timeout,
        message: '请求超时，请检查网络后重试',
      );
    }
  }

  /// 获取用户信息
  Future<GitHubUser> getUser(String username) async {
    final response = await _request('/users/${Uri.encodeComponent(username)}');
    return GitHubUser.fromJson(jsonDecode(response.body));
  }

  /// 获取当前认证用户
  Future<GitHubUser> getAuthenticatedUser() async {
    final response = await _request('/user');
    return GitHubUser.fromJson(jsonDecode(response.body));
  }

  /// 获取用户仓库列表
  Future<List<Repository>> getUserRepos(String username, {int page = 1, int perPage = 100}) async {
    final response = await _request(
      '/users/${Uri.encodeComponent(username)}/repos',
      query: {'page': '$page', 'per_page': '$perPage', 'sort': 'updated'},
    );
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Repository.fromJson(json)).toList();
  }

  /// 获取认证用户仓库列表
  Future<List<Repository>> getAuthenticatedUserRepos({int page = 1, int perPage = 100}) async {
    final response = await _request(
      '/user/repos',
      query: {'page': '$page', 'per_page': '$perPage', 'sort': 'updated'},
    );
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Repository.fromJson(json)).toList();
  }

  /// 获取用户事件
  Future<List<UserEvent>> getUserEvents(String username, {int page = 1, int perPage = 30}) async {
    final response = await _request(
      '/users/${Uri.encodeComponent(username)}/events/public',
      query: {'page': '$page', 'per_page': '$perPage'},
    );
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => UserEvent.fromJson(json)).toList();
  }

  /// 获取仓库语言统计
  Future<Map<String, int>> getRepoLanguages(String owner, String repo) async {
    final response = await _request(
      '/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repo)}/languages',
    );
    return Map<String, int>.from(jsonDecode(response.body));
  }

  /// 获取仓库贡献者
  Future<List<Map<String, dynamic>>> getRepoContributors(String owner, String repo) async {
    final response = await _request(
      '/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repo)}/contributors',
    );
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  /// 获取提交活动（最近一年）
  Future<List<int>> getCommitActivity(String owner, String repo) async {
    final response = await _request(
      '/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repo)}/stats/commit_activity',
      retryOn202: true,
    );
    final List<dynamic> data = jsonDecode(response.body);
    final List<int> weeklyCommits = [];
    for (final week in data) {
      final days = week['total'] ?? 0;
      weeklyCommits.add(days as int);
    }
    return weeklyCommits;
  }

  /// 获取每周提交频率
  Future<List<int>> getWeeklyCommitFrequency(String owner, String repo) async {
    final response = await _request(
      '/repos/${Uri.encodeComponent(owner)}/${Uri.encodeComponent(repo)}/stats/participation',
      retryOn202: true,
    );
    final data = jsonDecode(response.body);
    final all = data['all'] as List? ?? [];
    return all.cast<int>();
  }
}
