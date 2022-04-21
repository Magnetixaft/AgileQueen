import 'package:flutter/material.dart';
import 'package:flutter_application_1/tabs/detailed_view.dart';
import 'package:flutter_application_1/colors.dart';

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
        height: 48.0,
        decoration: BoxDecoration(
            color: elicitGreen,
            borderRadius: const BorderRadius.all(Radius.circular(6))),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 10),
            _buildColumn(),
            const SizedBox(width: 190),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ],
        ),
      )
    );
  }

  Widget _buildColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        SizedBox(height: 5),
        Text(
          "[Rumsnamn], [Plats]",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "Drottningtorget 5, 411 03 Göteborg",
          style: TextStyle(
            color: Colors.white,
          )
        ),
      ],
    );
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
