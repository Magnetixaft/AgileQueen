import 'package:flutter/material.dart';
import 'package:flutter_application_1/tabs/detailed_view.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

import 'bookings.dart';

/// This class represents an item that populates bookingList in [Bookings]
class BookingItem extends StatelessWidget {
  final String _roomName;
  final String _place;
  final String _address;
  final Date _date;
  final String _description;
  final String _timeslot;
  final String _attribute;
  final String _workspaceNr;
  final Function callback;

  const BookingItem(
      this._roomName,
      this._place,
      this._address,
      this._date,
      this._description,
      this._timeslot,
      this._attribute,
      this._workspaceNr,
      this.callback,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _openDetailedView(context),
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
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

  /// Builds and returns a Widget that contains information about a booking.
  Widget _buildColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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

  /// Opens a detailed booking view when pressing a [BookingItem].
  ///
  /// The detailed view is represented using an [AlertDialog].
  void _openDetailedView(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          contentPadding: const EdgeInsets.all(20),
          title: Text(_roomName + ', ' + _workspaceNr),
          content: DetailedView(_place, _address, _date.toString(),
              _description, _timeslot, _attribute),
          elevation: 24.0,
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(20),
                primary: Colors.black,
                backgroundColor: Colors.grey[100],
                onSurface: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextButton(
                child: const Text("Delete Booking"),
                onPressed: () {
                  //TODO function call to delete booking.
                  callback();
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  primary: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  onSurface: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            IconButton(
              onPressed: _addToCalendar,
              icon: const Icon(Icons.share),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );
  }

  /// Shares this [BookingItem] to the phone calendar.
  ///
  /// Opens the phone's default calendar and fills all fields with information about this specific [BookingItem].
  void _addToCalendar() {
    /// Start time for the booking parsed from _timeslot.
    int startTimeHour = int.parse(_timeslot.substring(8, 10));
    int startTimeMinute = int.parse(_timeslot.substring(11, 13));

    /// End time for the booking parsed from _timeslot.
    int endTimeHour = int.parse(_timeslot.substring(20, 22));
    int endTimeMinute = int.parse(_timeslot.substring(23, 25));

    /// Start day parsed from the booking.
    DateTime start = DateTime(
        _date.year, _date.month, _date.day, startTimeHour, startTimeMinute);

    /// End day parsed from the booking .
    DateTime end = DateTime(
        _date.year, _date.month, _date.day, endTimeHour, endTimeMinute);

    /// Opens the phonhe calendar and adds the booking.
    Add2Calendar.addEvent2Cal(Event(
      title: "Workspace " +
          _workspaceNr +
          " in " +
          _roomName +
          " booked at " +
          _place,
      description: 'Workspace with ' +
          _attribute +
          " booked in " +
          _roomName +
          ", " +
          _description,
      location: _address,
      startDate: start,
      endDate: end,
    ));
  }
}
