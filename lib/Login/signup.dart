import 'package:final_model_ai/Home/home.dart';
import 'package:final_model_ai/Login/login.dart';
import 'package:final_model_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedBloodType = 'A+';
  String _selectedGender = 'Male';
  bool _obscurePassword = true;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> _genders = ['Male', 'Female'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

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
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      'Images/back2.svg',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),

                /// App Logo
                Image.asset(
                  'Images/logo2.png',
                  width: 100,
                ),

                const SizedBox(height: 20),

                /// Welcome text
                Text(
                  'Create Account',
                  style: GoogleFonts.firaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Appcolors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Join us for a healthier journey',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 30),

                /// Personal Information Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Personal Information',
                    style: GoogleFonts.firaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Appcolors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                /// Full Name field
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: 'Full Name',
                    hintStyle: GoogleFonts.notoSansTangsa(fontSize: 15),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Appcolors.boardercolor, width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// Username field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.alternate_email),
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Appcolors.googleback, width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Appcolors.googleback, width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Appcolors.googleback, width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Health Information Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Health Information',
                    style: GoogleFonts.firaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Appcolors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                /// Age and Weight Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today),
                          hintText: 'Age',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Appcolors.googleback, width: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.monitor_weight),
                          hintText: 'Weight (kg)',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Appcolors.googleback, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// Blood Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedBloodType,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.bloodtype),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Appcolors.googleback, width: 1),
                    ),
                  ),
                  items: _bloodTypes.map((String bloodType) {
                    return DropdownMenuItem<String>(
                      value: bloodType,
                      child: Text(
                        'Blood Type: $bloodType',
                        style: GoogleFonts.tajawal(),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBloodType = newValue!;
                    });
                  },
                  dropdownColor: Appcolors.tertiarycolor,
                ),

                const SizedBox(height: 15),

                /// Gender Dropdown
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(8),
                  value: _selectedGender,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Appcolors.googleback, width: 1),
                    ),
                  ),
                  items: _genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(
                        'Gender: $gender',
                        style: GoogleFonts.tajawal(),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
                  dropdownColor: Appcolors.tertiarycolor,
                ),

                const SizedBox(height: 30),

                /// Create Account Button
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
                      // Validate and create account
                      if (_validateForm()) {
                        Get.to(() => const Homepage());
                      }
                    },
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.firaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Appcolors.tertiarycolor,
                      ),
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

                /// Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Appcolors.textColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const LoginPage()),
                      child: Text(
                        'Sign In',
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    if (_fullNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your full name');
      return false;
    }
    if (_usernameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a username');
      return false;
    }
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      Get.snackbar('Error', 'Please enter a valid email');
      return false;
    }
    if (_passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return false;
    }
    if (_ageController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your age');
      return false;
    }
    if (_weightController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your weight');
      return false;
    }
    return true;
  }
}
