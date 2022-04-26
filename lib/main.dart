import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_handler.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/theme_elicit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // Firebase options related to FirebaseDB
      options: const FirebaseOptions(
          apiKey: "AIzaSyD71VJDiqwq5e2y7gpaszs4um91jR6tN1g",
          authDomain: "agilequeen-82096.firebaseapp.com",
          projectId: "agilequeen-82096",
          storageBucket: "agilequeen-82096.appspot.com",
          messagingSenderId: "883336254219",
          appId: "1:883336254219:web:7d2de78527260bb27e080e"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Bookings',
      theme: elicitTheme(),
      home: FutureBuilder(
        //Initializes Firebase
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          //If Connection with Firebase failed
          if (snapshot.hasError) {
            print("Firebase initialization error");
          }
          //Checks connection to Firebase and when done loads HomePage
          if (snapshot.connectionState == ConnectionState.done) {
            print("Firebase initialized correctly");
            return const MyHomePage(
              title: "Room Bookings",
            );
          }
          //Waiting for connection with Firebase
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

/// The login page
///
/// A login page that navigates to [Home] when login is succesful.
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final userIdTextController = TextEditingController();
  final userPasswordTextController = TextEditingController();
//  final focusNodePassword = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 80, 40, 20),
                child: Image.asset('assets/images/elicit_logo.png'),
              )),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Email or phone number',
                      ),
                      controller: userIdTextController,
//                      onSubmitted: (_) {
//                        // This moves the focus to the password field when the user presses "enter".
//                        FocusScope.of(context).requestFocus(focusNodePassword);
//                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      ),
                      controller: userPasswordTextController,
//                      onSubmitted: (_) {
//                        login();
//                      },
//                      focusNode: focusNodePassword,
                    ),
//                    Align(
//                      alignment: Alignment.centerRight,
//                      child: TextButton(
//                        onPressed: () => {
//                          print("Todo, Show modal"),
//                        },
//                        child: const Text("Forgot Password?"),
//                      ),
//                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () => {login()},
                          child: const Text(
                            "Login",
                          )),
                    ),
//                    TextButton(
//                      onPressed: () => {
//                        print("Todo, Show modal"),
//                      },
//                      child: const Text("Create an account"),
//                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  /// Logs the user in using Azure
  ///
  /// Navigates to [Home] when login is succesful. Initalizes the [FirebaseHandler] using the input from [userIdTextController]
  void login() {
    // TODO login using Firebase Auth
    String userId = userIdTextController.text;
    FirebaseHandler.initialize(userId);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const Home())); // TODO use pushReplacement when login has been implemented. That way, the user will not be able to return to this page by pressing the back arrow
  }
}
