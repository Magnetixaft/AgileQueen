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

    for (String booking in FirebaseHandler.getInstance().getUserBookings()) {
      var roomDayTimeslot = booking.split(' ');
      bookedTiles.add(ListTile(
        title: Text(booking),
        trailing: ElevatedButton(
            child: const Text('Remove (not functional)'),
            onPressed: () {
              setState(() {
                print('not supported yet');
              });
            }),
      ));
    }

    return bookedTiles;
  }
}
