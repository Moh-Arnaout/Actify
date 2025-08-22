import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart';
import 'package:mohammad_model/Home/home.dart';
import 'package:mohammad_model/Tracker/activity.dart';
import 'package:mohammad_model/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with TickerProviderStateMixin {
  List<ActivityLog> _allLogs = [];
  String _selectedPeriod = 'Week';
  final List<String> _periodOptions = ['Day', 'Week', 'Month', 'Year'];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadLogs();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('activity_logs') ?? [];

    setState(() {
      _allLogs = logs.map((log) => _parseLogEntry(log)).toList();
      _allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
    _animationController.forward();
  }

  ActivityLog _parseLogEntry(String logEntry) {
    final parts = logEntry.split(' at ');
    if (parts.length >= 2) {
      final activity = parts[0];
      final timestampStr = parts.sublist(1).join(' at ');
      try {
        final timestamp = DateTime.parse(timestampStr);
        return ActivityLog(activity: activity, timestamp: timestamp);
      } catch (e) {
        return ActivityLog(activity: activity, timestamp: DateTime.now());
      }
    }
    return ActivityLog(activity: logEntry, timestamp: DateTime.now());
  }

  Color _getActivityColor(String activity) {
    switch (activity) {
      case 'Jogging':
        return Colors.red;
      case 'Walking':
        return Colors.green;
      case 'Sitting':
        return Colors.purple;
      case 'Standing':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String activity) {
    switch (activity) {
      case 'Jogging':
        return Icons.directions_run;
      case 'Walking':
        return Icons.directions_walk;
      case 'Sitting':
        return Icons.chair;
      case 'Standing':
        return Icons.accessibility;
      default:
        return Icons.help_outline;
    }
  }

  List<ActivityLog> _getFilteredLogs() {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return _allLogs
        .where((log) => log.timestamp
            .isAfter(startDate.subtract(const Duration(seconds: 1))))
        .toList();
  }

  Map<String, int> _getActivityCounts() {
    final filteredLogs = _getFilteredLogs();
    Map<String, int> counts = {};
    for (var log in filteredLogs) {
      counts[log.activity] = (counts[log.activity] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, List<int>> _getDailyTrends() {
    final filteredLogs = _getFilteredLogs();
    Map<String, List<int>> trends = {};

    final now = DateTime.now();
    int days = _selectedPeriod == 'Day'
        ? 1
        : _selectedPeriod == 'Week'
            ? 7
            : _selectedPeriod == 'Month'
                ? 30
                : 365;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayKey = DateFormat('MM/dd').format(date);

      Map<String, int> dayActivities = {};
      for (var log in filteredLogs) {
        if (log.timestamp.day == date.day &&
            log.timestamp.month == date.month &&
            log.timestamp.year == date.year) {
          dayActivities[log.activity] = (dayActivities[log.activity] ?? 0) + 1;
        }
      }

      trends[dayKey] = ['Jogging', 'Walking', 'Sitting', 'Standing']
          .map((activity) => dayActivities[activity] ?? 0)
          .toList();
    }

    return trends;
  }

  String _getMostActiveTime() {
    final filteredLogs = _getFilteredLogs();
    if (filteredLogs.isEmpty) return 'No data available';

    Map<int, int> hourCounts = {};
    for (var log in filteredLogs) {
      final hour = log.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final mostActiveHour =
        hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return '${mostActiveHour.toString().padLeft(2, '0')}:00';
  }

  String _getMostActiveDay() {
    final filteredLogs = _getFilteredLogs();
    if (filteredLogs.isEmpty) return 'No data available';

    Map<int, int> dayCounts = {};
    for (var log in filteredLogs) {
      final weekday = log.timestamp.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }

    final mostActiveDay =
        dayCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[mostActiveDay - 1];
  }

  double _getAverageActivitiesPerDay() {
    final filteredLogs = _getFilteredLogs();
    if (filteredLogs.isEmpty) return 0.0;

    final days = _selectedPeriod == 'Day'
        ? 1
        : _selectedPeriod == 'Week'
            ? 7
            : _selectedPeriod == 'Month'
                ? 30
                : 365;

    return filteredLogs.length / days;
  }

  @override
  Widget build(BuildContext context) {
    final activityCounts = _getActivityCounts();
    final dailyTrends = _getDailyTrends();
    final totalActivities =
        activityCounts.values.fold(0, (sum, count) => sum + count);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Appcolors.primaryColor,
                Appcolors.secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => ActivityRecognitionScreen());
              },
              child: SvgPicture.asset(
                'Images/back.svg',
                width: 30,
                height: 30,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            const Text(
              'Activity Statistics',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Period Selection
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Appcolors.primaryColor, Appcolors.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Select Time Period',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _periodOptions.map((period) {
                        final isSelected = _selectedPeriod == period;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPeriod = period),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              period,
                              style: TextStyle(
                                color: isSelected
                                    ? Appcolors.primaryColor
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Overview Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOverviewCard(
                        'Total Activities',
                        totalActivities.toString(),
                        Icons.analytics,
                        Appcolors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOverviewCard(
                        'Daily Average',
                        _getAverageActivitiesPerDay().toStringAsFixed(1),
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Activity Breakdown Chart
              if (activityCounts.isNotEmpty)
                _buildActivityBreakdown(activityCounts),

              const SizedBox(height: 16),

              // Insights Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildInsightCard(
                      'Most Active Time',
                      _getMostActiveTime(),
                      Icons.access_time,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildInsightCard(
                      'Most Active Day',
                      _getMostActiveDay(),
                      Icons.calendar_today,
                      Colors.purple,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Daily Trends Chart
              if (dailyTrends.isNotEmpty) _buildDailyTrendsChart(dailyTrends),

              const SizedBox(height: 16),

              // Activity Details
              if (activityCounts.isNotEmpty)
                _buildActivityDetails(activityCounts, totalActivities),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown(Map<String, int> activityCounts) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: PieChartPainter(activityCounts, _getActivityColor),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: activityCounts.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getActivityColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTrendsChart(Map<String, List<int>> dailyTrends) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Activity Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: LineChartPainter(dailyTrends, _getActivityColor),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDetails(
      Map<String, int> activityCounts, int totalActivities) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...activityCounts.entries.map((entry) {
            final percentage = totalActivities > 0
                ? (entry.value / totalActivities * 100)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getActivityIcon(entry.key),
                            color: _getActivityColor(entry.key),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getActivityColor(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, int> data;
  final Color Function(String) getColor;

  PieChartPainter(this.data, this.getColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final total = data.values.fold(0, (sum, value) => sum + value);

    double startAngle = -math.pi / 2;

    for (var entry in data.entries) {
      final sweepAngle = 2 * math.pi * entry.value / total;
      final paint = Paint()
        ..color = getColor(entry.key)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius.toDouble()),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineChartPainter extends CustomPainter {
  final Map<String, List<int>> data;
  final Color Function(String) getColor;

  LineChartPainter(this.data, this.getColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final activities = ['Jogging', 'Walking', 'Sitting', 'Standing'];
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxValue = data.values
        .expand((list) => list)
        .reduce((a, b) => math.max(a, b))
        .toDouble();

    if (maxValue == 0) return;

    final stepX = size.width / (data.length - 1);
    final stepY = size.height / maxValue;

    for (int activityIndex = 0;
        activityIndex < activities.length;
        activityIndex++) {
      final activity = activities[activityIndex];
      paint.color = getColor(activity);

      final path = Path();
      bool isFirst = true;

      data.entries.toList().asMap().forEach((index, entry) {
        final value = entry.value[activityIndex].toDouble();
        final x = index * stepX;
        final y = size.height - (value * stepY);

        if (isFirst) {
          path.moveTo(x, y);
          isFirst = false;
        } else {
          path.lineTo(x, y);
        }

        // Draw points
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = getColor(activity));
      });

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ActivityLog {
  final String activity;
  final DateTime timestamp;

  ActivityLog({required this.activity, required this.timestamp});
}
