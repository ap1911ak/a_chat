import 'package:a_chat/features/auth/presentation/screen/signup.dart';
// ignore: unused_import
import 'package:a_chat/features/auth/presentation/screen/wellcome.dart';
import 'package:a_chat/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:a_chat/features/chat/presentation/screen/chat_list.dart';
import 'package:a_chat/model/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:a_chat/injection_container.dart' as sl;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile(email: '', password: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

   @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
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
                              "Log In",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen()),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          initialValue:"aa@gmail.com", ////For Test
                          decoration: InputDecoration(
                              labelText: "Email ",
                              border: OutlineInputBorder()),
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: "Email is required"),
                            EmailValidator(errorText: "Invalid email format")
                          ]).call,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (String? email) {
                            profile.email = email!;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          initialValue:"123456", ////For Test
                          decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.visibility_off))
                              , // Placeholder for show/hide password
                          validator: RequiredValidator(
                              errorText: "Password is required").call,
                          obscureText: true,
                          onSaved: (String? password) {
                            profile.password = password!;
                          },
                        ),
                        SizedBox(height: 20),
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
                              "Log In",
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState?.save();
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: profile.email,
                                          password: profile.password)
                                      .then((value) {
                                    formKey.currentState?.activate();
                                    
                                    // ignore: use_build_context_synchronously
                                    Navigator.pushReplacement(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BlocProvider<ChatBloc>(
                                                create: (_) => sl.sl<ChatBloc>(),
                                                child: ChatListScreen(),
                                              )),
                                    );
    
                                  });
                                } on FirebaseAuthException catch (e) {
                                  Fluttertoast.showToast(
                                      msg: e.message!,
                                      gravity: ToastGravity.CENTER);
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Implement forgot password logic here
                            },
                            child: Text(
                              "Forgot your password?",
                              style: TextStyle(color: Colors.green),
                            ),
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