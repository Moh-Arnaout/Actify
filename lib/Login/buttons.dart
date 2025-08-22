import 'package:flutter/material.dart';
import 'package:mohammad_model/theme.dart';

class Buttons extends StatefulWidget {
  const Buttons(this.tname, {super.key, required this.onPressed});
  final String tname;
  final void Function()? onPressed;
  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Appcolors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.tname,
          softWrap: true,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Appcolors.tertiarycolor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
