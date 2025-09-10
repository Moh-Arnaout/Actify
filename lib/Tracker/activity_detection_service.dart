// lib/Tracker/activity_detection_service.dart
import 'dart:async';
import 'dart:isolate';
import 'package:final_model_ai/Tracker/activitypredictor2.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityDetectionService {
  static bool _isRunning = false;
  static ActivityPredictor2? _backgroundPredictor;
  static StreamSubscription? _activitySubscription;

  static bool get isRunning => _isRunning;

  static Future<void> startBackgroundDetection() async {
    if (_isRunning) {
      print('Background detection already running');
      return;
    }

    try {
      // Initialize foreground service
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'activity_detection',
          channelName: 'Activity Detection',
          channelDescription: 'Tracking your activities in the background',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          iconData: const NotificationIconData(
            resType: ResourceType.mipmap,
            resPrefix: ResourcePrefix.ic,
            name: 'launcher',
          ),
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: const ForegroundTaskOptions(
          interval: 5000, // 5 seconds
          isOnceEvent: false,
          autoRunOnBoot: true,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );

      // Start foreground service
      bool serviceStarted = await FlutterForegroundTask.startService(
        notificationTitle: '🏃 Activity Tracker Active',
        notificationText: 'Monitoring your activities in background...',
        callback: startCallback,
      );

      if (serviceStarted) {
        _isRunning = true;
        print('Background activity detection started successfully');

        // Save the state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('background_detection_enabled', true);
      } else {
        throw Exception('Failed to start foreground service');
      }
    } catch (e) {
      print('Error starting background detection: $e');
      throw e;
    }
  }

  static Future<void> stopBackgroundDetection() async {
    if (!_isRunning) {
      print('Background detection not running');
      return;
    }

    try {
      // Stop the predictor
      _backgroundPredictor?.stopListening();
      _backgroundPredictor?.dispose();
      _backgroundPredictor = null;

      // Cancel subscription
      _activitySubscription?.cancel();
      _activitySubscription = null;

      // Stop foreground service
      await FlutterForegroundTask.stopService();

      _isRunning = false;
      print('Background activity detection stopped');

      // Save the state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('background_detection_enabled', false);
    } catch (e) {
      print('Error stopping background detection: $e');
    }
  }

  static Future<bool> isBackgroundDetectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('background_detection_enabled') ?? false;
  }

  // This callback will be called from the foreground service
  @pragma('vm:entry-point')
  static void startCallback() {
    // Initialize the background task
    FlutterForegroundTask.setTaskHandler(ActivityTaskHandler());
  }
}

// Task handler for the foreground service
class ActivityTaskHandler extends TaskHandler {
  ActivityPredictor2? _predictor;
  int _updateCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    print('Background activity task started');

    // Initialize the activity predictor
    _predictor = ActivityPredictor2();

    // Set up callbacks
    _predictor!.onActivityChanged = (activity) async {
      print('Background detected activity: $activity');
      await _saveActivityLog(activity);

      // Update notification with current activity
      FlutterForegroundTask.updateService(
        notificationTitle: '🏃 Activity Tracker Active',
        notificationText: 'Current: $activity',
      );
    };

    _predictor!.onError = (error) {
      print('Background prediction error: $error');
    };

    // Load model and start listening
    try {
      await _predictor!.loadModel();
      _predictor!.startListening();
      print('Background predictor started successfully');
    } catch (e) {
      print('Error starting background predictor: $e');
    }
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // This runs every 5 seconds (as configured in ForegroundTaskOptions)
    _updateCount++;

    // Optional: Send periodic updates
    if (_updateCount % 12 == 0) {
      // Every minute
      print(
          'Background activity detection running... (${_updateCount * 5} seconds)');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('Background activity task destroyed');
    _predictor?.stopListening();
    _predictor?.dispose();
  }

  Future<void> _saveActivityLog(String activity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList('activity_logs') ?? [];

      final now = DateTime.now();
      final logEntry = '$activity at ${now.toLocal()}';
      logs.add(logEntry);

      // Keep only last 1000 entries to prevent storage issues
      if (logs.length > 1000) {
        logs = logs.sublist(logs.length - 1000);
      }

      await prefs.setStringList('activity_logs', logs);
      print("Background saved to logs: $logEntry");
    } catch (e) {
      print("Error saving background activity log: $e");
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // TODO: implement onRepeatEvent
  }
}
