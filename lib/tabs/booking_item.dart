import 'package:flutter/material.dart';
import 'package:flutter_application_1/tabs/detailed_view.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

///This class represents an item that populates bookingList in the
///Bookings class.
class BookingItem extends StatelessWidget {
  final String _roomName;
  final String _place;
  final String _address;
  final String _date;
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

  /// Builds and returns a Widget that contains information about a booking.
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

  /// Opens the detailed booking view when pressing a BookingItem.
  /// The detailed view is represented using an AlertDialog.
  void _openDetailedView(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_roomName + ', ' + _workspaceNr),
          content: DetailedView(
              _place, _address, _date, _description, _timeslot, _attribute),
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
                //TODO function call to delete booking. 
                callback();
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
                  title: "Workspace "+_workspaceNr+" in "+_roomName+" booked at "+_place, // TODO use firebase data
                  description: 'Workspace with '+_attribute+" booked in "+_roomName+", "+_description,
                  location: _address,
                  startDate: DateTime(2022,05,17,08,00), // TODO parse from _date and _timeslot
                  endDate: DateTime(2022,05,17,17,00), // TODO parse from _date and _timeslot
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
