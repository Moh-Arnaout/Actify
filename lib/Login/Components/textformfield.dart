import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  final String hinttext;
  final TextEditingController mycontroller;
  final IconData myicon;
  final String? Function(String?)? validator;

  const CustomTextForm(
      {super.key,
      required this.hinttext,
      required this.mycontroller,
      required this.myicon,
      required this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: mycontroller,
      decoration: InputDecoration(
        prefixIcon: Icon(myicon),
        hintText: hinttext,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Appcolors.googleback, width: 1),
        ),
      ),
    );
  }
}
