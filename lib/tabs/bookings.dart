import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/booking_item.dart';

//This class is really just a list that contains BookingItems
class Bookings extends StatefulWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  List<BookingItem> bookingList = <BookingItem>[];
  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < 1000; i++) {
      bookingList.add(const BookingItem());
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: bookingList,
    );
  }
}
