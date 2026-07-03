import 'package:intl/intl.dart';

/// 格式化工具
class Formatters {
  /// 格式化数字（1000 -> 1k）
  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  /// 格式化日期（相对时间）
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return '刚刚';
    if (difference.inMinutes < 60) return '${difference.inMinutes}分钟前';
    if (difference.inHours < 24) return '${difference.inHours}小时前';
    if (difference.inDays < 7) return '${difference.inDays}天前';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}周前';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}个月前';
    return '${(difference.inDays / 365).floor()}年前';
  }

  /// 格式化完整日期
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// 格式化百分比
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}

/// String 首字母大写扩展
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
