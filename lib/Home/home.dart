import 'package:flutter/material.dart';
import 'package:mohammad_model/bottombar.dart';
import 'package:mohammad_model/Home/fitnesscard.dart';
import 'package:mohammad_model/Home/healthcard.dart';
import 'package:mohammad_model/theme.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Bottombar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Appcolors.secondaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.settings,
              color: Appcolors.tertiarycolor,
            ),
            Icon(
              Icons.notifications,
              color: Appcolors.tertiarycolor,
            ),
          ],
        ),
      ),
      backgroundColor: Appcolors.backcolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Appcolors.secondaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Row
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Appcolors.backcolor,
                          radius: 22,
                          backgroundImage: const AssetImage('Images/User2.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Hi, Mohammad!',
                                style: TextStyle(
                                  color: Appcolors.tertiarycolor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.waving_hand,
                                color: Colors.yellow,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Info Row
                    Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: Appcolors.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, yyyy-MM-dd').format(DateTime.now()),
                          style: TextStyle(
                            color: Appcolors.tertiarycolor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star,
                          color: Color.fromARGB(255, 238, 215, 41),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pro Member',
                          style: TextStyle(
                            color: Appcolors.tertiarycolor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Fitness And Activity Tracker',
                          style: TextStyle(
                              color: Appcolors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Your top 3 activites for today:',
                          style: TextStyle(
                              color: Appcolors.secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const FitnessCard(
                      'Walking',
                      'You have walked for 40 mins today!',
                      'Images/Walking.png'),
                  const SizedBox(
                    height: 10,
                  ),
                  const FitnessCard('Sitting',
                      'You have sat for 60 mins today!', 'Images/Sitting.png'),
                  const SizedBox(
                    height: 10,
                  ),
                  const FitnessCard(
                      'Standing',
                      'You have stood up for 3 hrs today!',
                      'Images/Standing.png'),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text('Health Metrics',
                          style: TextStyle(
                              color: Appcolors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Your health indicators based on recent movements:',
                          style: TextStyle(
                              color: Appcolors.secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Healthcard('Heart', 'Your heart is performing at 85%',
                            'Images/heart.png', Appcolors.heart),
                        SizedBox(
                          width: 10,
                        ),
                        Healthcard('Lungs', 'Healthy breathing patterns',
                            'Images/lungs.png', Appcolors.lungs),
                        SizedBox(
                          width: 10,
                        ),
                        Healthcard('Joints', 'Good joint mobility',
                            'Images/bones1.png', Appcolors.joint),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text('Wellness AI Chatbot',
                          style: TextStyle(
                              color: Appcolors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(232, 0, 33, 89),
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        alignment: Alignment.centerRight,
                        image: AssetImage('Images/robot.png'),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              'Your Wellness \nAI Chatbot',
                              style: TextStyle(
                                color: Appcolors.tertiarycolor,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      //Bottombar();
    );
  }
}
