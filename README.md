# GitHub Dashboard

一个美观的 GitHub 仪表盘 Flutter App，实时显示仓库数据和提交活跃度统计。

## ✨ 功能

- 📊 **仪表盘** - 用户信息卡片 + 总 Stars/Forks/Issues 统计
- 📚 **仓库列表** - 搜索筛选、多种排序方式
- 📈 **活跃度统计** - 语言分布、提交热力图、Top 仓库排行
- 🎨 **毛玻璃 UI** - 浅绿色主色调、深色/浅色主题切换
- 🔐 **Token 支持** - 无需 Token 也能查看公开数据

## 🚀 构建

### 环境要求
- Flutter >= 3.0.0
- Dart >= 3.0.0

### 构建 APK
```bash
flutter pub get
flutter build apk --release
```

### 构建 iOS
```bash
flutter pub get
flutter build ios --release
```

## 📱 截图

| 仪表盘 | 仓库列表 | 活跃度 |
|--------|---------|--------|
| 用户卡片 + 统计 | 搜索排序筛选 | 热力图 + 排行 |

## 🔧 技术栈

- Flutter + Dart
- Provider 状态管理
- GitHub REST API v3
- SharedPreferences 本地存储

## 📄 License

MIT
