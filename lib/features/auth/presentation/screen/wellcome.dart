import 'package:a_chat/features/auth/presentation/screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class WelcomeScreen extends StatelessWidget {
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"), // Changed title to English
        backgroundColor: Colors.green[500],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              Text(
                auth.currentUser?.email ?? "User", // Display user email if available
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red button for logout
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  "Log Out", // Changed text to English
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                onPressed: () {
                  auth.signOut().then((value) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context,
                        MaterialPageRoute(builder: (context) {
                      return HomeScreen(); // Navigate back to HomeScreen after logout
                    }));
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}