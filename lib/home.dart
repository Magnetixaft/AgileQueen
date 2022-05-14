import 'package:flutter/material.dart';
import 'package:flutter_application_1/tabs/booking_view.dart';
import 'package:flutter_application_1/tabs/booking_view2.dart';
import 'package:flutter_application_1/tabs/bookings.dart';
import 'package:flutter_application_1/tabs/profile_settings.dart';

/// A tab-based view that acts as the apps top most page.
///
/// This page is navigated to when a user has logged in.
/// The page has three tabs selecatble by the user: [BookingView], [Bookings] and [Profile].
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  /// The index currently selected in the BottomNavigationBar.
  int _selectedIndex = 0;
  
  /// The list of tabs/pages selectable using the BottomNavigationBar.
  final List<Widget> _tabs = <Widget>[
    BookingView(),
    const Bookings(),
    const Profile()
  ];
  
  /// Switches tab to [index].
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
        child: _tabs.elementAt(_selectedIndex),
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
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        //selectedItemColor: elicitGreen,
        onTap: _onItemTapped,
      ),
    );
  }
}
