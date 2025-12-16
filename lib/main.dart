import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shigoto/View/AnalyticsScreen.dart';
import 'package:shigoto/View/SplashScreen.dart';
import 'package:shigoto/View/TeamMembersScreen.dart';
import 'package:shigoto/View/createTaskScreen.dart';
import 'package:shigoto/View/LoginScreen.dart';
import 'package:shigoto/View/DashboardScreen.dart';
import 'package:shigoto/View/ProjectBoardScreen.dart';
import 'package:shigoto/View/TaskDetail.dart';
import 'package:shigoto/View/settings_screen.dart';
import 'package:shigoto/View/Upcoming.dart';
import 'package:shigoto/View/Announcement.dart';
import 'View/SignupScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // start normally
      routes: {
        '/login': (context) => const Loginscreen(),
        '/Dashboard': (context) => const Dashboardscreen(),
        // '/ProjectBoard': (context) => const Projectboardscreen(),
       // '/CreateTask': (context) => CreateTaskScreen(),
        // '/TaskDetail': (context) => Taskdetail(),
        // '/TeamMember': (context) => TeamMemberScreen(),
        '/Settings': (context) => SettingsScreen(),
        '/Signup': (context) => SignupScreen(),
        '/Upcoming': (context) => UpcomingScreen(),
        '/Announcement': (context) => AnnouncementScreen(),
      },
    );
  }
}

