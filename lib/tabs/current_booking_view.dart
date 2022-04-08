import 'package:flutter/material.dart';
import 'package:flutter_application_1/FirebaseHandler.dart';

class CurrentBookingView extends StatefulWidget {
  const CurrentBookingView({Key? key}) : super(key: key);

  @override
  State<CurrentBookingView> createState() => _CurrentBookingViewState();
}

class _CurrentBookingViewState extends State<CurrentBookingView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Center(child: Text('Current bookings for ${FirebaseHandler.getInstance().getName()}'),),
        ),
        Expanded(
            child: ListView(
          children: getBookedTiles(),
        ))
      ],
    );

  }

  List<Widget> getBookedTiles() {
    var bookedTiles = <Widget>[];
    var bookings = FirebaseHandler.getInstance().getUserBookings();
    bookings.sort();

    for (String booking in bookings) {
      var roomDayTimeslotStrings = booking.split(' ');
      var roomNr = int.parse(roomDayTimeslotStrings[1]);
      var dayNr = int.parse(roomDayTimeslotStrings[3]);
      var timeslot = int.parse(roomDayTimeslotStrings[5]);
      bookedTiles.add(ListTile(
        title: Text(booking),
        trailing: ElevatedButton(
            child: const Text('Remove'),
            onPressed: () {
              FirebaseHandler.getInstance().removeBooking(roomNr, dayNr, timeslot);
              FirebaseHandler.getInstance().getData();
              setState(() {
              });
            }),
      ));
    }

    return bookedTiles;
  }
}
