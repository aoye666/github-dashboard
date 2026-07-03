/// GitHub 仓库模型
class Repository {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final bool private;
  final bool fork;
  final String htmlUrl;
  final String? homepage;
  final int stargazersCount;
  final int watchersCount;
  final int forksCount;
  final int openIssuesCount;
  final String defaultBranch;
  final String? language;
  final bool archived;
  final bool disabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime pushedAt;
  final int size;
  final List<String>? topics;

  Repository({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.private,
    required this.fork,
    required this.htmlUrl,
    this.homepage,
    required this.stargazersCount,
    required this.watchersCount,
    required this.forksCount,
    required this.openIssuesCount,
    required this.defaultBranch,
    this.language,
    required this.archived,
    required this.disabled,
    required this.createdAt,
    required this.updatedAt,
    required this.pushedAt,
    required this.size,
    this.topics,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      description: json['description'],
      private: json['private'] ?? false,
      fork: json['fork'] ?? false,
      htmlUrl: json['html_url'] ?? '',
      homepage: json['homepage'],
      stargazersCount: json['stargazers_count'] ?? 0,
      watchersCount: json['watchers_count'] ?? 0,
      forksCount: json['forks_count'] ?? 0,
      openIssuesCount: json['open_issues_count'] ?? 0,
      defaultBranch: json['default_branch'] ?? 'main',
      language: json['language'],
      archived: json['archived'] ?? false,
      disabled: json['disabled'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      pushedAt: DateTime.parse(json['pushed_at'] ?? DateTime.now().toIso8601String()),
      size: json['size'] ?? 0,
      topics: json['topics'] != null ? List<String>.from(json['topics']) : null,
    );
  }

  /// 仓库大小（格式化）
  String get formattedSize {
    if (size < 1024) return '${size}KB';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
