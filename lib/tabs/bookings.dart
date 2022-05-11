import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_handler.dart';
import 'package:flutter_application_1/tabs/booking_item.dart';

/// Class that builds and displays a list of [BookingItem] and [String].
class Bookings extends StatefulWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
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
          return const Center(child: CircularProgressIndicator());
        });
  }

  /// Builds and returns a list of [Booking].
  List<Widget> buildList(List<Booking>? bookings, FirebaseHandler backend) {
    if (bookings == null) {
      return [const Text('No bookings found')];
    }

    var myBookings = <Widget>[];
    Date previousDay = const Date(0, 0, 0);

    for (Booking booking in bookings) {
      Date currentDay =
          Date(booking.day.year, booking.day.month, booking.day.day);
      DateTime now = DateTime.now();
      Date today = Date(now.year, now.month, now.day);

      //TODO Gettolösning, borde kanske radera gamla bokningar i backenden.
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
                fontSize: 20,
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
        myBookings.add(BookingItem(
            room.name, // "[Rumsnamn]",
            room.office,// "[Plats]",
            backend.getAllOffices()[room.office]?.address ?? 'Office not found',// "[Adress]",
            currentDay,//.toString(),
            room.description,// "[Description]",
            room.timeslots[booking.timeslot].toString(),// "[Timeslot]",
            room.workspaces[booking.roomNr].toString(),// "[Attribut]",
            booking.workspaceNr.toString(),// "[Platsnamn]/[Workspacenr]",
            callback));
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
