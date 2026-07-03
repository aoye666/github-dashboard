/// 提交活跃度统计模型
class ContributionStats {
  final int total;
  final List<int> days; // 每周7天的提交数

  ContributionStats({
    required this.total,
    required this.days,
  });

  factory ContributionStats.fromJson(Map<String, dynamic> json) {
    return ContributionStats(
      total: json['total'] ?? 0,
      days: List<int>.from((json['days'] ?? []).map((e) => e ?? 0)),
    );
  }
}

/// 每周提交数据
class WeeklyCommitData {
  final DateTime weekStart;
  final List<int> days; // 7天的提交数

  WeeklyCommitData({
    required this.weekStart,
    required this.days,
  });

  int get total => days.fold(0, (a, b) => a + b);

  factory WeeklyCommitData.fromJson(List<dynamic> json) {
    final total = json[0] as int? ?? 0;
    final days = List<int>.from((json[1] as List? ?? []).map((e) => e ?? 0));
    return WeeklyCommitData(
      weekStart: DateTime.now().subtract(Duration(days: days.length * 7)),
      days: days,
    );
  }
}

/// 语言统计数据
class LanguageStats {
  final String name;
  final int bytes;
  final Color color;

  LanguageStats({
    required this.name,
    required this.bytes,
    required this.color,
  });

  static final Map<String, Color> _languageColors = {
    'Dart': Color(0xFF00B4AB),
    'JavaScript': Color(0xFFF1E05A),
    'TypeScript': Color(0xFF2B7489),
    'Python': Color(0xFF3572A5),
    'Java': Color(0xFFB07219),
    'Kotlin': Color(0xFFA97BFF),
    'Swift': Color(0xFFF05138),
    'Go': Color(0xFF00ADD8),
    'Rust': Color(0xFFDEA584),
    'C++': Color(0xFFF34B7D),
    'C': Color(0xFF555555),
    'C#': Color(0xFF178600),
    'Ruby': Color(0xFF701516),
    'PHP': Color(0xFF4F5D95),
    'HTML': Color(0xFFE34C26),
    'CSS': Color(0xFF563D7C),
    'Vue': Color(0xFF41B883),
    'Shell': Color(0xFF89E051),
    'Lua': Color(0xFF000080),
    'Dockerfile': Color(0xFF384D54),
    'YAML': Color(0xFFCB171E),
    'Markdown': Color(0xFF083FA1),
  };

  static Color getColor(String name) {
    return _languageColors[name] ?? Color(0xFF999999);
  }
}
