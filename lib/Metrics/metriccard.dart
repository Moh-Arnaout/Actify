import 'dart:async';
import 'package:final_model_ai/Tracker/logs.dart';
import 'package:final_model_ai/bottombar.dart';
import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'drawers.dart';
import 'metrics_methods.dart';

class Metrics extends StatefulWidget {
  const Metrics({super.key});

  @override
  State<Metrics> createState() => _MetricsState();
}

class _MetricsState extends State<Metrics> with TickerProviderStateMixin {
  int _selectedIndex = 2;
  List<ActivityLog> _logs = [];
  Map<String, dynamic> _healthMetrics = {};
  bool _isLoading = true;
  Timer? _refreshTimer;

  // **STORE ALL CHART DATA IN STATE**
  Map<String, double> _activityDurations = {};
  Map<String, dynamic> _healthScores = {};
  Map<String, List<double>> _weeklyTrends = {};
  List<ActivityGroup> _activityGroups = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLogs();

    // **FREQUENT AUTO-REFRESH FOR REAL-TIME UPDATES**
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadLogs();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Force fresh data
      final logs = prefs.getStringList('activity_logs') ?? [];

      if (logs.isEmpty) {
        setState(() {
          _logs = [];
          _activityDurations = _getDefaultDurations();
          _healthScores = _getDefaultScores();
          _weeklyTrends = _getDefaultTrends();
          _activityGroups = [];
          _healthMetrics = _getDefaultMetrics();
          _isLoading = false;
        });
        return;
      }

      // **USE EXACT SAME PARSING AND GROUPING AS LOGS**
      List<ActivityLog> parsedLogs =
          logs.map((log) => _parseLogEntry(log)).toList();
      parsedLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      List<ActivityGroup> groupedLogs =
          _groupActivitiesExactlyLikeLogs(parsedLogs);

      // **UPDATE ALL STATE VARIABLES**
      Map<String, double> newActivityDurations =
          _calculateDurationsFromGroups(groupedLogs);
      Map<String, dynamic> newHealthScores =
          _calculateSensitiveHealthScores(newActivityDurations);
      Map<String, List<double>> newWeeklyTrends =
          _calculateHourlyTrends(parsedLogs);

      setState(() {
        _logs = parsedLogs;
        _activityGroups = groupedLogs;
        _activityDurations = newActivityDurations;
        _healthScores = newHealthScores;
        _weeklyTrends = newWeeklyTrends;

        // **UPDATE COMPLETE METRICS OBJECT**
        _healthMetrics = {
          'activityDurations': _activityDurations,
          'healthScores': _healthScores,
          'weeklyTrends': _weeklyTrends,
          'totalActivities': _logs.length,
          'activeDays': _calculateActiveDays(_logs),
          'longestSession': _getLongestSession(groupedLogs),
          'averageSessionLength': _getAverageSessionLength(groupedLogs),
          'consistencyScore': _calculateConsistencyScore(_logs),
          'improvementTrend': 0.0,
        };
        _isLoading = false;
      });

      print('ALL METRICS UPDATED:');
      print('Activity Durations: $_activityDurations');
      print('Health Scores: $_healthScores');
      print('Weekly Trends: $_weeklyTrends');
    } catch (e) {
      print('Error loading logs: $e');
      setState(() {
        _logs = [];
        _activityDurations = _getDefaultDurations();
        _healthScores = _getDefaultScores();
        _weeklyTrends = _getDefaultTrends();
        _healthMetrics = _getDefaultMetrics();
        _isLoading = false;
      });
    }
  }

  // **EXACT SAME PARSING AS LOGS**
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

  // **EXACT SAME GROUPING LOGIC AS LOGS**
  List<ActivityGroup> _groupActivitiesExactlyLikeLogs(
      List<ActivityLog> parsedLogs) {
    List<ActivityGroup> groupedLogs = [];
    if (parsedLogs.isNotEmpty) {
      ActivityLog currentLog = parsedLogs.first;
      DateTime startTime = currentLog.timestamp;

      for (int i = 1; i < parsedLogs.length; i++) {
        ActivityLog nextLog = parsedLogs[i];

        if (nextLog.activity != currentLog.activity) {
          // Activity changed, create a group
          groupedLogs.add(ActivityGroup(
            activity: currentLog.activity,
            startTime: startTime,
            endTime:
                nextLog.timestamp, // Use NEXT activity's timestamp as end time
          ));

          // Start new group
          currentLog = nextLog;
          startTime = nextLog.timestamp;
        } else {
          // Same activity, update current log
          currentLog = nextLog;
        }
      }

      // Add the last group (ongoing activity)
      groupedLogs.add(ActivityGroup(
        activity: currentLog.activity,
        startTime: startTime,
        endTime:
            DateTime.now(), // Use current time for the last/ongoing activity
      ));
    }

    return groupedLogs;
  }

  Map<String, double> _calculateDurationsFromGroups(
      List<ActivityGroup> groups) {
    Map<String, double> durations = {
      'Walking': 0.0,
      'Jogging': 0.0,
      'Standing': 0.0,
      'Sitting': 0.0,
      'Lying': 0.0,
      'Upstairs': 0.0,
      'Downstairs': 0.0
    };

    for (var group in groups) {
      // **PRECISE DURATION CALCULATION INCLUDING FRACTIONAL MINUTES**
      double exactMinutes = group.duration.inSeconds / 60.0;

      String activity = group.activity;
      if (durations.containsKey(activity)) {
        durations[activity] = (durations[activity] ?? 0) + exactMinutes;
      } else {
        durations[activity] = exactMinutes;
      }
    }

    return durations;
  }

// **MORE SENSITIVE SCORING - SMALLER CHANGES MATTER**
  Map<String, dynamic> _calculateSensitiveHealthScores(
      Map<String, double> durations) {
    double totalMinutes =
        durations.values.fold(0.0, (sum, duration) => sum + duration);

    if (totalMinutes == 0) {
      return {'heart': 50, 'lungs': 50, 'joints': 50, 'overall': 50};
    }

    // Activity variables
    double joggingMinutes = durations['Jogging'] ?? 0;
    double walkingMinutes = durations['Walking'] ?? 0;
    double stairsMinutes =
        (durations['Upstairs'] ?? 0) + (durations['Downstairs'] ?? 0);
    double standingMinutes = durations['Standing'] ?? 0;
    double sedentaryMinutes =
        (durations['Sitting'] ?? 0) + (durations['Lying'] ?? 0);

    // **1. HEART SCORE CALCULATION**
    double heartBase = 50;
    double heartBonus = 0;

    // Increased multipliers for faster response
    if (joggingMinutes > 0) heartBonus += math.min(joggingMinutes * 4.0, 35);
    if (walkingMinutes > 0) heartBonus += math.min(walkingMinutes * 2.0, 25);
    if (stairsMinutes > 0) heartBonus += math.min(stairsMinutes * 3.0, 20);

    // Reduced penalty threshold (was 60 minutes, now 30)
    double sedentaryPenalty =
        sedentaryMinutes > 30 ? math.min((sedentaryMinutes - 30) * 0.2, 15) : 0;

    double heartScore =
        (heartBase + heartBonus - sedentaryPenalty).clamp(20, 95);

    // **2. LUNGS SCORE CALCULATION**
    double lungsBase = 50;
    double lungsBonus = 0;

    // All aerobic activities benefit lungs
    double aerobicMinutes =
        joggingMinutes + (walkingMinutes * 0.8) + (stairsMinutes * 1.2);
    if (aerobicMinutes > 0)
      lungsBonus += math.min(aerobicMinutes * 2.2, 42); // Was 1.8

    // No sedentary penalty for lungs - they don't deteriorate as quickly
    double lungsScore = (lungsBase + lungsBonus).clamp(25, 95);

    // **3. JOINTS SCORE CALCULATION**
    double jointsBase = 50;
    double jointsBonus = 0;

    // All movement activities benefit joints
    double movementMinutes =
        walkingMinutes + (standingMinutes * 0.6) + (stairsMinutes * 1.1);
    if (movementMinutes > 0)
      jointsBonus += math.min(movementMinutes * 2.5, 40); // Was 1.5

    // Reduced sitting penalty threshold (was 120 minutes, now 90)
    double prolongedSittingPenalty = (durations['Sitting'] ?? 0) > 90 ? 12 : 0;

    double jointsScore =
        (jointsBase + jointsBonus - prolongedSittingPenalty).clamp(20, 95);

    // **4. OVERALL SCORE CALCULATION**
    double overallScore = (heartScore + lungsScore + jointsScore) / 3;
    overallScore = overallScore.clamp(20, 95);

    return {
      'heart': heartScore.round(),
      'lungs': lungsScore.round(),
      'joints': jointsScore.round(),
      'overall': overallScore.round(),
    };
  }

  // **WEEKLY TRENDS FOR CHARTS**
// Instead of weekly trends, use last 24 hours with hourly granularity
  Map<String, List<double>> _calculateHourlyTrends(List<ActivityLog> logs) {
    List<double> heartTrend = [];
    List<double> lungsTrend = [];
    List<double> jointsTrend = [];

    DateTime now = DateTime.now();

    // **SHOW LAST 12 HOURS WITH 1-HOUR INTERVALS**
    for (int i = 11; i >= 0; i--) {
      DateTime targetHour = now.subtract(Duration(hours: i));

      List<ActivityLog> hourLogs = logs
          .where((log) =>
              log.timestamp.isAfter(targetHour.subtract(Duration(hours: 1))) &&
              log.timestamp.isBefore(targetHour))
          .toList();

      if (hourLogs.isNotEmpty) {
        List<ActivityGroup> hourGroups =
            _groupActivitiesExactlyLikeLogs(hourLogs);
        Map<String, double> hourDurations =
            _calculateDurationsFromGroups(hourGroups);
        Map<String, dynamic> hourScores =
            _calculateSensitiveHealthScores(hourDurations);

        heartTrend.add(hourScores['heart'].toDouble());
        lungsTrend.add(hourScores['lungs'].toDouble());
        jointsTrend.add(hourScores['joints'].toDouble());
      } else {
        // **USE PREVIOUS VALUE OR BASELINE**
        double prevHeart = heartTrend.isNotEmpty ? heartTrend.last : 50.0;
        heartTrend.add(prevHeart);
        lungsTrend.add(lungsTrend.isNotEmpty ? lungsTrend.last : 50.0);
        jointsTrend.add(jointsTrend.isNotEmpty ? jointsTrend.last : 50.0);
      }
    }

    return {
      'heart': heartTrend,
      'lungs': lungsTrend,
      'joints': jointsTrend,
    };
  }

  // **DEFAULT VALUES**
  Map<String, double> _getDefaultDurations() {
    return {
      'Walking': 0.0,
      'Jogging': 0.0,
      'Standing': 0.0,
      'Sitting': 0.0,
      'Lying': 0.0,
      'Upstairs': 0.0,
      'Downstairs': 0.0
    };
  }

  Map<String, dynamic> _getDefaultScores() {
    return {'heart': 50, 'lungs': 50, 'joints': 50, 'overall': 50};
  }

  Map<String, List<double>> _getDefaultTrends() {
    return {
      'heart': [50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0],
      'lungs': [50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0],
      'joints': [50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0]
    };
  }

  Map<String, dynamic> _getDefaultMetrics() {
    return {
      'activityDurations': _getDefaultDurations(),
      'timeMetrics': {
        'totalMinutes': 0,
        'activeMinutes': 0,
        'sedentaryMinutes': 0,
        'mostActiveHour': 12,
        'peakActivity': 'Unknown'
      },
      'healthScores': _getDefaultScores(),
      'weeklyTrends': _getDefaultTrends(),
      'totalActivities': 0,
      'activeDays': 0,
      'longestSession': {'activity': 'None', 'duration': 0.0},
      'averageSessionLength': 0.0,
      'consistencyScore': 0,
      'improvementTrend': 0.0,
    };
  }

  // **SUPPORTING METHODS**
  int _calculateActiveDays(List<ActivityLog> logs) {
    Set<String> days = logs
        .map((log) =>
            '${log.timestamp.year}-${log.timestamp.month}-${log.timestamp.day}')
        .toSet();
    return days.length;
  }

  Map<String, dynamic> _getLongestSession(List<ActivityGroup> groups) {
    if (groups.isEmpty) return {'activity': 'None', 'duration': 0.0};

    ActivityGroup longest = groups
        .reduce((a, b) => a.duration.inMinutes > b.duration.inMinutes ? a : b);

    return {
      'activity': longest.activity,
      'duration': longest.duration.inMinutes.toDouble(),
    };
  }

  double _getAverageSessionLength(List<ActivityGroup> groups) {
    if (groups.isEmpty) return 0.0;

    double totalMinutes =
        groups.fold(0.0, (sum, group) => sum + group.duration.inMinutes);
    return totalMinutes / groups.length;
  }

  int _calculateConsistencyScore(List<ActivityLog> logs) {
    if (logs.length < 7) return logs.length * 10;

    int activeDays = _calculateActiveDays(logs);
    int totalDays =
        logs.last.timestamp.difference(logs.first.timestamp).inDays + 1;

    return ((activeDays / math.min(totalDays, 30)) * 100).round();
  }

  Future<void> _refreshMetrics() async {
    setState(() => _isLoading = true);
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.backcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Health Metrics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Appcolors.primaryColor, Appcolors.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshMetrics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Card
                    Card(
                      color: Appcolors.tertiarycolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Your Health Dashboard',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Appcolors.primaryColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        Appcolors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_healthScores['overall'] ?? 50}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Appcolors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.autorenew,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                const Text(
                                  'Live updates every 5 seconds',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // **HEALTH METRICS CARDS - ALL UPDATE WITH NEW DATA**
                    Column(
                      children: [
                        EnhancedHeartMetricCard(healthMetrics: _healthMetrics),
                        const SizedBox(height: 16),
                        EnhancedLungsMetricCard(healthMetrics: _healthMetrics),
                        const SizedBox(height: 16),
                        EnhancedJointsMetricCard(healthMetrics: _healthMetrics),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
