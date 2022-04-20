import 'package:firebase_auth_oauth/firebase_auth_oauth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/AuthenticationHandler.dart';
import 'package:flutter_application_1/FirebaseHandler.dart';
import 'package:flutter_application_1/tabs/booking_view.dart';
import 'package:flutter_application_1/tabs/changebooking.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/tabs/current_booking_view.dart';
import 'package:flutter_application_1/tabs/firebasedemoview.dart';

import 'colors.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.grey, // TODO Custom Swatch
      ),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var authentication = AuthenticationHandler.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: elicitWhite,
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
                    ElevatedButton(
                    onPressed: () async {
                      authentication.login();
                    }, child: Text("Sign in With Azure"),
                    ),

                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Email or phone number',
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Password',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => {
                          print("Todo, Show modal"),
                        },
                        child: const Text("Forgot Password?"),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  elicitGreen)),
                          onPressed: () => {
                                print("TODO Login using Firebase Auth"), // TODO Add text controllers for above fields an loding using firebase auth
                                Navigator.push(
                                    // TODO use pushReplacement when login has been implemented. That way, the uswer will not be able to return to this page by pressing the back arrow
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Home()))
                              },
                          child: Text(
                            "Login",
                            style: TextStyle(color: elicitWhite),
                          )),
                    ),
                    TextButton(
                      onPressed: () => {
                        print("Todo, Show modal"),
                      },
                      child: const Text("Create an account"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}