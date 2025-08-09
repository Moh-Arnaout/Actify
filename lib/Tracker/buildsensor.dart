import 'package:flutter/material.dart';

class Buildsensor extends StatelessWidget {
  const Buildsensor(this.axis, this.type, this.colors, {super.key});

  final String axis;
  final double type;
  final MaterialColor colors;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colors,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colors, width: 2),
          ),
          child: Center(
            child: Text(
              axis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '$type',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
