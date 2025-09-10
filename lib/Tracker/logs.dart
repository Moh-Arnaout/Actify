import 'package:final_model_ai/Tracker/activity2.dart';
import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LogsPage extends StatefulWidget {
  final List<String> activityLogs;
  const LogsPage({super.key, required this.activityLogs});

  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<ActivityGroup> _allGroups = [];
  List<ActivityGroup> _filteredGroups = [];
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Jogging',
    'Walking',
    'Upstairs', // Added
    'Downstairs', // Added
    'Sitting',
    'Standing',
    'Lying' // Added
  ];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('activity_logs') ?? [];

    // Parse all logs
    List<ActivityLog> parsedLogs =
        logs.map((log) => _parseLogEntry(log)).toList();
    parsedLogs.sort(
        (a, b) => a.timestamp.compareTo(b.timestamp)); // Sort by oldest first

    // Group consecutive activities
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
      // For the last activity, use current time as end time if it's still ongoing
      groupedLogs.add(ActivityGroup(
        activity: currentLog.activity,
        startTime: startTime,
        endTime:
            DateTime.now(), // Use current time for the last/ongoing activity
      ));
    }

    setState(() {
      _allGroups =
          groupedLogs.reversed.toList(); // Reverse to show newest first
      _filteredGroups = List.from(_allGroups);
    });
  }

  ActivityLog _parseLogEntry(String logEntry) {
    // Parse format: "Activity at 2024-01-15 14:30:25.123"
    final parts = logEntry.split(' at ');
    if (parts.length >= 2) {
      final activity = parts[0];
      final timestampStr = parts.sublist(1).join(' at ');
      try {
        final timestamp = DateTime.parse(timestampStr);
        return ActivityLog(activity: activity, timestamp: timestamp);
      } catch (e) {
        // Fallback for parsing errors
        return ActivityLog(activity: activity, timestamp: DateTime.now());
      }
    }
    return ActivityLog(activity: logEntry, timestamp: DateTime.now());
  }

  void _filterLogs(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredGroups = List.from(_allGroups);
      } else {
        _filteredGroups =
            _allGroups.where((group) => group.activity == filter).toList();
      }
    });
  }

  Future<void> _clearLogs() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Logs'),
          content: const Text(
              'Are you sure you want to clear all activity logs? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('activity_logs');
                setState(() {
                  _allGroups.clear();
                  _filteredGroups.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('All logs cleared successfully')),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
      case 'Upstairs':
        return Colors.blue;
      case 'Downstairs':
        return Colors.orange;
      case 'Lying':
        return Colors.indigo;
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
      case 'Upstairs':
        return Icons.keyboard_arrow_up; // ⬆️ Up arrow
      case 'Downstairs':
        return Icons.keyboard_arrow_down; // ⬇️ Down arrow
      case 'Lying':
        return Icons.hotel; // 🛏️ Bed icon

      default:
        return Icons.help_outline;
    }
  }

  Map<String, int> _getActivityStats() {
    Map<String, int> stats = {};
    for (var group in _allGroups) {
      stats[group.activity] = (stats[group.activity] ?? 0) + 1;
    }
    return stats;
  }

  String _formatDurationGroup(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$minutes:$seconds mins';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getActivityStats();
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
                Get.back();
              },
              child: SvgPicture.asset(
                'Images/back.svg',
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text(
              'Activity Logs',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stats Overview
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Activity Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                        'Total', _allGroups.length.toString(), Icons.analytics),
                    _buildStatCard(
                        'Today', _getTodayCount().toString(), Icons.today),
                    _buildStatCard('This Week', _getWeekCount().toString(),
                        Icons.date_range),
                  ],
                ),
              ],
            ),
          ),
          // Filter Options
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : Appcolors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => _filterLogs(filter),
                    backgroundColor: Colors.white,
                    selectedColor: Appcolors.joint,
                    elevation: 2,
                  ),
                );
              },
            ),
          ),
          // Logs List
          Expanded(
            child: _filteredGroups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activity logs found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start tracking your activities to see logs here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = _filteredGroups[index];
                      final formattedDuration =
                          _formatDurationGroup(group.duration);
                      final timeAgo =
                          DateTime.now().difference(group.startTime);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getActivityColor(group.activity)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getActivityIcon(group.activity),
                              color: _getActivityColor(group.activity),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            group.activity,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy - hh:mm a')
                                    .format(group.startTime),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formattedDuration,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(timeAgo),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  int _getTodayCount() {
    final today = DateTime.now();
    return _allGroups.where((group) {
      return group.startTime.day == today.day &&
          group.startTime.month == today.month &&
          group.startTime.year == today.year;
    }).length;
  }

  int _getWeekCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _allGroups.where((group) {
      return group.startTime
          .isAfter(weekStart.subtract(const Duration(days: 1)));
    }).length;
  }
}

class ActivityLog {
  final String activity;
  final DateTime timestamp;
  ActivityLog({required this.activity, required this.timestamp});
}

class ActivityGroup {
  final String activity;
  final DateTime startTime;
  final DateTime endTime;

  ActivityGroup({
    required this.activity,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}
