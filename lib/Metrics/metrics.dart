// import 'package:flutter/material.dart';
// import 'package:mohammad_model/Metrics/metriccard.dart';
// import 'package:mohammad_model/bottombar.dart';
// import 'package:mohammad_model/theme.dart';

// class Metrics extends StatefulWidget {
//   const Metrics({super.key});

//   @override
//   State<Metrics> createState() => _MetricsState();
// }

// class _MetricsState extends State<Metrics> {
//   int _selectedIndex = 2;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         bottomNavigationBar: Bottombar(
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//         ),
//         backgroundColor: Appcolors.backcolor,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text(
//             'Health Metrics ',
//             style: TextStyle(color: Appcolors.tertiarycolor),
//           ),
//           backgroundColor: Appcolors.secondaryColor,
//           elevation: 1,
//         ),
//         body: Padding(
//             padding: EdgeInsets.all(20),
//             child: SingleChildScrollView(
//               child: Column(children: [
//                 Card(
//                   color: Appcolors.tertiarycolor,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15)),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Your Health at a Glance',
//                                   style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.w800,
//                                       color: Appcolors.primaryColor),
//                                 ),
//                                 Image.asset(
//                                   'Images/heart.png',
//                                   scale: 15,
//                                 )
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width:
//                                       MediaQuery.of(context).size.width / 1.3,
//                                   child: const Text(
//                                     '''Your scores are based on how you've balanced walking, sitting, and resting this week — showing how your activity supports your heart, lungs, and joints.''',
//                                     style: TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w700),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 // Replace HealthMetricsScreen() with HealthMetricsCards()
//                 HealthMetricsScreen()
//               ]),
//             )));
//   }
// }
