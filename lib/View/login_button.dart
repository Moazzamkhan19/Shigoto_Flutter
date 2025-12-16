import 'package:flutter/material.dart';
import 'package:shigoto/View/DashboardScreen.dart';
class LoginButton extends StatefulWidget {
  final VoidCallback onTap;

  const LoginButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF4169E1),
      end: const Color(0xFF5A8FF1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() async {
    await _controller.forward();

    if (mounted) {
      widget.onTap(); // calls login() from LoginScreen
    }

    _controller.reverse(); // optional: animate back
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 250,
          height: 30,
          child: ElevatedButton(
            onPressed: _onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorAnimation.value,
              elevation: 2,
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
