import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mohammad_model/AI/aibot.dart';
import 'package:mohammad_model/Metrics/metriccard.dart';
import 'package:mohammad_model/Metrics/metrics.dart';
import 'package:mohammad_model/Tracker/activity.dart';
import 'package:mohammad_model/Home/home.dart';
import 'package:mohammad_model/theme.dart';

class Bottombar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const Bottombar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _widthAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();

    // Create animation controllers for each nav item
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    // Create width animations
    _widthAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 50.0,
              end: 120.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    // Create opacity animations for labels
    _opacityAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
            )))
        .toList();

    // Set initial state
    if (widget.currentIndex >= 0 && widget.currentIndex < 4) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(Bottombar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animations when currentIndex changes
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reverse old selection
      if (oldWidget.currentIndex >= 0 && oldWidget.currentIndex < 4) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }

      // Forward new selection
      if (widget.currentIndex >= 0 && widget.currentIndex < 4) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                onTap: () {
                  widget.onTap(0);
                  Get.to(() => Homepage());
                },
              ),
              _buildNavItem(
                icon: Icons.fitness_center_rounded,
                label: 'Tracker',
                index: 1,
                onTap: () {
                  widget.onTap(1);
                  Get.to(() => ActivityRecognitionScreen());
                },
              ),
              _buildNavItem(
                icon: Icons.monitor_heart_rounded,
                label: 'Health',
                index: 2,
                onTap: () {
                  widget.onTap(2);
                  Get.to(() => Metrics());
                },
              ),
              _buildNavItem(
                icon: Icons.chat_rounded,
                label: 'AI Bot',
                index: 3,
                onTap: () {
                  widget.onTap(3);
                  Get.to(() => Aibot());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _animationControllers[index],
        builder: (context, child) {
          return Container(
            width: _widthAnimations[index].value,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? Appcolors.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : Appcolors.primaryColor.withOpacity(0.6),
                  size: 24,
                ),
                if (_opacityAnimations[index].value > 0) ...[
                  const SizedBox(width: 8),
                  Opacity(
                    opacity: _opacityAnimations[index].value,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
