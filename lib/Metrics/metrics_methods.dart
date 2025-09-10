import 'dart:math' as math;
import 'dart:ui';

import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';

String getHealthSummary(Map<String, dynamic> healthMetrics) {
  int overallScore = healthMetrics['overallScore'] ?? 50;
  int improvement = healthMetrics['improvement'] ?? 0;

  String trend = improvement > 5
      ? 'improving'
      : improvement < -5
          ? 'declining'
          : 'stable';

  String performance = overallScore >= 75
      ? 'excellent'
      : overallScore >= 60
          ? 'good'
          : 'needs attention';

  return 'Your health is $performance and $trend.';
}

// Enhanced Heart Metric Card with more comprehensive data
class EnhancedHeartMetricCard extends StatefulWidget {
  final Map<String, dynamic> healthMetrics;

  const EnhancedHeartMetricCard({super.key, required this.healthMetrics});

  @override
  State<EnhancedHeartMetricCard> createState() =>
      _EnhancedHeartMetricCardState();
}

class _EnhancedHeartMetricCardState extends State<EnhancedHeartMetricCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> healthScores =
        widget.healthMetrics['healthScores'] ?? {};
    Map<String, double> durations =
        widget.healthMetrics['activityDurations'] ?? {};
    Map<String, dynamic> timeMetrics =
        widget.healthMetrics['timeMetrics'] ?? {};
    List<double> weeklyTrend =
        (widget.healthMetrics['weeklyTrends']?['heart'] as List<dynamic>? ??
                [50, 50, 50, 50, 50, 50, 50])
            .map((e) => (e as num).toDouble())
            .toList();

    int heartScore = healthScores['heart'] ?? 50;
    double joggingMinutes = durations['Jogging'] ?? 0;
    double walkingMinutes = durations['Walking'] ?? 0;
    double totalActiveMinutes = joggingMinutes +
        walkingMinutes +
        (durations['Upstairs'] ?? 0) +
        (durations['Downstairs'] ?? 0);
    double sedentaryMinutes =
        (durations['Sitting'] ?? 0) + (durations['Lying'] ?? 0);

    String heartStatus = heartScore >= 80
        ? 'Excellent cardiovascular health'
        : heartScore >= 65
            ? 'Good heart condition'
            : heartScore >= 50
                ? 'Moderate cardiovascular fitness'
                : 'Needs cardiovascular improvement';

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
              // Header Row with Dynamic Icon
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
                    child: Stack(
                      children: [
                        Icon(
                          heartScore >= 70
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        if (heartScore >= 80)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dynamic Heart Rate Visualization
              SizedBox(
                height: 60,
                width: double.infinity,
                child: CustomPaint(
                  painter: HeartRatePainter(),
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic Score Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      heartStatus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '$heartScore%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Expanding part with comprehensive data
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Weekly Trend Chart
                          Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: CustomPaint(
                              painter:
                                  WeeklyTrendPainter(weeklyTrend, Colors.white),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Detailed metrics
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetric(
                                  Icons.directions_run,
                                  "High Intensity",
                                  "${joggingMinutes.toInt()} min"),
                              _buildMetric(Icons.directions_walk, "Moderate",
                                  "${walkingMinutes.toInt()} min"),
                              _buildMetric(
                                  Icons.airline_seat_recline_normal,
                                  "Sedentary",
                                  "${sedentaryMinutes.toInt()} min"),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),

                          // Activity breakdown
                          Text(
                            'Activity Breakdown (Last 7 Days)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _buildActivityBar(
                              'High Intensity',
                              joggingMinutes,
                              totalActiveMinutes + sedentaryMinutes,
                              Colors.redAccent),
                          _buildActivityBar(
                              'Moderate Activity',
                              walkingMinutes,
                              totalActiveMinutes + sedentaryMinutes,
                              Colors.orangeAccent),
                          _buildActivityBar(
                              'Sedentary Time',
                              sedentaryMinutes,
                              totalActiveMinutes + sedentaryMinutes,
                              Colors.grey),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),

                          // Dynamic insights based on data
                          ..._generateHeartInsights(heartScore, joggingMinutes,
                              walkingMinutes, sedentaryMinutes),
                        ],
                      )
                    : const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildActivityBar(
      String label, double value, double total, Color color) {
    double percentage = total > 0 ? (value / total) : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${value.toInt()}m',
              style: const TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateHeartInsights(
      int score, double jogging, double walking, double sedentary) {
    List<Widget> insights = [];

    if (jogging < 15) {
      insights.add(_buildInsight(
          "Try adding 15+ minutes of high-intensity activity like jogging for better heart health."));
    }

    if (sedentary > 180) {
      insights.add(_buildInsight(
          "Consider breaking up long sitting periods - your sedentary time is quite high."));
    }

    if (score >= 80) {
      insights.add(_buildInsight(
          "Great work! Your cardiovascular fitness is excellent. Keep it up!"));
    } else if (walking + jogging < 30) {
      insights.add(_buildInsight(
          "Aim for at least 30 minutes of daily activity to improve heart health."));
    }

    return insights;
  }

  Widget _buildInsight(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Colors.yellowAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Similar enhanced versions for Lungs and Joints cards would follow the same pattern
// Due to length constraints, I'll provide the key classes:

// Enhanced Lungs Metric Card (similar structure with lung-specific metrics)
class EnhancedLungsMetricCard extends StatefulWidget {
  final Map<String, dynamic> healthMetrics;
  const EnhancedLungsMetricCard({super.key, required this.healthMetrics});

  @override
  State<EnhancedLungsMetricCard> createState() =>
      _EnhancedLungsMetricCardState();
}

class _EnhancedLungsMetricCardState extends State<EnhancedLungsMetricCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> healthScores =
        widget.healthMetrics['healthScores'] ?? {};
    Map<String, double> durations =
        widget.healthMetrics['activityDurations'] ?? {};
    List<double> weeklyTrend =
        (widget.healthMetrics['weeklyTrends']?['lungs'] as List<dynamic>? ??
                [50, 50, 50, 50, 50, 50, 50])
            .map((e) => (e as num).toDouble())
            .toList();

    int lungsScore = healthScores['lungs'] ?? 50;
    double joggingMinutes = durations['Jogging'] ?? 0;
    double walkingMinutes = durations['Walking'] ?? 0;
    double stairsMinutes =
        (durations['Upstairs'] ?? 0) + (durations['Downstairs'] ?? 0);
    double aerobicTotal = joggingMinutes + walkingMinutes + stairsMinutes;

    String lungsStatus = lungsScore >= 80
        ? 'Outstanding respiratory fitness'
        : lungsScore >= 65
            ? 'Good lung capacity'
            : lungsScore >= 50
                ? 'Moderate breathing efficiency'
                : 'Respiratory system needs attention';

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
                        Icon(
                          lungsScore >= 70 ? Icons.air : Icons.air_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        if (lungsScore >= 80)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Breathing Animation Visualization
              Center(
                child: SizedBox(
                  width: 100,
                  height: 80,
                  child: CustomPaint(
                    painter: BreathingVisualizationPainter(lungsScore),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Score Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lungsStatus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '$lungsScore%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Expanding details
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Weekly Trend
                          Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: CustomPaint(
                              painter:
                                  WeeklyTrendPainter(weeklyTrend, Colors.white),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Aerobic Activity Metrics
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetric(Icons.directions_run, "Running",
                                  "${joggingMinutes.toInt()} min"),
                              _buildMetric(Icons.directions_walk, "Walking",
                                  "${walkingMinutes.toInt()} min"),
                              _buildMetric(Icons.stairs, "Stairs",
                                  "${stairsMinutes.toInt()} min"),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),

                          // Respiratory Capacity Indicator
                          Text(
                            'Respiratory Activity Analysis',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _buildCapacityIndicator('Aerobic Capacity',
                              aerobicTotal, 150, Colors.lightBlueAccent),
                          _buildCapacityIndicator('Weekly Goal', aerobicTotal,
                              210, Colors.cyanAccent),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),

                          // Dynamic Lung Health Insights
                          ..._generateLungsInsights(lungsScore, joggingMinutes,
                              walkingMinutes, stairsMinutes),
                        ],
                      )
                    : const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildCapacityIndicator(
      String label, double current, double target, Color color) {
    double percentage = (current / target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text('${current.toInt()}/${target.toInt()}m',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateLungsInsights(
      int score, double jogging, double walking, double stairs) {
    List<Widget> insights = [];

    if (jogging + walking < 30) {
      insights.add(_buildInsight(
          "Increase daily aerobic activity to improve lung capacity and oxygen efficiency."));
    }

    if (stairs > 15) {
      insights.add(_buildInsight(
          "Excellent stair climbing! This greatly benefits your respiratory system."));
    }

    if (score >= 80) {
      insights.add(_buildInsight(
          "Your lung health is exceptional! Consider activities like swimming or cycling to maintain it."));
    } else if (score < 50) {
      insights.add(_buildInsight(
          "Focus on gradual cardio increases and deep breathing exercises for improvement."));
    }

    return insights;
  }

  Widget _buildInsight(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Colors.yellowAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 11, color: Colors.white, height: 1.3)),
          ),
        ],
      ),
    );
  }
}

// Enhanced Joints Metric Card
class EnhancedJointsMetricCard extends StatefulWidget {
  final Map<String, dynamic> healthMetrics;
  const EnhancedJointsMetricCard({super.key, required this.healthMetrics});

  @override
  State<EnhancedJointsMetricCard> createState() =>
      _EnhancedJointsMetricCardState();
}

class _EnhancedJointsMetricCardState extends State<EnhancedJointsMetricCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> healthScores =
        widget.healthMetrics['healthScores'] ?? {};
    Map<String, double> durations =
        widget.healthMetrics['activityDurations'] ?? {};
    List<double> weeklyTrend =
        (widget.healthMetrics['weeklyTrends']?['joints'] as List<dynamic>? ??
                [50, 50, 50, 50, 50, 50, 50])
            .map((e) => (e as num).toDouble())
            .toList();

    int jointsScore = healthScores['joints'] ?? 50;
    double walkingMinutes = durations['Walking'] ?? 0;
    double standingMinutes = durations['Standing'] ?? 0;
    double sittingMinutes = durations['Sitting'] ?? 0;
    double stairsMinutes =
        (durations['Upstairs'] ?? 0) + (durations['Downstairs'] ?? 0);
    double movementTotal = walkingMinutes + standingMinutes + stairsMinutes;

    String jointsStatus = jointsScore >= 80
        ? 'Exceptional joint mobility'
        : jointsScore >= 65
            ? 'Good joint flexibility'
            : jointsScore >= 50
                ? 'Moderate joint health'
                : 'Joints need more movement';

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
                    child: Stack(
                      children: [
                        Icon(
                          jointsScore >= 70
                              ? Icons.accessibility_new
                              : Icons.accessibility,
                          color: Colors.white,
                          size: 28,
                        ),
                        if (jointsScore >= 80)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Joint Mobility Visualization
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: CustomPaint(
                      painter: JointMobilityPainter(jointsScore),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mobility Score',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
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
                            widthFactor: jointsScore / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$jointsScore% Flexibility',
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
                          const SizedBox(height: 20),

                          // Weekly Trend
                          Container(
                            height: 60,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: CustomPaint(
                              painter:
                                  WeeklyTrendPainter(weeklyTrend, Colors.white),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Movement Metrics
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetric(Icons.directions_walk, "Walking",
                                  "${walkingMinutes.toInt()} min"),
                              _buildMetric(Icons.accessibility, "Standing",
                                  "${standingMinutes.toInt()} min"),
                              _buildMetric(Icons.stairs, "Stairs",
                                  "${stairsMinutes.toInt()} min"),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),

                          // Joint Health Analysis
                          Text(
                            'Movement vs Sedentary Analysis',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          _buildMovementBar(
                              'Active Movement',
                              movementTotal,
                              movementTotal + sittingMinutes,
                              Colors.greenAccent),
                          _buildMovementBar('Sedentary Time', sittingMinutes,
                              movementTotal + sittingMinutes, Colors.redAccent),

                          const SizedBox(height: 12),

                          // Joint Stress Indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildJointIndicator(
                                  'Knees', walkingMinutes + stairsMinutes),
                              _buildJointIndicator(
                                  'Hips', walkingMinutes + standingMinutes),
                              _buildJointIndicator('Spine',
                                  sittingMinutes > 240 ? 'High Risk' : 'Good'),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),

                          // Dynamic Joint Health Insights
                          ..._generateJointsInsights(
                              jointsScore,
                              walkingMinutes,
                              standingMinutes,
                              sittingMinutes,
                              stairsMinutes),
                        ],
                      )
                    : const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildMovementBar(
      String label, double value, double total, Color color) {
    double percentage = total > 0 ? (value / total) : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text('${value.toInt()}m',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget _buildJointIndicator(String joint, dynamic value) {
    String status;
    Color color;

    if (value is String) {
      status = value;
      color = value == 'Good' ? Colors.greenAccent : Colors.redAccent;
    } else {
      double minutes = value as double;
      if (minutes >= 30) {
        status = 'Good';
        color = Colors.greenAccent;
      } else if (minutes >= 15) {
        status = 'Fair';
        color = Colors.orangeAccent;
      } else {
        status = 'Low';
        color = Colors.redAccent;
      }
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.circle, color: color, size: 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(joint,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        Text(status, style: TextStyle(color: color, fontSize: 9)),
      ],
    );
  }

  List<Widget> _generateJointsInsights(int score, double walking,
      double standing, double sitting, double stairs) {
    List<Widget> insights = [];

    if (sitting > 240) {
      insights.add(_buildInsight(
          "Long sitting periods detected. Take regular breaks to prevent joint stiffness."));
    }

    if (walking < 20) {
      insights.add(_buildInsight(
          "Increase daily walking to improve joint lubrication and flexibility."));
    }

    if (stairs > 20) {
      insights.add(_buildInsight(
          "Great stair usage! This strengthens your leg joints and improves stability."));
    }

    if (score >= 80) {
      insights.add(_buildInsight(
          "Outstanding joint health! Consider yoga or stretching to maintain flexibility."));
    } else if (standing < 30) {
      insights.add(_buildInsight(
          "Try to stand more throughout the day to reduce joint compression."));
    }

    return insights;
  }

  Widget _buildInsight(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Colors.yellowAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 11, color: Colors.white, height: 1.3)),
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

// Custom Painter for Weekly Trend
class WeeklyTrendPainter extends CustomPainter {
  final List<double> trendValues;
  final Color lineColor;

  WeeklyTrendPainter(this.trendValues, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (trendValues.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double minValue = trendValues.reduce((a, b) => a < b ? a : b);
    final double maxValue = trendValues.reduce((a, b) => a > b ? a : b);
    final double range =
        (maxValue - minValue).abs() < 1 ? 1 : (maxValue - minValue);

    final double horizontalStep = size.width / (trendValues.length - 1);

    Path path = Path();
    for (int i = 0; i < trendValues.length; i++) {
      double x = i * horizontalStep;
      double y = size.height -
          ((trendValues[i] - minValue) / range * size.height * 0.8 +
              size.height * 0.1);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots for each value
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < trendValues.length; i++) {
      double x = i * horizontalStep;
      double y = size.height -
          ((trendValues[i] - minValue) / range * size.height * 0.8 +
              size.height * 0.1);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Joint Mobility Visualization
class JointMobilityPainter extends CustomPainter {
  final int jointsScore;

  JointMobilityPainter(this.jointsScore);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw mobility arc
    final arcPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double sweepAngle = (jointsScore / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Draw score text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$jointsScore',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final offset = Offset(
        center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Breathing Visualization (Lungs)
class BreathingVisualizationPainter extends CustomPainter {
  final int lungsScore;

  BreathingVisualizationPainter(this.lungsScore);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double maxRadius = size.width * 0.4;
    final double minRadius = size.width * 0.2;
    final double radius = minRadius +
        ((lungsScore.clamp(0, 100) / 100) * (maxRadius - minRadius));

    final Paint circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final Paint outlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw expanding/contracting circle
    canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);
    canvas.drawCircle(Offset(centerX, centerY), radius, outlinePaint);

    // Draw lungs icon in the center
    final lungsIconPainter = TextPainter(
      text: const TextSpan(
        text: '🫁',
        style: TextStyle(fontSize: 32),
      ),
      textDirection: TextDirection.ltr,
    );
    lungsIconPainter.layout();
    lungsIconPainter.paint(
      canvas,
      Offset(centerX - lungsIconPainter.width / 2,
          centerY - lungsIconPainter.height / 2),
    );

    // Draw score text below
    final scorePainter = TextPainter(
      text: TextSpan(
        text: '$lungsScore%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(
      canvas,
      Offset(centerX - scorePainter.width / 2, centerY + radius + 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
