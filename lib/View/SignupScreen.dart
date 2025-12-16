import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:shigoto/View/DashboardScreen.dart';

import '../Controller/Authentication.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final UsernameController = TextEditingController();
  final Authentication auth = Authentication();
  bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4169E1),
      body: SingleChildScrollView(
      child:SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Vector image at the top
                Container(
                  height: 200,
                  width: 300,
                  child: Image.asset("assets/images/signupVector.png"),
                ),

                // White container with form fields
                Container(
                  height: 410,
                  width: 380,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Color(0xFF4169E1),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Full Name
                      TextField(
                        controller: UsernameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          fillColor: Colors.grey[200],
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Email
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          fillColor: Colors.grey[200],
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          fillColor: Colors.grey[200],
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sign Up button
                      SizedBox(
                        width: 250,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                            setState(() => _isLoading = true);

                            String res = await auth.signUp(
                              username: UsernameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                            if (!mounted) return; // Safety check

                            if (res == "Success") {
                              print("SignUp successful, navigating to Dashboard");

                              Navigator.pushReplacementNamed(context, '/Dashboard');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(res)),
                              );
                            }

                            setState(() => _isLoading = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4169E1),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // OR Divider
                      Row(
                        children: const [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('OR'),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Google Sign-in Button
                      SizedBox(
                        width: 300,
                        height: 30,
                        child: SignInButton(
                          Buttons.Google,
                            onPressed: _isLoading
                            ? null
                            : () async {
                      setState(() => _isLoading = true);

                      String res = await auth.signInWithGoogle();

                      if (!mounted) return;

                      if (res == "Success") {
                      Navigator.pushReplacementNamed(context, '/Dashboard');
                      } else if (res == "Cancelled") {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Google sign-in cancelled")));
                      } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(res)));
                      }

                      setState(() => _isLoading = false);
                      },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      // Already have account?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                              "Already have an account?", style: TextStyle(
                              fontSize: 14)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

}