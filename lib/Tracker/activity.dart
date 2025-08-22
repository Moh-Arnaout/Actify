import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:mohammad_model/Tracker/activitypredictor.dart';
import 'package:mohammad_model/Tracker/logs.dart';
import 'package:mohammad_model/Tracker/statistics.dart';
import 'package:mohammad_model/bottombar.dart';
import 'package:mohammad_model/Tracker/buildsensor.dart';
import 'package:mohammad_model/theme.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ActivityRecognitionScreen extends StatefulWidget {
  @override
  _ActivityRecognitionScreenState createState() =>
      _ActivityRecognitionScreenState();
}

class _ActivityRecognitionScreenState extends State<ActivityRecognitionScreen> {
  Interpreter? _interpreter;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  String _currentActivity = "Unknown";
  bool _isModelLoaded = false;
  bool _isListening = false;

  // Buffer to store accelerometer readings
  List<List<double>> _sensorBuffer = [];
  final int _bufferSize = 50; // Number of readings to collect for prediction

  // Activity labels (adjust based on your model's output classes)
  final List<String> _activityLabels = [
    'Jogging',
    'Sitting',
    'Standing',
    'Walking',
    // 'Upstairs',
    // 'Walking'
  ];

  // Current sensor values for display
  double _x = 0.0, _y = 0.0, _z = 0.0;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Load the TFLite model from assets
      _interpreter =
          await Interpreter.fromAsset('assets/activity_model.tflite');

      // Print model information for debugging
      print('Model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Input type: ${_interpreter!.getInputTensor(0).type}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
      print('Output type: ${_interpreter!.getOutputTensor(0).type}');

      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print('Failed to load model: $e');
      setState(() {
        _isModelLoaded = false;
      });
    }
  }

  void _startListening() {
    if (!_isModelLoaded) {
      _showMessage('Model not loaded yet');
      return;
    }

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });

      // Add to buffer
      _sensorBuffer.add([event.x, event.y, event.z]);

      // Keep buffer size fixed
      if (_sensorBuffer.length > _bufferSize) {
        _sensorBuffer.removeAt(0);
      }

      // Predict when buffer is full
      if (_sensorBuffer.length == _bufferSize) {
        final predictor = ActivityPredictor(
          interpreter: _interpreter!,
          sensorBuffer: _sensorBuffer,
          bufferSize: _bufferSize,
          activityLabels: _activityLabels,
        );

        predictor.predictActivity().then((predictedActivity) {
          if (predictedActivity != null) {
            setState(() {
              _currentActivity = predictedActivity;
            });

            // Also call the logging callback if needed
            _onActivityDetected.call(predictedActivity);
          }
        });
      }
    });

    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
    _accelerometerSubscription?.cancel();
    setState(() {
      _isListening = false;
      _currentActivity = "Unknown";
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _getActivityColor() {
    switch (_currentActivity) {
      case 'Jogging':
        return Colors.red;
      case 'Walking':
        return Colors.green;
      case 'Upstairs':
        return Colors.blue;
      case 'Downstairs':
        return Colors.orange;
      case 'Sitting':
        return Colors.purple;
      case 'Standing':
        return Colors.brown;
      default:
        return Appcolors.currentactivity;
    }
  }

  IconData _getActivityIcon() {
    switch (_currentActivity) {
      case 'Jogging':
        return Icons.directions_run;
      case 'Walking':
        return Icons.directions_walk;
      case 'Upstairs':
        return Icons.keyboard_arrow_up;
      case 'Downstairs':
        return Icons.keyboard_arrow_down;
      case 'Sitting':
        return Icons.chair;
      case 'Standing':
        return Icons.accessibility;
      default:
        return Icons.help_outline;
    }
  }

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<String> _activityLogs = [];

  Future<void> _onActivityDetected(String activity) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('activity_logs') ?? [];

    final now = DateTime.now();
    final logEntry = '$activity at ${now.toLocal()}';
    logs.add(logEntry);

    await prefs.setStringList('activity_logs', logs);
    print("Saved to logs: $logEntry");
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
                  // Add subtle shadow to match the card appearance
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

              const SizedBox(
                height: 10,
              ),

              const SizedBox(height: 15),

              // Current Activity Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [_getActivityColor(), _getActivityColor()],
                    // begin: Alignment.topLeft,
                    // end: Alignment.bottomRight,
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
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isListening ? null : _startListening,
                            icon: Icon(Icons.play_arrow,
                                color: _isListening
                                    ? Appcolors.tertiarycolor
                                    : Colors.white),
                            label: Text(
                              'Start Detection',
                              style: TextStyle(
                                color: _isListening
                                    ? Appcolors.tertiarycolor
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening
                                  ? Appcolors.tertiarycolor
                                  : Appcolors.start,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isListening ? _stopListening : null,
                            icon: Icon(Icons.stop,
                                color: !_isListening
                                    ? Appcolors.tertiarycolor
                                    : Colors.white),
                            label: Text(
                              'Stop Detection',
                              style: TextStyle(
                                color: !_isListening
                                    ? Appcolors.tertiarycolor
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  !_isListening ? Colors.white : Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Sensor Values Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => LogsPage(activityLogs: _activityLogs));
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
                  SizedBox(
                    width: 26,
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => StatsPage());
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
                                    'Statisics',
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
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accelerometer Values',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Buildsensor('X', double.parse(_x.toStringAsFixed(3)),
                              Colors.red),
                          Buildsensor('Y', double.parse(_y.toStringAsFixed(3)),
                              Colors.green),
                          Buildsensor('Z', double.parse(_z.toStringAsFixed(3)),
                              Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _interpreter?.close();
    super.dispose();
  }
}
