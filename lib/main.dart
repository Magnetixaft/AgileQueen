import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_application_1/tabs/bookingsview.dart';
import 'package:flutter_application_1/tabs/changebooking.dart';
import 'package:flutter_application_1/tabs/createbooking.dart';
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
        appId: "1:883336254219:web:7d2de78527260bb27e080e")
    );
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Bookings',
      theme: ThemeData(
        primarySwatch: Colors.blue, // TODO Custom Swatch
      ),
      home: FutureBuilder(
        //Initializes Firebase
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          //If Connection with Firebase failed
          if(snapshot.hasError){
            print("Firebase initialization error");
          }
          //Checks connection to Firebase and when done loads HomePage
          if(snapshot.connectionState == ConnectionState.done){
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
  int _selectedIndex = 0;

  final List<Widget> _buildTabViews = [
    FirebaseDemoView(),
    const BookingsView(),
    const CreateBookingView(),
    const ChangeBookingView(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: elicitGreen,
            groupAlignment: 0.0,
            labelType: NavigationRailLabelType.selected,
            destinations: <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.fire_extinguisher_outlined, color: elicitWhite, size: 40,),
                selectedIcon: Icon(Icons.fire_extinguisher, color: elicitWhite, size: 40,),
                label: Text('Firebase Demo', style: TextStyle(color: elicitWhite),),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month_outlined, color: elicitWhite, size: 40,),
                selectedIcon: Icon(Icons.calendar_month, color: elicitWhite, size: 40,),
                label: Text('View Bookings', style: TextStyle(color: elicitWhite),),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.create_outlined, color: elicitWhite, size: 40,),
                selectedIcon: Icon(Icons.create, color: elicitWhite, size: 40,),
                label: Text('Create Booking', style: TextStyle(color: elicitWhite),),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.cancel_outlined, color: elicitWhite, size: 40,),
                selectedIcon: Icon(Icons.cancel, color: elicitWhite, size: 40,),
                label: Text('Change Booking', style: TextStyle(color: elicitWhite),),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: Center(
              child: _buildTabViews[_selectedIndex],
            ),
          )
        ],
      ),
    );
  }


}



