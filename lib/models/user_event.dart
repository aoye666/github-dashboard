/// GitHub 用户事件模型（提交、PR、Issue 等）
class UserEvent {
  final String id;
  final String type;
  final String repoName;
  final DateTime createdAt;
  final Map<String, dynamic> payload;

  UserEvent({
    required this.id,
    required this.type,
    required this.repoName,
    required this.createdAt,
    required this.payload,
  });

  factory UserEvent.fromJson(Map<String, dynamic> json) {
    final repo = json['repo'] as Map<String, dynamic>? ?? {};
    return UserEvent(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      repoName: repo['name'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      payload: json['payload'] ?? {},
    );
  }

  /// 事件描述
  String get description {
    switch (type) {
      case 'PushEvent':
        final commits = payload['commits'] as List? ?? [];
        return 'Pushed ${commits.length} commit(s)';
      case 'CreateEvent':
        return 'Created ${payload['ref_type'] ?? 'repository'}';
      case 'DeleteEvent':
        return 'Deleted ${payload['ref_type'] ?? 'branch'}';
      case 'IssuesEvent':
        return '${(payload['action'] ?? 'opened').toString().capitalize()} issue';
      case 'PullRequestEvent':
        return '${(payload['action'] ?? 'opened').toString().capitalize()} pull request';
      case 'WatchEvent':
        return 'Starred repository';
      case 'ForkEvent':
        return 'Forked repository';
      case 'ReleaseEvent':
        return 'Published release';
      default:
        return type.replaceAll('Event', '');
    }
  }

  /// 事件图标
  String get icon {
    switch (type) {
      case 'PushEvent':
        return '⬆️';
      case 'CreateEvent':
        return '🆕';
      case 'DeleteEvent':
        return '🗑️';
      case 'IssuesEvent':
        return '🐛';
      case 'PullRequestEvent':
        return '🔀';
      case 'WatchEvent':
        return '⭐';
      case 'ForkEvent':
        return '🍴';
      case 'ReleaseEvent':
        return '📦';
      default:
        return '📌';
    }
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
