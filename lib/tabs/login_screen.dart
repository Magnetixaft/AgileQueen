import 'package:flutter/material.dart';
import 'package:flutter_application_1/FirebaseHandler.dart';

import '../main.dart';

class LoginView extends StatefulWidget {
  final LoginListener loginListener;
  const LoginView(this.loginListener, {Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  var textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget> [
            Container(
              width: 300,
              height: 60,
              child: const Center(child:  Text('Enter your unique username')),
            ),

            Container(
              width: 200,
              child: TextField(
                controller: textController,
                onSubmitted: (text) {
                  continueLogin(text);
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'username',
                ),
              ),
            ),

            Container(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                continueLogin(textController.text);
              }, child: FirebaseHandler.isInitialized() ? const Text('Change user') : const Text("Login"),
            ),
          ]
      ),
    );
  }

  void continueLogin(String username) {
    if(username != '') {
      FirebaseHandler.initialize(username);
      widget.loginListener.alert();
      setState(() {
      });
    }
  }
}
