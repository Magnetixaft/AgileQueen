import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_handler.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/theme.dart';
//import 'package:flutter_application_1/theme_elicit.dart';
import 'AuthenticationHandler.dart';

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

/// The main widget for ELLI
///
/// This widget is presented when the app is started and, whilst Firebase is initializing, a [CircularProgressIndicator] i returned.
/// Once Firebase is initialized, [MyHomePage] is returned.
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Bookings',
      //theme: elicitTheme(),
      theme: ElliTheme.lightTheme,
      //darkTheme: ThemeData.dark(),
      //themeMode: ThemeMode.system,
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
            // print("Firebase initialized correctly");
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
/// A login page that navigates to [Home] when login is successful.
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /// Tests if a user is already logged in with Azure by calling [login] after the widget has been initially built.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      checkIfLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Container(
                width: 700,
                child: Column(
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
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                  onPressed: () => {login()},
                                  child: const Text(
                                    "Login with Azure",
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ))));
  }

  /// Navigates to [Home] when login is successful. Initializes the [FirebaseHandler] using email from AuthenticationHandler
  Future<void> login() async {
    AuthenticationHandler authenticationHandler = AuthenticationHandler.getInstance();
    try {
      await authenticationHandler.login();
      if (await authenticationHandler.isUserSignedIn() == true) {
        // this is not optimal, but work in progress.
        FirebaseHandler.initialize(await authenticationHandler.getUserEmail());
        await FirebaseHandler.getInstance().buildStaticModel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
      }
    } catch (e) {
      print(e.toString());
    }
    //TODO for debugging using the web. Remove before shipping.
    //  FirebaseHandler.initialize("testing");
    //  FirebaseHandler.getInstance().buildStaticModel().then((value) {
    //    Navigator.pushReplacement(
    //        context,
    //        MaterialPageRoute(
    //            builder: (context) =>
    //            const Home()));
    //  });
  }

  Future<void> checkIfLoggedIn() async {
    AuthenticationHandler authenticationHandler = AuthenticationHandler.getInstance();
    try{
      if(await authenticationHandler.isUserSignedIn()==true){
        FirebaseHandler.initialize(await authenticationHandler.getUserEmail());
        await FirebaseHandler.getInstance().buildStaticModel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
      }
    }catch (e) {
      print(e.toString());
    }
  }
}
