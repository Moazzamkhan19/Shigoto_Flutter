import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'DashboardScreen.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation for splash logo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Check auth state immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnAuth();
    });
  }

  // Check if user is logged in and navigate accordingly
  void _navigateBasedOnAuth() async {
    User? user = FirebaseAuth.instance.currentUser;

    // Optional: Add a short delay for splash effect
    await Future.delayed(const Duration(milliseconds: 800));

    if (user != null) {
      // User is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboardscreen()),
      );
    } else {
      // User not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Loginscreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4169E1),
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: const Text(
            'SHIGOTO',
            style: TextStyle(
              fontSize: 55,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 5,
              fontFamily: 'ArialRoundedMTBold',
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.white54,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




