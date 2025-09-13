# Actify

Your Health. Your Journey. Simplified. 💪✨

---

## Overview

Actify is a wellness mobile application that transforms daily motion data captured from smartphones into meaningful health insights. Unlike traditional fitness apps that count steps, Actify analyzes activity patterns such as walking, standing, sitting, climbing stairs, and lying down to assess their effects on cardiovascular, respiratory, and joint health. The app provides users with an easy-to-understand percentage score, empowering them to improve their well-being through small, actionable lifestyle changes.

---

## Key Features

- **Home Page Hub:** Central navigation for all app features.
- **AI-Powered Activity Tracker:** Detects, logs, and analyzes user movements including walking, sitting, standing, and climbing stairs.
- **Health Metrics Dashboard:** Visualizes how daily activity ratios impact heart, lungs, and joints.
- **Wellness AI Chatbot:** Uses the Deepseek API to answer user questions about activity patterns and provide health guidance.
- **Accurate Activity Recognition:** Leveraging deep learning on mobile sensor data for reliable classification.

---

## Technologies and Tools

- **Flutter:** Primary framework for cross-platform mobile app development.
- **Python:** Used for signal processing, data preprocessing, and AI model development.
- **TensorFlow / Keras:** Built the Convolutional Neural Network (CNN) model to classify user activities from accelerometer data.
- **TensorFlow Lite (TFLite):** Converted the trained AI model for deployment on mobile devices within the Flutter app.
- **Deepseek API:** Integrated as the backend for the Wellness AI Chatbot to provide user support and health tips.
- **WISDM Dataset:** Used combined Wireless Sensor Data Mining Lab datasets for training and testing the activity recognition model.

---

## AI Modeling

- Collected and merged accelerometer sensor datasets (x, y, z coordinates) reflecting various user activities.
- Preprocessed data by cleaning, filtering, and framing sensor time-series for neural network input.
- Developed a CNN with multiple Conv2D layers utilizing batch normalization, dropout, and global average pooling.
- Achieved an overall activity classification accuracy of 95.8%, with balanced precision and recall across classes like walking, sitting, jogging, and stair climbing.
- The AI model was converted to TFLite format for smooth integration into the mobile app.

---

## Health Scoring System

- Based on research from WHO, AHA, CDC, Arthritis Foundation, and ACSM.
- Translates physical activity patterns into health impact scores for heart, lungs, and joints.
- Factors in activity intensity, duration, and type (e.g., stair climbing has a higher positive impact).
- Penalizes prolonged sitting or lying beyond 2 hours due to associated health risks.
- Provides users with a baseline score and updates it based on daily movement to motivate healthier habits.

---

## IEEE MotionSense AI Competition 2025 🎉🏆

Actify was created as part of the **IEEE MotionSense AI Competition 2025** held in **Amman, Jordan**, supervised and judged by **MathWorks**. Out of **64 teams** participating and **16 final submissions**, Actify proudly secured **3rd place** in this prestigious tournament! 🥉

Our team consisted of three dedicated members:
- Mohammad Arnaout
- Odai Altamrawi
- Mu'taz Muneer

This achievement highlights our commitment to leveraging AI and signal processing for real-world health applications. 🚀💡

---

## App Structure

- **Home:** Gateway to all features with easy access.
- **Activity Tracker:** Real-time detection and logging of motion activity.
- **Health Metrics:** Displays the efficiency scores for joints, heart, and lungs.
- **AI Chatbot:** Interactive assistant answering health-related queries and providing personalized guidance.

---

## Installation & Usage

1. Clone this repository.
2. Ensure Flutter is installed and set up on your machine.
3. Install dependencies using `flutter pub get`.
4. The AI model (`model.tflite`) is included and ready for use within the app.
5. Run the app on an Android/iOS device or emulator.
6. For the AI chatbot functionality, an API key for Deepseek API is required and should be configured in the app.

---

## References

- Dataset: [WISDM Dataset](https://www.cis.fordham.edu/wisdm/dataset.php)
- TFLite Flutter Package: [tflite_flutter](https://pub.dev/packages/tflite_flutter)
- WHO Guidelines on Physical Activity and Health: [WHO Publication](https://www.who.int/publications/i/item/9789240015128)
- Deepseek API Docs: [Deepseek API](https://api-docs.deepseek.com/)

## Contact

- Contact me via:
1- Email : Mohammadrami15@yahoo.com
2- Phone : +926797055476
3- LinkedIn : www.linkedin.com/in/mohammad-arnaout-9003b52b3

Thanks for reading!
