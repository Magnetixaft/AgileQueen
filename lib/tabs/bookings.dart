import 'package:flutter/material.dart';
import 'package:flutter_application_1/tabs/booking_item.dart';

//This class is really just a list that contains BookingItems
class Bookings extends StatefulWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  List<Widget> bookingList = <Widget>[];

  @override
  Widget build(BuildContext context) {
    
    // Generating tiles and adding to our BookingList
    for (var i = 0; i < 1000; i++) {
      if (i % 13 == 0) {
        bookingList.add(const SizedBox(height: 10));
        bookingList.add(const Text(
          "Today",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold),
          ), 
        );
        bookingList.add(const SizedBox(height: 5));
      } else {
        bookingList.add(const BookingItem());
      }
    }

    // Building our actual widget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 10),
        const Text("    My bookings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            )),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: bookingList,
          ),
        ),
      ],
    );
  }
}
