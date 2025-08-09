import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mohammad_model/AI/aibot.dart';
import 'package:mohammad_model/Tracker/activity.dart';
import 'package:mohammad_model/Home/home.dart';
import 'package:mohammad_model/theme.dart';

class Bottombar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const Bottombar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      fixedColor: Appcolors.secondaryColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () {
              Get.to(() => Homepage());
            },
            child: Icon(
              Icons.home,
              color: Appcolors.primaryColor,
            ),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
              onTap: () {
                Get.to(() => ActivityRecognitionScreen());
              },
              child: Icon(Icons.fitness_center, color: Appcolors.primaryColor)),
          label: 'Tracker',
        ),
        BottomNavigationBarItem(
          icon:
              Icon(Icons.monitor_heart_rounded, color: Appcolors.primaryColor),
          label: 'Health',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
              onTap: () {
                Get.to(() => Aibot());
              },
              child: Icon(Icons.chat, color: Appcolors.primaryColor)),
          label: 'AI Bot',
        ),
      ],
    );
  }
}
