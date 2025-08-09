import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class ActivityPredictor {
  final Interpreter interpreter;
  final List<List<double>> sensorBuffer;
  final int bufferSize;
  final List<String> activityLabels;

  ActivityPredictor({
    required this.interpreter,
    required this.sensorBuffer,
    required this.bufferSize,
    required this.activityLabels,
  });

  Future<String?> predictActivity() async {
    if (sensorBuffer.length < bufferSize) return null;

    try {
      var inputShape = interpreter.getInputTensor(0).shape;
      // Prepare input tensor
      Float32List input;
      List<int> inputTensorShape;

      if (inputShape.length == 4) {
        if (inputShape[1] == bufferSize && inputShape[2] == 3) {
          input = Float32List(bufferSize * 3);
          for (int i = 0; i < bufferSize; i++) {
            input[i * 3] = sensorBuffer[i][0];
            input[i * 3 + 1] = sensorBuffer[i][1];
            input[i * 3 + 2] = sensorBuffer[i][2];
          }
          inputTensorShape = [1, bufferSize, 3, 1];
        } else if (inputShape[1] == 1 && inputShape[2] == bufferSize) {
          input = Float32List(bufferSize * 3);
          for (int i = 0; i < bufferSize; i++) {
            input[i * 3] = sensorBuffer[i][0];
            input[i * 3 + 1] = sensorBuffer[i][1];
            input[i * 3 + 2] = sensorBuffer[i][2];
          }
          inputTensorShape = [1, 1, bufferSize, 3];
        } else {
          int totalElements = inputShape.reduce((a, b) => a * b);
          input = Float32List(totalElements);
          int dataIndex = 0;
          for (int i = 0; i < totalElements; i++) {
            if (dataIndex < bufferSize * 3) {
              int sensorIndex = dataIndex ~/ 3;
              int axisIndex = dataIndex % 3;
              input[i] = sensorBuffer[sensorIndex][axisIndex];
              dataIndex++;
            } else {
              input[i] = 0.0;
            }
          }
          inputTensorShape = inputShape;
        }
      } else if (inputShape.length == 3) {
        input = Float32List(bufferSize * 3);
        for (int i = 0; i < bufferSize; i++) {
          input[i * 3] = sensorBuffer[i][0];
          input[i * 3 + 1] = sensorBuffer[i][1];
          input[i * 3 + 2] = sensorBuffer[i][2];
        }
        inputTensorShape = [1, bufferSize, 3];
      } else {
        input = Float32List(bufferSize * 3);
        for (int i = 0; i < bufferSize; i++) {
          input[i * 3] = sensorBuffer[i][0];
          input[i * 3 + 1] = sensorBuffer[i][1];
          input[i * 3 + 2] = sensorBuffer[i][2];
        }
        inputTensorShape = inputShape;
      }

      var inputTensor = input.reshape(inputTensorShape);

      var outputShape = interpreter.getOutputTensor(0).shape;
      var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
          .reshape(outputShape);

      interpreter.run(inputTensor, output);

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

      int maxIndex = 0;
      double maxValue = predictions[0];

      for (int i = 1;
          i < predictions.length && i < activityLabels.length;
          i++) {
        if (predictions[i] > maxValue) {
          maxValue = predictions[i];
          maxIndex = i;
        }
      }

      print('Predictions: $predictions');
      print('Max confidence: $maxValue for ${activityLabels[maxIndex]}');

      if (maxValue > 0.3) {
        return activityLabels[maxIndex];
      } else {
        return null;
      }
    } catch (e) {
      print('Prediction error: $e');
      return null;
    }
  }
}
