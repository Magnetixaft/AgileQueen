import 'package:flutter/material.dart';
import 'package:flutter_application_1/tabs/detailed_view.dart';

//This class represents an item that populates the bookingList in the 
//Bookings class. 
//Currently, it is a list of random test objects. The idea is to get a booking
//object from Firebase. 
class BookingItem extends StatelessWidget {
  const BookingItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _openDetailedView(context),
        child: Container(
          margin: const EdgeInsets.all(10.0),
          color: Colors.blue,
          height: 48.0,
        ));
  }

  void _openDetailedView(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("[Rumsnamn]"), //booking.getRoomName or something.
          content: const DetailedView(),
          elevation: 24.0,
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                primary: Colors.black,
                backgroundColor: Colors.grey[100],
                onSurface: Colors.grey,
              ),
            ),
            TextButton(
                child: const Text("Delete Booking"),
                onPressed: () {
                  //TODO: Function call to delete booking and redraw Bookings
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.red[600],
                  onSurface: Colors.red[350],
              ),
            )
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

}
