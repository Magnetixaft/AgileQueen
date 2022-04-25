import 'package:flutter/material.dart';
import 'package:flutter_application_1/tabs/booking_view.dart';
import 'package:flutter_application_1/tabs/bookings.dart';
import 'package:flutter_application_1/tabs/profile_settings.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const BookingView(),
    const Bookings(), // TODO Replace with tab
    const Profile() // TODO Replace with tab
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(10,0,0,0),
          child: Image.asset('assets/images/elicit_logo.png'),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        //selectedItemColor: elicitGreen,
        onTap: _onItemTapped,
      ),
    );
  }
}
