import 'package:flutter/material.dart';
import 'package:mohammad_model/Tracker/logs.dart';
import 'package:mohammad_model/bottombar.dart';
import 'package:mohammad_model/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Metrics extends StatefulWidget {
  const Metrics({super.key});

  @override
  State<Metrics> createState() => _MetricsState();
}

class _MetricsState extends State<Metrics> {
  int _selectedIndex = 2;
  List<ActivityLog> _logs = [];
  Map<String, double> _activityStats = {};
  bool _isLoading = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('activity_logs') ?? [];

    List<ActivityLog> parsedLogs = logs.map((e) => _parseLogEntry(e)).toList();

    // Calculate activity statistics
    Map<String, double> stats = _calculateActivityStats(parsedLogs);

    setState(() {
      _logs = parsedLogs;
      _activityStats = stats;
      _isLoading = false;
    });
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

  Map<String, double> _calculateActivityStats(List<ActivityLog> logs) {
    if (logs.isEmpty) {
      return {
        'totalMinutes': 0,
        'activeMinutes': 0,
        'sedentaryMinutes': 0,
        'walkingMinutes': 0,
        'joggingMinutes': 0,
        'standingMinutes': 0,
        'sittingMinutes': 0,
        'heartScore': 50,
        'lungsScore': 50,
        'jointsScore': 50,
      };
    }

    // Group consecutive activities to calculate durations
    Map<String, double> activityMinutes = {
      'Walking': 0,
      'Jogging': 0,
      'Standing': 0,
      'Sitting': 0,
    };

    // Sort logs by timestamp
    logs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (int i = 0; i < logs.length - 1; i++) {
      String currentActivity = logs[i].activity;
      DateTime currentTime = logs[i].timestamp;
      DateTime nextTime = logs[i + 1].timestamp;

      double duration = nextTime.difference(currentTime).inMinutes.toDouble();

      // Cap duration at reasonable limits (e.g., 4 hours max between logs)
      if (duration > 240) duration = 10; // Default 10 minutes if gap too large

      activityMinutes[currentActivity] =
          (activityMinutes[currentActivity] ?? 0) + duration;
    }

    double totalMinutes = activityMinutes.values.reduce((a, b) => a + b);
    double activeMinutes =
        (activityMinutes['Walking'] ?? 0) + (activityMinutes['Jogging'] ?? 0);
    double sedentaryMinutes = (activityMinutes['Sitting'] ?? 0);

    // Calculate health scores based on activity patterns
    double heartScore = _calculateHeartScore(activityMinutes, totalMinutes);
    double lungsScore = _calculateLungsScore(activityMinutes, totalMinutes);
    double jointsScore = _calculateJointsScore(activityMinutes, totalMinutes);

    return {
      'totalMinutes': totalMinutes,
      'activeMinutes': activeMinutes,
      'sedentaryMinutes': sedentaryMinutes,
      'walkingMinutes': activityMinutes['Walking'] ?? 0,
      'joggingMinutes': activityMinutes['Jogging'] ?? 0,
      'standingMinutes': activityMinutes['Standing'] ?? 0,
      'sittingMinutes': activityMinutes['Sitting'] ?? 0,
      'heartScore': heartScore,
      'lungsScore': lungsScore,
      'jointsScore': jointsScore,
    };
  }

  double _calculateHeartScore(Map<String, double> activities, double total) {
    if (total == 0) return 50;

    double jogging = activities['Jogging'] ?? 0;
    double walking = activities['Walking'] ?? 0;
    double sitting = activities['Sitting'] ?? 0;

    // Heart score based on cardio activities vs sedentary time
    double cardioRatio =
        (jogging * 2 + walking) / total; // Jogging counts double
    double sedentaryPenalty = (sitting / total) * 0.3; // Sitting penalty

    double score = (cardioRatio * 100) - (sedentaryPenalty * 100);
    return (score.clamp(20, 95)).roundToDouble();
  }

  double _calculateLungsScore(Map<String, double> activities, double total) {
    if (total == 0) return 50;

    double jogging = activities['Jogging'] ?? 0;
    double walking = activities['Walking'] ?? 0;

    // Lungs score based on aerobic activities
    double aerobicRatio = (jogging * 1.5 + walking * 0.8) / total;

    double score = aerobicRatio * 120; // Higher multiplier for lungs
    return (score.clamp(30, 95)).roundToDouble();
  }

  double _calculateJointsScore(Map<String, double> activities, double total) {
    if (total == 0) return 50;

    double walking = activities['Walking'] ?? 0;
    double standing = activities['Standing'] ?? 0;
    double sitting = activities['Sitting'] ?? 0;

    // Joints score based on movement variety and avoiding prolonged sitting
    double movementRatio = (walking + standing * 0.5) / total;
    double sittingPenalty = (sitting / total) * 0.4;

    double score = (movementRatio * 100) - (sittingPenalty * 100);
    return (score.clamp(25, 95)).roundToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Bottombar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      backgroundColor: Appcolors.backcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Health Metrics ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        elevation: 1,
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
                                Text(
                                  'Your Health at a Glance',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Appcolors.primaryColor,
                                  ),
                                ),
                                Image.asset(
                                  'Images/heart.png',
                                  scale: 15,
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.3,
                                  child: Text(
                                    _logs.isEmpty
                                        ? 'Start tracking your activities to see personalized health insights based on your movement patterns.'
                                        : 'Your scores are based on how you\'ve balanced walking, sitting, and resting — showing how your activity supports your heart, lungs, and joints.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Health Metrics Cards
                    Column(
                      children: [
                        HeartMetricCard(activityStats: _activityStats),
                        const SizedBox(height: 16),
                        LungsMetricCard(activityStats: _activityStats),
                        const SizedBox(height: 16),
                        JointsMetricCard(activityStats: _activityStats),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Heart Metric Card
class HeartMetricCard extends StatefulWidget {
  final Map<String, double> activityStats;

  const HeartMetricCard({super.key, required this.activityStats});

  @override
  State<HeartMetricCard> createState() => _HeartMetricCardState();
}

class _HeartMetricCardState extends State<HeartMetricCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double heartScore = widget.activityStats['heartScore'] ?? 50;
    double activeMinutes = widget.activityStats['activeMinutes'] ?? 0;
    double totalMinutes = widget.activityStats['totalMinutes'] ?? 1;
    double sedentaryPercent = totalMinutes > 0
        ? ((widget.activityStats['sittingMinutes'] ?? 0) / totalMinutes * 100)
        : 0;
    double joggingMinutes = widget.activityStats['joggingMinutes'] ?? 0;

    return GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Appcolors.heart, Color(0xFFFC8181)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53E3E).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Heart',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Heart Rate Visualization
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: HeartRatePainter(),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  'Your heart is performing at ${heartScore.toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                // Expanding part
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Row of metrics
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetric(
                                    Icons.directions_walk,
                                    "Active Minutes",
                                    "${activeMinutes.toInt()}/day"),
                                _buildMetric(
                                    Icons.access_time,
                                    "Sedentary Time",
                                    "${sedentaryPercent.toInt()}%"),
                                _buildMetric(
                                    Icons.directions_run,
                                    "High Intensity",
                                    "${joggingMinutes.toInt()} min"),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24),

                            // Fixed Heart-specific Insights
                            _buildInsight(
                              "Aim for 30+ minutes of moderate activity daily for optimal heart health.",
                            ),
                            _buildInsight(
                              "Break up sitting time every 30-60 minutes to improve circulation.",
                            ),
                            _buildInsight(
                              "Include 2-3 high-intensity sessions per week to strengthen your heart.",
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                )
              ],
            ),
          ),
        ));
  }

  // Helper Widgets
  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildInsight(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Appcolors.tertiarycolor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lungs Metric Card
class LungsMetricCard extends StatefulWidget {
  final Map<String, double> activityStats;

  const LungsMetricCard({super.key, required this.activityStats});

  @override
  State<LungsMetricCard> createState() => _LungsMetricCardState();
}

class _LungsMetricCardState extends State<LungsMetricCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double lungsScore = widget.activityStats['lungsScore'] ?? 50;
    double activeMinutes = widget.activityStats['activeMinutes'] ?? 0;
    double walkingMinutes = widget.activityStats['walkingMinutes'] ?? 0;
    double joggingMinutes = widget.activityStats['joggingMinutes'] ?? 0;

    String lungsStatus = lungsScore >= 70
        ? "Excellent breathing patterns"
        : lungsScore >= 50
            ? "Good breathing patterns"
            : "Needs improvement";

    return GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Appcolors.lungs, Color(0xFF63B3ED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3182CE).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lungs',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.air,
                            color: Colors.white,
                            size: 28,
                          ),
                          if (lungsScore >= 70)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Lungs Visualization
                Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CustomPaint(
                      painter: LungsPainter(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Always visible text
                Text(
                  lungsStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                // Expanding details
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Row of metrics
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetric(Icons.directions_walk, "Walking",
                                    "${walkingMinutes.toInt()} min"),
                                _buildMetric(Icons.directions_run, "Jogging",
                                    "${joggingMinutes.toInt()} min"),
                                _buildMetric(Icons.trending_up, "Lung Score",
                                    "${lungsScore.toInt()}%"),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24),

                            // Fixed Lungs-specific Insights
                            _buildInsight(
                              "Deep breathing exercises can improve lung capacity and oxygen flow.",
                            ),
                            _buildInsight(
                              "Regular aerobic activity strengthens respiratory muscles effectively.",
                            ),
                            _buildInsight(
                              "Consider outdoor activities for fresh air and natural breathing patterns.",
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                )
              ],
            ),
          ),
        ));
  }

  // Helper Widgets
  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildInsight(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Appcolors.tertiarycolor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Joints Metric Card
class JointsMetricCard extends StatefulWidget {
  final Map<String, double> activityStats;

  const JointsMetricCard({super.key, required this.activityStats});

  @override
  State<JointsMetricCard> createState() => _JointsMetricCardState();
}

class _JointsMetricCardState extends State<JointsMetricCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double jointsScore = widget.activityStats['jointsScore'] ?? 50;
    double walkingMinutes = widget.activityStats['walkingMinutes'] ?? 0;
    double standingMinutes = widget.activityStats['standingMinutes'] ?? 0;
    double totalMinutes = widget.activityStats['totalMinutes'] ?? 1;
    double mobilityPercent = jointsScore;

    String jointsStatus = jointsScore >= 75
        ? "Excellent joint mobility"
        : jointsScore >= 50
            ? "Good joint mobility"
            : "Needs more movement";

    return GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Appcolors.joint, Color(0xFF68D391)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38A169).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Joints',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.accessibility_new,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Joints Health Indicator
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: const Icon(
                        Icons.directions_run,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Flexibility',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: mobilityPercent / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${mobilityPercent.toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Always visible
                Text(
                  jointsStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                // Expanding part
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Row of metrics
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetric(Icons.directions_walk, "Walking",
                                    "${walkingMinutes.toInt()} min"),
                                _buildMetric(Icons.accessibility, "Standing",
                                    "${standingMinutes.toInt()} min"),
                                _buildMetric(Icons.trending_up, "Joint Score",
                                    "${jointsScore.toInt()}%"),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24),

                            // Fixed Joints-specific Insights
                            _buildInsight(
                              "Regular movement prevents joint stiffness and maintains flexibility.",
                            ),
                            _buildInsight(
                              "Include stretching and mobility exercises in your daily routine.",
                            ),
                            _buildInsight(
                              "Weight-bearing activities like walking help strengthen joints naturally.",
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                )
              ],
            ),
          ),
        ));
  }

  // Helper Widgets
  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildInsight(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Appcolors.tertiarycolor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Heart Rate
class HeartRatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.25, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.1),
      Offset(size.width * 0.35, size.height * 0.9),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.6),
      Offset(size.width * 0.65, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.7),
      Offset(size.width * 0.75, size.height * 0.6),
      Offset(size.width, size.height * 0.6),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Lungs
class LungsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Left lung
    final leftLung = Path()
      ..moveTo(size.width * 0.1, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.05, size.height * 0.5,
          size.width * 0.15, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.4,
          size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.43, size.height * 0.5,
          size.width * 0.38, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.15,
          size.width * 0.1, size.height * 0.25);

    // Right lung
    final rightLung = Path()
      ..moveTo(size.width * 0.62, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.15,
          size.width * 0.9, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.5,
          size.width * 0.85, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.9, size.width * 0.6,
          size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.57, size.height * 0.5,
          size.width * 0.62, size.height * 0.25);

    canvas.drawPath(leftLung, paint);
    canvas.drawPath(rightLung, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
