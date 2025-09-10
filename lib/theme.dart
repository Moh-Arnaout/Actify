import 'package:flutter/material.dart';

class Appcolors {
  static Color primaryColor = const Color(0xFF0F67FE);
  //static Color primaryAccent = Color.fromRGBO(120, 14, 14, 1);
  static Color secondaryColor = const Color(0xFF001141);
  //static Color secondaryAccent = Color.fromRGBO(35, 35, 35, 1);
  static Color subtitleColor = const Color.fromRGBO(37, 37, 37, 1);
  static Color textColor = const Color.fromRGBO(37, 37, 37, 1);
  static Color fieldcolor = const Color(0xFFA8A49E);
  static Color highlightColor = const Color.fromRGBO(212, 172, 13, 1);
  static Color backcolor = const Color.fromRGBO(240, 240, 240, 1);
  static Color tertiarycolor = const Color(0xFFFFFFFF);
  static Color googleback = const Color(0xFF1A73E8);
  static Color fieldbackcolor = const Color.fromARGB(255, 239, 239, 239);
  static Color boardercolor = const Color(0xFFE0DAD3);
  static Color cardcolor = const Color.fromARGB(255, 255, 255, 255);
  static const Color heart = Color(0xFFFA4D5E);
  static const Color lungs = Color(0xFF0F67FE);
  static const Color joint = Color(0xFF08BDBA);
  static Color currentactivity = const Color(0xFF002159);
  static const Color start = Color(0xFFFF4154);
  static final LinearGradient appBarGradient = LinearGradient(
    colors: [
      Appcolors.primaryColor,
      Appcolors.secondaryColor,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  ThemeData primaryTheme = ThemeData(
    //scaffold color
    scaffoldBackgroundColor: Appcolors.backcolor,

    //App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: Appcolors.backcolor,
      foregroundColor: Appcolors.textColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),

    //Text theme
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        color: Appcolors.textColor,
        fontSize: 16,
        letterSpacing: 1,
      ),
      headlineMedium: TextStyle(
        color: Appcolors.subtitleColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
      titleMedium: TextStyle(
        color: Appcolors.subtitleColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    ),

    //card theme
    cardTheme: CardThemeData(
      // ignore: deprecated_member_use
      color: Appcolors.secondaryColor.withOpacity(0.5),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 16),
    ),

    //input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Appcolors.secondaryColor.withOpacity(0.5),
      border: InputBorder.none,
      labelStyle: TextStyle(color: Appcolors.textColor, fontSize: 16),
      prefixIconColor: Appcolors.textColor,
    ),
    // Dialog theme
    dialogTheme: DialogThemeData(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Appcolors.backcolor,
    ),
  );
}
