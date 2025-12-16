import 'package:flutter/material.dart';
import 'package:shigoto/Controller/Authentication.dart';
import 'package:shigoto/View/DashboardScreen.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:shigoto/View/login_button.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});
  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final Authentication aut = Authentication();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4169E1),
      body: SingleChildScrollView(
        child :SafeArea(
          child: Center(
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Vector image
                    Image.asset(
                      "assets/images/loginVector.png",
                      width: 2500,
                      height: 250,
                    ),

                    const SizedBox(height: 10),

                    // White container with text fields and buttons
                    Container(
                      height: 400,
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
                            "Welcome Back",
                            style: TextStyle(
                              color: Color(0xFF4169E1),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Email field
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              fillColor: Colors.grey[200],
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Password field
                          TextField(
                            controller: passwordController,
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

                          // Login Button
                          Center(
                            child: LoginButton(
                              onTap: () async{
                                String res = await aut.login(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim());
                                if (res == "Success")
                                {
                                  Navigator.pushReplacementNamed(context, '/Dashboard');
                                }
                                else
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("res")));
                                }},
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
                          const SizedBox(height: 10),
                          // Google Sign-in Button
                          SizedBox(
                            width: 300,
                            height: 30,
                            child: SignInButton(
                              Buttons.Google,
                              onPressed: () async
                              {
                                aut.signInWithGoogle();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          // Sign Up row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?", style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(context, '/Signup');
                                },
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )

            ),
          ),
        ),
      )

    );
  }
}
