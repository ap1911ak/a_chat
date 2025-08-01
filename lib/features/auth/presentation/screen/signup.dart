import 'package:a_chat/features/auth/presentation/screen/signin.dart';
import 'package:a_chat/model/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile(email: '', password: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Error"),
            ),
            body: Center(child: Text("${snapshot.error}")),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInScreen()),
                                );
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: "Email ",
                              border: OutlineInputBorder()),
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: "Email  is required"),
                            EmailValidator(errorText: "Invalid email format")
                          ]).call,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (String? email) {
                            profile.email = email!;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.visibility_off)), // Placeholder for show/hide password
                          validator: RequiredValidator(
                              errorText: "Password is required").call,
                          obscureText: true,
                          onSaved: (String? password) {
                            profile.password = password!;
                          },
                        ),
                        SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Green button as in the image
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            onPressed: () async {
                                formKey.currentState?.save();
                                try {
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                          email: profile.email,
                                          password: profile.password)
                                      .then((value) {
                                    formKey.currentState?.reset();
                                    Fluttertoast.showToast(
                                        msg: "Account created successfully",
                                        gravity: ToastGravity.TOP);
                                    // ignore: use_build_context_synchronously
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) {
                                      return SignInScreen(); // Navigate to Login after successful registration
                                    }));
                                  });
                                  
                                } on FirebaseAuthException catch (e) {
                                  // ignore: avoid_print
                                  print(e.code);
                                  String message;
                                  if (e.code == 'email-already-in-use') {
                                    message =
                                        "This email is already in use. Please use another email.";
                                  } else if (e.code == 'weak-password') {
                                    message =
                                        "Password should be at least 6 characters.";
                                  } else {
                                    message = e.message!;
                                  }
                                  Fluttertoast.showToast(
                                      msg: message,
                                      gravity: ToastGravity.CENTER);
                                }
                              
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}