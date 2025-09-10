import 'package:final_model_ai/Login/login.dart';
import 'package:final_model_ai/Login/signup.dart';
import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class First extends StatelessWidget {
  const First({super.key});

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width / 1.4;
    double buttonHeight = 55;

    return Scaffold(
      body: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Logo / Illustration
              Image.asset(
                "Images/logo2.png",
                width: 150,
              ),
              const SizedBox(height: 40),

              /// Main Title
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.3,
                child: Text(
                  'Welcome To The Future Of Health',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.firaSans(
                    color: Appcolors.primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Subtitle tagline
              Text(
                'Your Health, Your Journey\nSimplified.',
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 100),

              /// Buttons Section
              Column(
                children: [
                  SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Appcolors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        shadowColor: Colors.black26,
                      ),
                      onPressed: () => Get.to(() => const LoginPage()),
                      child: Text(
                        "Login",
                        style: GoogleFonts.firaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Appcolors.tertiarycolor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: Appcolors.primaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Get.to(const SignUpPage());
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.firaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Appcolors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
