import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_handler.dart';
import 'package:flutter_application_1/tabs/booking_item.dart';
import '../models/booking.dart';

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

  List<Widget> buildList(List<Booking>? bookings, FirebaseHandler backend) {
    if (bookings == null) {
      return [const Text('No bookings found')];
    }
    var myBookings = <Widget>[];
    _Date previousDay = const _Date(0, 0, 0);

    for (Booking booking in bookings) {
      _Date currentDay =
          _Date(booking.day.year, booking.day.month, booking.day.day);
      DateTime now = DateTime.now();
      _Date today = _Date(now.year, now.month, now.day);

      //TODO Gettolösning, borde kanske radera gamla bokningar i backenden.
      if (currentDay.lessThan(today)) {
        continue;
      }

      if (currentDay.equals(previousDay)) {
        myBookings.add(BookingItem(booking.roomNr.toString(), "[Plats]",
            backend.getSelectedOffice(), currentDay.toString()));
      } else {
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
        myBookings.add(BookingItem(booking.roomNr.toString(), "[Plats]",
            backend.getSelectedOffice(), currentDay.toString()));
      }
      previousDay = currentDay;
    }
    return myBookings;
  }
}

//Class representing a date with a year, month and day.
//Currently used for comparing dates in _BookingsState.
class _Date {
  final int year;
  final int month;
  final int day;
  const _Date(this.year, this.month, this.day);

  bool equals(_Date date2) {
    return year == date2.year && month == date2.month && day == date2.day;
  }

  bool lessThan(_Date date2) {
    return year <= date2.year && month <= date2.month && day < date2.day;
  }

  @override
  String toString() {
    return _getMonth(month) + ' ' + day.toString() + ', ' + year.toString();
  }

  String _getMonth(var month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
