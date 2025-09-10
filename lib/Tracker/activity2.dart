import 'dart:async';

import 'package:final_model_ai/Tracker/activity_detection_service.dart';
import 'package:final_model_ai/Tracker/activitypredictor2.dart';
import 'package:final_model_ai/Tracker/logs.dart';
import 'package:final_model_ai/Tracker/statistics.dart';
import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityRecognitionScreen2 extends StatefulWidget {
  const ActivityRecognitionScreen2({super.key});

  @override
  _ActivityRecognitionScreenState createState() =>
      _ActivityRecognitionScreenState();
}

class _ActivityRecognitionScreenState extends State<ActivityRecognitionScreen2>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _backgroundDetectionEnabled = false;
  late ActivityPredictor2 _predictor;

  String _currentActivity = "Unknown";
  bool _isModelLoaded = false;
  bool _isListening = false;
  double _x = 0.0, _y = 0.0, _z = 0.0;

  final List<String> _activityLogs = [];

  // Activity Timer Variables
  Timer? _activityTimer;
  DateTime? _activityStartTime;
  Duration _currentActivityDuration = Duration.zero;
  String _lastTrackedActivity = "";

  // UI Update Optimization
  Timer? _uiUpdateTimer;
  bool _pendingUIUpdate = false;

  // Cache for expensive operations
  Color? _cachedActivityColor;
  IconData? _cachedActivityIcon;
  String _lastActivityForCache = "";

  @override
  void initState() {
    super.initState();
    _initializePredictor();
    _checkBackgroundDetectionStatus();
  }

  void _initializePredictor() {
    _predictor = ActivityPredictor2();

    _predictor.onActivityChanged = (activity) {
      if (mounted && _currentActivity != activity) {
        setState(() {
          _currentActivity = activity;
          _clearActivityCache();
        });

        // Reset the activity timer when activity changes
        _resetActivityTimer(activity);

        // Log the activity when it changes (async)
        _onActivityDetectedAsync(activity);
      }
    };

    // Throttle sensor data updates to prevent excessive rebuilds
    _predictor.onSensorDataChanged = (x, y, z) {
      if (mounted) {
        _x = x;
        _y = y;
        _z = z;

        if (!_pendingUIUpdate) {
          _pendingUIUpdate = true;
          _uiUpdateTimer?.cancel();
          _uiUpdateTimer = Timer(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                // Sensor values are already updated above
              });
            }
            _pendingUIUpdate = false;
          });
        }
      }
    };

    _predictor.onModelLoadStatusChanged = (loaded) {
      if (mounted) {
        setState(() {
          _isModelLoaded = loaded;
        });
      }
    };

    _predictor.onError = (error) {
      if (mounted) {
        _showMessage(error);
      }
    };

    _predictor.loadModel();
  }

  // Activity Timer Methods
  void _resetActivityTimer(String newActivity) {
    // Stop the current timer
    _activityTimer?.cancel();

    // Reset duration and start time only if it's a different activity or we're starting fresh
    if (_lastTrackedActivity != newActivity || _activityStartTime == null) {
      _activityStartTime = DateTime.now();
      _currentActivityDuration = Duration.zero;
      _lastTrackedActivity = newActivity;

      // Start new timer that updates every second
      if (newActivity != "Unknown" && _isListening) {
        _activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted && _activityStartTime != null) {
            setState(() {
              _currentActivityDuration =
                  DateTime.now().difference(_activityStartTime!);
            });
          }
        });
      }
    }
  }

  void _stopActivityTimer() {
    _activityTimer?.cancel();
    _activityStartTime = null;
    _currentActivityDuration = Duration.zero;
    _lastTrackedActivity = "";
  }

  void _showInstructionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Appcolors.primaryColor,
                              Appcolors.secondaryColor
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.directions_run,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'How to Use Activity Tracker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Appcolors.primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Follow these simple steps to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Instructions
                    _buildInstructionItem(
                      icon: Icons.play_arrow,
                      iconColor: Appcolors.start,
                      title: 'Press Start Detection',
                      description:
                          'Tap the "Start Detection" button to begin tracking your movements and activities.',
                    ),

                    _buildInstructionItem(
                      icon: Icons.phone_android,
                      iconColor: Colors.blue,
                      title: 'Phone Position',
                      description:
                          'Keep your phone in your pocket or similar position. Do NOT hold it in your hand while moving.',
                    ),

                    _buildInstructionItem(
                      icon: Icons.sensors,
                      iconColor: Colors.green,
                      title: 'Natural Movement',
                      description:
                          'Move naturally! The AI will detect walking, jogging, sitting, standing, and going up/down stairs.',
                    ),

                    _buildInstructionItem(
                      icon: Icons.timer,
                      iconColor: Colors.orange,
                      title: 'Continuous Tracking',
                      description:
                          'Keep the tracker running for best results. It learns your patterns over time.',
                    ),

                    _buildInstructionItem(
                      icon: Icons.analytics,
                      iconColor: Colors.purple,
                      title: 'View Your Data',
                      description:
                          'Check the Logs and Statistics sections to see your activity history and health insights.',
                    ),
                    // Add this instruction item to your _showInstructionBottomSheet method:
                    _buildInstructionItem(
                      icon: Icons.alarm,
                      iconColor: Colors.indigo,
                      title: 'Background Detection',
                      description:
                          'Enable background tracking to continue monitoring activities even when the app is closed or phone is in your pocket.',
                    ),

                    const SizedBox(height: 30),

                    // Tips section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  color: Colors.amber[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Pro Tips',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTipItem(
                              '• Battery optimization: The tracker is designed to be battery-efficient'),
                          _buildTipItem(
                              '• Privacy: All processing happens on your device - no data sent to servers'),
                          _buildTipItem(
                              '• Accuracy: Wait a few seconds after starting for the AI to calibrate'),
                          _buildTipItem(
                              '• Best results: Use consistently for a few days to see patterns'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _actuallyStartListening();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Appcolors.start,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Got It! Start Tracking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Maybe Later',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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

  Widget _buildInstructionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          height: 1.3,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  // Check if this is the first time using the tracker
  Future<bool> _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('has_used_tracker') ?? false);
  }

  Future<void> _markAsUsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_used_tracker', true);
  }

  void _startListening() async {
    if (!_isModelLoaded) {
      _showMessage('Model not loaded yet');
      return;
    }

    if (await _isFirstTime()) {
      _showInstructionBottomSheet();
      return;
    }

    _actuallyStartListening();
  }

  void _actuallyStartListening() {
    _predictor.startListening();
    setState(() {
      _isListening = _predictor.isListening;
    });

    // Reset timer when starting
    if (_currentActivity != "Unknown") {
      _resetActivityTimer(_currentActivity);
    }

    _markAsUsed();
    _saveAutoStartPreference(true);
  }

  void _stopListening() {
    _predictor.stopListening();
    setState(() {
      _isListening = _predictor.isListening;
      _currentActivity = "Unknown";
      _clearActivityCache();
    });

    // Stop the timer when stopping detection
    _stopActivityTimer();
    _saveAutoStartPreference(false);
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _enableBackgroundDetection() async {
    try {
      await ActivityDetectionService.startBackgroundDetection();
      setState(() {
        _backgroundDetectionEnabled = true;
      });
      _showMessage('Background tracking enabled');
    } catch (e) {
      _showMessage('Failed to enable background tracking: $e');
    }
  }

  Future<void> _checkBackgroundDetectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldAutoStart = prefs.getBool('auto_start_detection') ?? false;

    if (shouldAutoStart && !_isListening) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isModelLoaded) {
          _startListening();
        }
      });
    }
  }

  Future<void> _saveAutoStartPreference(bool autoStart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_start_detection', autoStart);
  }

  Future<void> _disableBackgroundDetection() async {
    await ActivityDetectionService.stopBackgroundDetection();
    setState(() {
      _backgroundDetectionEnabled = false;
    });
    _showMessage('Background tracking disabled');
  }

  Widget _buildBackgroundDetectionToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.alarm,
            color: _backgroundDetectionEnabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Background Detection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Appcolors.primaryColor,
                  ),
                ),
                Text(
                  _backgroundDetectionEnabled
                      ? 'Tracking activities in background'
                      : 'Enable to track when app is closed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _backgroundDetectionEnabled,
            onChanged: (value) {
              if (value) {
                _enableBackgroundDetection();
              } else {
                _disableBackgroundDetection();
              }
            },
            activeColor: Appcolors.primaryColor,
          ),
        ],
      ),
    );
  }

  // [Keep all your existing _showInstructionBottomSheet, _buildInstructionItem, and _buildTipItem methods as they are]

  void _clearActivityCache() {
    _cachedActivityColor = null;
    _cachedActivityIcon = null;
    _lastActivityForCache = "";
  }

  Color _getActivityColor() {
    if (_cachedActivityColor != null &&
        _lastActivityForCache == _currentActivity) {
      return _cachedActivityColor!;
    }

    _lastActivityForCache = _currentActivity;
    switch (_currentActivity) {
      case 'Jogging':
        _cachedActivityColor = Colors.red;
        break;
      case 'Lying':
        _cachedActivityColor = Colors.indigo;
        break;
      case 'Walking':
        _cachedActivityColor = Colors.green;
        break;
      case 'Upstairs':
        _cachedActivityColor = Colors.blue;
        break;
      case 'Downstairs':
        _cachedActivityColor = Colors.orange;
        break;
      case 'Sitting':
        _cachedActivityColor = Colors.purple;
        break;
      case 'Standing':
        _cachedActivityColor = Colors.brown;
        break;
      default:
        _cachedActivityColor = Appcolors.currentactivity;
    }
    return _cachedActivityColor!;
  }

  IconData _getActivityIcon() {
    if (_cachedActivityIcon != null &&
        _lastActivityForCache == _currentActivity) {
      return _cachedActivityIcon!;
    }

    switch (_currentActivity) {
      case 'Jogging':
        _cachedActivityIcon = Icons.directions_run;
        break;
      case 'Lying':
        _cachedActivityIcon = Icons.hotel;
        break;
      case 'Walking':
        _cachedActivityIcon = Icons.directions_walk;
        break;
      case 'Upstairs':
        _cachedActivityIcon = Icons.keyboard_arrow_up;
        break;
      case 'Downstairs':
        _cachedActivityIcon = Icons.keyboard_arrow_down;
        break;
      case 'Sitting':
        _cachedActivityIcon = Icons.chair;
        break;
      case 'Standing':
        _cachedActivityIcon = Icons.accessibility;
        break;
      default:
        _cachedActivityIcon = Icons.help_outline;
    }
    return _cachedActivityIcon!;
  }

  Future<void> _onActivityDetectedAsync(String activity) async {
    unawaited(_saveActivityLog(activity));
  }

  Future<void> _saveActivityLog(String activity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList('activity_logs') ?? [];

      final now = DateTime.now();
      final logEntry = '$activity at ${now.toLocal()}';
      logs.add(logEntry);

      await prefs.setStringList('activity_logs', logs);
      print("Saved to logs: $logEntry");
    } catch (e) {
      print("Error saving activity log: $e");
    }
  }

  // Enhanced Current Activity Card with Timer
  Widget _buildCurrentActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [_getActivityColor(), _getActivityColor()],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Activity',
                style: TextStyle(
                  fontSize: 30,
                  color: Appcolors.tertiarycolor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                _getActivityIcon(),
                size: 40,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: MediaQuery.of(context).size.width / 1.5,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Appcolors.tertiarycolor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentActivity,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    color: Appcolors.currentactivity,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Activity Timer Display
          if (_isListening &&
              _currentActivity != "Unknown" &&
              _activityStartTime != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_currentActivityDuration),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 30),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isListening ? null : _startListening,
            icon: Icon(Icons.play_arrow,
                color: _isListening ? Appcolors.tertiarycolor : Colors.white),
            label: Text(
              'Start Detection',
              style: TextStyle(
                color: _isListening ? Appcolors.tertiarycolor : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isListening ? Appcolors.tertiarycolor : Appcolors.start,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isListening ? _stopListening : null,
            icon: Icon(Icons.stop,
                color: !_isListening ? Appcolors.tertiarycolor : Colors.white),
            label: Text(
              'Stop Detection',
              style: TextStyle(
                color: !_isListening ? Appcolors.tertiarycolor : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_isListening ? Colors.white : Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Appcolors.backcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Activity Recognition',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showInstructionBottomSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Appcolors.tertiarycolor,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Fitness And Activity Tracker',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Appcolors.primaryColor,
                            ),
                            softWrap: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'Images/Weights2.png',
                          scale: 15,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This page tracks your movements in real time, helping the app understand your activity patterns so it can support your health and recovery.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Enhanced Current Activity Display with Timer
              _buildCurrentActivityCard(),

              const SizedBox(height: 20),

              // Navigation buttons for Logs and Statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => LogsPage(activityLogs: _activityLogs))
                            ?.then((_) {
                          if (mounted) setState(() {});
                        });
                      },
                      child: Container(
                        height: 131,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Appcolors.currentactivity),
                        child: Center(
                          child: ClipOval(
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Appcolors.tertiarycolor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'Images/logs.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text(
                                    'Logs',
                                    style: TextStyle(
                                        color: Appcolors.primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 26),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => const StatsPage())?.then((_) {
                          if (mounted) setState(() {});
                        });
                      },
                      child: Container(
                        height: 131,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Appcolors.currentactivity),
                        child: Center(
                          child: ClipOval(
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Appcolors.tertiarycolor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'Images/stats2.svg',
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text(
                                    'Statistics',
                                    style: TextStyle(
                                        color: Appcolors.primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _activityTimer?.cancel(); // Clean up the activity timer
    _predictor.dispose();
    super.dispose();
  }
}

// Extension to suppress unawaited warnings
extension FutureExtensions<T> on Future<T> {
  void unawaited() {}
}
