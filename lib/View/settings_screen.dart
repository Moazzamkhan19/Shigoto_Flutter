import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shigoto/Components/MyTextFields.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Controller/Authentication.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  final TextEditingController nameController = TextEditingController();

  static const String _settingsImagePath = 'assets/images/setting_vector.png';

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: const Color(0xFF4169E1),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/Dashboard');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 30,
        ),
      ),
      body: Column(
        children: [

          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            color: const Color(0xFF4169E1),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                _settingsImagePath,
                fit: BoxFit.contain, // Ensures the whole image is visible
                height: 300, // You can adjust the height as needed
              ),
            ),
          ),
          // ------------------------------------

          // --- White Settings Content Area ---
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: SingleChildScrollView( // Added SingleChildScrollView for safety
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile Settings",
                      style: TextStyle(
                        fontSize: 22, // Increased font size for title
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    //---HELP SUPPORT
                    // --- HELP SUPPORT BUTTON ---
                    Center(
                      child: InkWell(
                        onTap: () async {
                          final Uri emailUri = Uri(
                            scheme: 'mailto',
                            path: 'moazzamk12319@gmail.com', // replace with your support email
                            queryParameters: {
                              'subject': 'Help Support',
                              'body': 'Hello, I need assistance with...'
                            },
                          );
                          if (await canLaunchUrl(emailUri)) {
                            await launchUrl(emailUri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Could not open email app'))
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.help, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Help Support",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),


                    // --- Delete Profile Button ---
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5, // Add some elevation
                        ),
                        onPressed: () async {
                          final TextEditingController passwordController = TextEditingController();

                          // Show dialog to enter password
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Enter your password to delete your profile'),
                                    const SizedBox(height: 15),
                                    TextField(
                                      controller: passwordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: "Password",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();

                                      final auth = Authentication();
                                      final user = FirebaseAuth.instance.currentUser;

                                      if (user != null) {
                                        String result = await auth.deleteProfile(
                                          userId: user.uid,
                                          email: user.email ?? "",
                                          password: passwordController.text,
                                        );

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(result)),
                                        );

                                        if (result == "Profile deleted successfully") {
                                          // Redirect to login or landing page
                                          Navigator.pushReplacementNamed(context, '/Login');
                                        }
                                      }
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          "Delete Profile",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // -----------------------------
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  //shows dialouge box for deletion
  Future<void> showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Enter Password'),
                //we need to call the validate method to validate password then
                //proceed with deletion
                SizedBox(height: 15,),
                Mytextfields(label: "Password")
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {

                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

}