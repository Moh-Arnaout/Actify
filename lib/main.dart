import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mohammad_model/Login/First.dart';
import 'package:mohammad_model/Login/login.dart';
import 'package:mohammad_model/Tracker/activity.dart';
import 'package:mohammad_model/Tracker/activitypredictor.dart';
import 'package:mohammad_model/Home/home.dart';
import 'package:mohammad_model/splash.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Activity Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splashscreen(),
    );
  }
}
