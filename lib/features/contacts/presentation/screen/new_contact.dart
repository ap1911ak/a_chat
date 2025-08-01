// ignore: unused_import
import 'package:a_chat/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:a_chat/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';


class NewContactScreen extends StatefulWidget {
  const NewContactScreen({super.key});

  @override
  State<NewContactScreen> createState() => _NewContactScreenState();
}


class _NewContactScreenState extends State<NewContactScreen> {final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Dispatch event to load conversations when the page initializes
      BlocProvider.of<ContactsBloc>(context).add(GetContactsEvent(currentUser.uid));
    }
  // ignore: avoid_print
  print("UID : ${GetContactsEvent(currentUser!.uid)}");
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _addContact() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final contactEmail = _emailController.text.trim();
      if (contactEmail.isNotEmpty) { // เพิ่มการตรวจสอบนี้เพื่อความปลอดภัย
      BlocProvider.of<ContactsBloc>(context).add(
        AddContactEvent(contactEmail),
      );
    }
    }
    // ignore: avoid_print
    print("Data : ${_emailController.text.trim()}");
    //print("Data : ${p}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Contact"),
      ),
      body: BlocListener<ContactsBloc, ContactsState>(
        listener: (context, state) {
          if (state is ContactAddedSuccess) {
            Fluttertoast.showToast(msg: "Contact added successfully!");
            Navigator.pop(context); // Go back to contacts list
          } else if (state is ContactsError) {
            Fluttertoast.showToast(msg: state.message, gravity: ToastGravity.CENTER);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter contact's email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: const Icon(Icons.search), // As per image
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Email is required"),
                    EmailValidator(errorText: "Invalid email format"),
                  ]).call,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green button as in the image
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _addContact,
                    child: const Text(
                      "Add",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
  }
