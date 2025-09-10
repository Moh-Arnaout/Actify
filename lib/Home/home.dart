import 'package:final_model_ai/AI/aibot.dart';
import 'package:final_model_ai/Home/fitnesscard.dart';
import 'package:final_model_ai/Home/healthcard.dart';
import 'package:final_model_ai/Metrics/metriccard.dart';
import 'package:final_model_ai/Tracker/activity2.dart';
import 'package:final_model_ai/Tracker/logs.dart';
import 'package:final_model_ai/bottombar.dart';
import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  final int initialIndex;

  const Homepage({super.key, this.initialIndex = 0});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Bottom navigation variables
  int _currentIndex = 0;

  Duration walkingDuration = Duration.zero;
  Duration sittingDuration = Duration.zero;
  Duration standingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadDurations();
  }

  Future<void> _loadDurations() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('activity_logs') ?? [];

    List<ActivityLog> parsedLogs =
        logs.map((log) => _parseLogEntry(log)).toList();
    parsedLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    List<ActivityGroup> groups = [];
    if (parsedLogs.isNotEmpty) {
      ActivityLog current = parsedLogs.first;
      DateTime start = current.timestamp;

      for (int i = 1; i < parsedLogs.length; i++) {
        ActivityLog next = parsedLogs[i];
        if (next.activity != current.activity) {
          groups.add(ActivityGroup(
              activity: current.activity,
              startTime: start,
              endTime: current.timestamp));
          current = next;
          start = next.timestamp;
        } else {
          current = next;
        }
      }
      groups.add(ActivityGroup(
          activity: current.activity,
          startTime: start,
          endTime: current.timestamp));
    }

    final today = DateTime.now();
    groups = groups
        .where((g) =>
            g.startTime.year == today.year &&
            g.startTime.month == today.month &&
            g.startTime.day == today.day)
        .toList();

    Duration walk = Duration.zero;
    Duration sit = Duration.zero;
    Duration stand = Duration.zero;

    for (var g in groups) {
      if (g.activity == "Walking") walk += g.duration;
      if (g.activity == "Sitting") sit += g.duration;
      if (g.activity == "Standing") stand += g.duration;
    }

    if (mounted) {
      setState(() {
        walkingDuration = walk;
        sittingDuration = sit;
        standingDuration = stand;
      });
    }
  }

  ActivityLog _parseLogEntry(String logEntry) {
    final parts = logEntry.split(' at ');
    if (parts.length >= 2) {
      final activity = parts[0];
      final timestampStr = parts.sublist(1).join(' at ');
      try {
        final timestamp = DateTime.parse(timestampStr);
        return ActivityLog(activity: activity, timestamp: timestamp);
      } catch (_) {
        return ActivityLog(activity: activity, timestamp: DateTime.now());
      }
    }
    return ActivityLog(activity: logEntry, timestamp: DateTime.now());
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return "${d.inHours}h ${d.inMinutes.remainder(60)}m";
    } else {
      return "${d.inMinutes}m";
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Card navigation methods - same as bottom bar behavior
  void _navigateToTracker() {
    _onTabTapped(1); // Same as pressing Activity Tracker tab
  }

  void _navigateToMetrics() {
    _onTabTapped(2); // Same as pressing Health Metrics tab
  }

  void _navigateToAIBot() {
    _onTabTapped(3); // Same as pressing AI Bot tab
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          _onTabTapped(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        bottomNavigationBar: Bottombar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
        // Use IndexedStack instead of PageView to preserve Scaffolds
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            const ActivityRecognitionScreen2(),
            const Metrics(),
            const Aibot(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Appcolors.secondaryColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.settings,
              color: Appcolors.tertiarycolor,
            ),
            Icon(
              Icons.notifications,
              color: Appcolors.tertiarycolor,
            ),
          ],
        ),
      ),
      backgroundColor: Appcolors.backcolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Appcolors.secondaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Row
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Appcolors.backcolor,
                          radius: 22,
                          backgroundImage: const AssetImage('Images/User2.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Hi, Mohammad!',
                                style: TextStyle(
                                  color: Appcolors.tertiarycolor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.waving_hand,
                                color: Colors.yellow,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Info Row
                    Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: Appcolors.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, yyyy-MM-dd').format(DateTime.now()),
                          style: TextStyle(
                            color: Appcolors.tertiarycolor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star,
                          color: Color.fromARGB(255, 238, 215, 41),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pro Member',
                          style: TextStyle(
                            color: Appcolors.tertiarycolor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Fitness Tracker Section
                  Row(
                    children: [
                      Text('Fitness And Activity Tracker',
                          style: TextStyle(
                              color: Appcolors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Your top 3 activities for today:',
                          style: TextStyle(
                              color: Appcolors.secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Fitness Cards with navigation
                  FitnessCard(
                      'Walking',
                      'You walked for ${_formatDuration(walkingDuration)} today!',
                      'Images/Walking.png'),
                  const SizedBox(height: 10),
                  FitnessCard(
                      'Sitting',
                      'You sat for ${_formatDuration(sittingDuration)} today!',
                      'Images/Sitting.png'),
                  const SizedBox(height: 10),
                  FitnessCard(
                      'Standing',
                      'You stood for ${_formatDuration(standingDuration)} today!',
                      'Images/Standing.png'),

                  const SizedBox(height: 20),

                  // Health Metrics Section
                  Row(
                    children: [
                      Text('Health Metrics',
                          style: TextStyle(
                              color: Appcolors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Your health indicators based on recent movements:',
                          style: TextStyle(
                              color: Appcolors.secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Health Cards with navigation
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Healthcard(
                            'Heart',
                            'Your heart is performing at 85%',
                            'Images/heart.png',
                            Appcolors.heart),
                        const SizedBox(width: 10),
                        const Healthcard('Lungs', 'Healthy breathing patterns',
                            'Images/lungs.png', Appcolors.lungs),
                        const SizedBox(width: 10),
                        const Healthcard('Joints', 'Good joint mobility',
                            'Images/bones1.png', Appcolors.joint),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // AI Chatbot Section
                  Row(
                    children: [
                      Text('Wellness AI Chatbot',
                          style: TextStyle(
                              color: Appcolors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // AI Bot Card
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(232, 0, 33, 89),
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        alignment: Alignment.centerRight,
                        image: AssetImage('Images/robot.png'),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Your Wellness \nAI Chatbot',
                              style: TextStyle(
                                color: Appcolors.tertiarycolor,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
