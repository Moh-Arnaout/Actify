import 'package:final_model_ai/Home/home.dart';
import 'package:final_model_ai/Login/First.dart';
import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEDF2F7), // light gray
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Get.to(() => const First()),
                    child: SvgPicture.asset(
                      'Images/back2.svg',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),

                //  App Logo (optional)
                Image.asset(
                  'Images/logo2.png',
                  width: 120,
                ),

                const SizedBox(height: 30),

                /// Welcome text
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.firaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Appcolors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter your username and password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 40),

                /// Username field
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Appcolors.googleback, width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Password field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Appcolors.googleback, width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black26,
                    ),
                    onPressed: () {
                      Get.offAll(() => const Homepage());
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.firaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Appcolors.tertiarycolor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Forgot Password
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Appcolors.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Divider with OR
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),

                const SizedBox(height: 20),

                /// Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Appcolors.textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.firaSans(
                          decoration: TextDecoration.underline,
                          decorationColor: Appcolors.primaryColor,
                          color: Appcolors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
