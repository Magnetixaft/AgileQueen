import 'package:flutter/material.dart';
import 'package:flutter_application_1/handlers/firebase_handler.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'dart:io' show Platform;
import 'package:flutter_application_1/themes/theme.dart';

/// Class that builds and displays a list of [BookingItem] and [String].
class MyBookingsTab extends StatefulWidget {
  const MyBookingsTab({Key? key}) : super(key: key);

  @override
  _MyBookingsTabState createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<MyBookingsTab> {
  List<Widget> bookingList = <Widget>[];

  callback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    FirebaseHandler backend = FirebaseHandler.getInstance();
    return FutureBuilder<List<Booking>>(
        future: backend.getUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            bookingList = buildList(snapshot.data, backend);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 58),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Text("My bookings", style: ElliText.boldHeadLine),
                ),
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
          return const Center(child: CircularProgressIndicator());
        });
  }

  /// Builds and returns a list of [Booking].
  List<Widget> buildList(List<Booking>? bookings, FirebaseHandler backend) {
    if (bookings == null) {
      return const [Text('No bookings found', style: ElliText.regularBody)];
    }

    var myBookings = <Widget>[];
    Date previousDay = const Date(0, 0, 0);

    for (Booking booking in bookings) {
      Date currentDay =
          Date(booking.day.year, booking.day.month, booking.day.day);
      DateTime now = DateTime.now();
      Date today = Date(now.year, now.month, now.day);

      if (currentDay.lessThan(today)) {
        continue;
      }

      if (currentDay.equals(previousDay) == false) {
        String date =
            currentDay.equals(today) ? "Today" : currentDay.toString();
        myBookings.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 0, 5),
            child: Text(
              date,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 17,
                fontWeight: currentDay.equals(today)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        );
      }
      Room? room = backend.getAllRooms()[booking.roomNr];
      if (room != null) {
        myBookings.add(_BookingItem(
            room.name, // "[Rumsnamn]",
            room.office, // "[Plats]",
            backend.getAllOffices()[room.office]?.address ??
                'Office not found', // "[Adress]",
            currentDay, //.toString(),
            room.description, // "[Description]",
            room.timeslots[booking.timeslot].toString(), // "[Timeslot]",
            room.workspaces[booking.workspaceNr].toString().replaceAll("[","").
              replaceAll("]", ""), // "[Attribut]",
            booking.workspaceNr.toString(), // "[Platsnamn]/[Workspacenr]",
            callback,
            booking));
      }
      previousDay = currentDay;
    }
    return myBookings;
  }
}

/// Class representing a date with a year, month and day.
///
/// Contains methods [equals] and [lessThan] for comparing two [Date].
class Date {
  final int year;
  final int month;
  final int day;
  const Date(this.year, this.month, this.day);

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  bool equals(Date date2) {
    return year == date2.year && month == date2.month && day == date2.day;
  }

  bool lessThan(Date date2) {
    if (year < date2.year) {
      return true;
    }
    if (year > date2.year) {
      return false;
    }
    if (month < date2.month) {
      return true;
    }
    if (month > date2.month) {
      return false;
    }
    if (day < date2.day) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return months[month - 1] + ' ' + day.toString() + ', ' + year.toString();
  }
}

/// This class represents an item that populates bookingList in [MyBookingsTab]
class _BookingItem extends StatelessWidget {
  final String _roomName;
  final String _place;
  final String _address;
  final Date _date;
  final String _description;
  final String _timeslot;
  final String _attribute;
  final String _workspaceNr;
  final Function callback;
  final Booking _booking;

  const _BookingItem(
      this._roomName,
      this._place,
      this._address,
      this._date,
      this._description,
      this._timeslot,
      this._attribute,
      this._workspaceNr,
      this.callback,
      this._booking,
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
          _roomName,
          style: ElliText.boldWhiteSubHead,
        ),
        Text(_place, style: ElliText.boldWhiteSubHead),
        const SizedBox(height: 5),
        Text(
          _address,
          style: ElliText.regularWhiteSubHead,
        ),
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_roomName,
                style: ElliText.boldBody),
              Text("Workspace " + _workspaceNr,
                style: ElliText.boldBody)
            ],
          ),
          content: _DetailedView(_place, _address, _date.toString(),
              _description, _timeslot, _attribute, _booking),
          elevation: 24.0,
          actions: <Widget>[
            TextButton(
              child: Text("Close", style: ElliText.regularWhiteBody),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                primary: Colors.black,
                backgroundColor: ElliColors.darkBlue,
                onSurface: Colors.grey,
              ),
            ),
            TextButton(
              child: Text("Delete", style: ElliText.regularWhiteBody),
              onPressed: () async {
                await FirebaseHandler.getInstance().removeBooking(_booking);
                callback();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(2, 10, 2, 10),
                primary: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onSurface: Theme.of(context).colorScheme.secondary,
              ),
            ),
            if (Platform.isAndroid) ...[
              IconButton(
                onPressed: _addToCalendar,
                icon: const Icon(Icons.share),
              )
            ],
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

    /// Opens the phone calendar and adds the booking.
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

///This class represents the detailed my bookings view. 
///This view shows up when selecting a [BookingItem]
class _DetailedView extends StatelessWidget {
  final String _place;
  final String _address;
  final String _date;
  final String _description;
  final String _timeslot;
  final String _attribute;
  final Booking _booking;

  const _DetailedView(this._place, this._address, this._date, this._description,
      this._timeslot, this._attribute, this._booking,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      color: Colors.white,
      height: 300,
      width: 150,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Text(
                  _place,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _address,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(_date, style: ElliText.regularBody),
                Text(_timeslot
                    .replaceAll("{start: ", "")
                    .replaceAll(", end:", " -")
                    .replaceAll("}", ""),
                    style: ElliText.regularBody),
                const SizedBox(height: 10),
                Text(_description == "null" ? "" : _description,
                  style: ElliText.regularBody),
                const SizedBox(height: 10),
                Text(_attribute == "" ? "" : "Equipment: " + _attribute,
                  style: ElliText.regularBody),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
