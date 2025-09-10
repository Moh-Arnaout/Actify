// File 1: activity_predictor.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ActivityPredictor2 {
  Interpreter? _interpreter;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  final int _bufferSize = 75;
  final List<List<double>> _sensorBuffer = [];

  final List<String> _activityLabels = [
    'Downstairs',
    'Jogging',
    'Lying',
    'Sitting',
    'Standing',
    'Upstairs',
    'Walking'
  ];

  // Callback functions to communicate with UI
  Function(String)? onActivityChanged;
  Function(double, double, double)? onSensorDataChanged;
  Function(bool)? onModelLoadStatusChanged;
  Function(String)? onError;

  bool _isModelLoaded = false;
  bool _isListening = false;

  bool get isModelLoaded => _isModelLoaded;
  bool get isListening => _isListening;

  // Load the TensorFlow Lite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/new_20_8_CNN_activity_model2.tflite');

      print('Model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');

      _isModelLoaded = true;
      onModelLoadStatusChanged?.call(true);
    } catch (e) {
      print('Failed to load model: $e');
      _isModelLoaded = false;
      onModelLoadStatusChanged?.call(false);
      onError?.call('Failed to load model: $e');
    }
  }

  // Start listening to accelerometer
  void startListening() {
    if (!_isModelLoaded) {
      onError?.call('Model not loaded yet');
      return;
    }

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      // Notify UI about sensor data changes
      onSensorDataChanged?.call(event.x, event.y, event.z);

      // Add to buffer
      _sensorBuffer.add([event.x, event.y, event.z]);

      // Keep buffer size fixed
      if (_sensorBuffer.length > _bufferSize) {
        _sensorBuffer.removeAt(0);
      }

      // Predict when buffer is full
      if (_sensorBuffer.length == _bufferSize) {
        _predictActivity();
      }
    });

    _isListening = true;
  }

  // Stop listening to accelerometer
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _isListening = false;
    onActivityChanged?.call("Unknown");
  }

  // Predict activity using the loaded model
  void _predictActivity() async {
    if (_interpreter == null || _sensorBuffer.length < _bufferSize) return;

    try {
      // Get model input shape
      var inputShape = _interpreter!.getInputTensor(0).shape;

      // Prepare input data
      Float32List input;
      List<int> inputTensorShape;

      if (inputShape.length == 4) {
        if (inputShape[1] == _bufferSize && inputShape[2] == 3) {
          input = Float32List(_bufferSize * 3);
          for (int i = 0; i < _bufferSize; i++) {
            input[i * 3] = _sensorBuffer[i][0];
            input[i * 3 + 1] = _sensorBuffer[i][1];
            input[i * 3 + 2] = _sensorBuffer[i][2];
          }
          inputTensorShape = [1, _bufferSize, 3, 1];
        } else if (inputShape[1] == 1 && inputShape[2] == _bufferSize) {
          input = Float32List(_bufferSize * 3);
          for (int i = 0; i < _bufferSize; i++) {
            input[i * 3] = _sensorBuffer[i][0];
            input[i * 3 + 1] = _sensorBuffer[i][1];
            input[i * 3 + 2] = _sensorBuffer[i][2];
          }
          inputTensorShape = [1, 1, _bufferSize, 3];
        } else {
          int totalElements = inputShape.reduce((a, b) => a * b);
          input = Float32List(totalElements);
          int dataIndex = 0;
          for (int i = 0; i < totalElements; i++) {
            if (dataIndex < _bufferSize * 3) {
              int sensorIndex = dataIndex ~/ 3;
              int axisIndex = dataIndex % 3;
              input[i] = _sensorBuffer[sensorIndex][axisIndex];
              dataIndex++;
            } else {
              input[i] = 0.0;
            }
          }
          inputTensorShape = inputShape;
        }
      } else if (inputShape.length == 3) {
        input = Float32List(_bufferSize * 3);
        for (int i = 0; i < _bufferSize; i++) {
          input[i * 3] = _sensorBuffer[i][0];
          input[i * 3 + 1] = _sensorBuffer[i][1];
          input[i * 3 + 2] = _sensorBuffer[i][2];
        }
        inputTensorShape = [1, _bufferSize, 3];
      } else {
        input = Float32List(_bufferSize * 3);
        for (int i = 0; i < _bufferSize; i++) {
          input[i * 3] = _sensorBuffer[i][0];
          input[i * 3 + 1] = _sensorBuffer[i][1];
          input[i * 3 + 2] = _sensorBuffer[i][2];
        }
        inputTensorShape = inputShape;
      }

      // Reshape and run inference
      var inputTensor = input.reshape(inputTensorShape);
      var outputShape = _interpreter!.getOutputTensor(0).shape;
      var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
          .reshape(outputShape);

      _interpreter!.run(inputTensor, output);

      // Process predictions
      List<double> predictions;
      if (output.isNotEmpty) {
        if (output[0] is List) {
          predictions = List<double>.from(output[0]);
        } else {
          predictions = List<double>.from(output);
        }
      } else {
        predictions = List<double>.from(output);
      }

      // Find the class with highest probability
      int maxIndex = 0;
      double maxValue = predictions[0];

      for (int i = 1;
          i < predictions.length && i < _activityLabels.length;
          i++) {
        if (predictions[i] > maxValue) {
          maxValue = predictions[i];
          maxIndex = i;
        }
      }

      print('Predictions: $predictions');
      print('Max confidence: $maxValue for ${_activityLabels[maxIndex]}');

      // Notify UI if confidence is reasonable
      if (maxValue > 0.3) {
        onActivityChanged?.call(_activityLabels[maxIndex]);
      }
    } catch (e) {
      print('Prediction error: $e');
      onError?.call('Prediction error: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _accelerometerSubscription?.cancel();
    _interpreter?.close();
  }
}
