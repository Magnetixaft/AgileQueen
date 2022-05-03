import 'package:flutter/material.dart';
import 'package:flutter_application_1/tabs/detailed_view.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

//This class represents an item that populates the bookingList in the
//Bookings class.
//Currently, it is a list of random test objects. The idea is to get a booking
//object from Firebase.
class BookingItem extends StatelessWidget {
  final String _roomName;
  final String _place;
  final String _address;
  final String _date;

  //const BookingItem({Key? key}) : super(key: key);
  const BookingItem(this._roomName, this._place, this._address, this._date,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _openDetailedView(context),
        child: Container(
          margin: const EdgeInsets.all(10.0),
          height: 48.0,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(6))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: _buildColumn(),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ],
          ),
        ));
  }

  Widget _buildColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 5),
        Text(
          _roomName + ', ' + _place,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(_address,
            style: const TextStyle(
              color: Colors.white,
            )),
      ],
    );
  }

  void _openDetailedView(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_roomName), //booking.getRoomName or something.
          content: DetailedView("Centralen", _address, _date, "Description"),
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
            ),
            IconButton(
              onPressed: () {
                Add2Calendar.addEvent2Cal(Event(
                  title: 'Event title', // TODO use firebase data
                  description: 'Event description',
                  location: 'Event location',
                  startDate: DateTime(2022, 06, 06, 08, 00),
                  endDate: DateTime(2022, 06, 06, 17, 00),
                ));
              },
              icon: const Icon(Icons.share),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }
}
