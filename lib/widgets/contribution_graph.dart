import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// GitHub 贡献热力图组件
class ContributionGraph extends StatelessWidget {
  final List<int> weeklyData; // 每周提交数，最近52周

  const ContributionGraph({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = weeklyData.fold(0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 热力图网格
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weeklyData.length, (weekIndex) {
              final intensity = weeklyData[weekIndex] == 0 
                ? 0.0 
                : (weeklyData[weekIndex] / (weeklyData.reduce((a, b) => a > b ? a : b).clamp(1, 999))).clamp(0.15, 1.0);
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(7, (dayIndex) {
                    final dayIntensity = (dayIndex % 2 == 0) ? intensity : intensity * 0.7;
                    return Container(
                      width: 10,
                      height: 10,
                      margin: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(dayIntensity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 8),
        // 图例
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('最近52周提交：$total', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Row(
              children: [
                Text('少 ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ...List.generate(5, (i) => Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(i * 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
                Text(' 多', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
