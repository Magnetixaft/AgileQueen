// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/firebase_handler.dart';

// import '../models/booking.dart';

// class CurrentBookingView extends StatefulWidget {
//   const CurrentBookingView({Key? key}) : super(key: key);

//   @override
//   State<CurrentBookingView> createState() => _CurrentBookingViewState();
// }

// //Widget to view and un-book timeslots.
// class _CurrentBookingViewState extends State<CurrentBookingView> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Booking>>(
//       future: FirebaseHandler.getInstance().getUserBookings(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 50,
//                 child: Center(
//                   child: Text('Current bookings for ${FirebaseHandler.getInstance().getName()}'),
//                 ),
//               ),
//               Expanded(
//                   child: ListView(
//                     children: getBookedTiles(snapshot.data))
//               )
//             ],
//           );
//         }
//         return const Center(child: CircularProgressIndicator());
//       }
//     );
//   }

//   List<Widget> getBookedTiles(List<Booking>? bookings) {
//     if (bookings == null) {
//       return [const Text('No bookings found')];
//     }
//     var bookedTiles = <Widget>[];
//     for (Booking booking in bookings) {
//       bookedTiles.add(const Divider(height: 20,));
//       bookedTiles.add(ListTile(
//         title: Text('${booking.day.month} - ${booking.day.day}'),
//         trailing: ElevatedButton(
//             child: const Text('Remove'),
//             onPressed: () {
//               setState(() {
//                 FirebaseHandler.getInstance().removeBooking(booking.roomNr, booking.day);
//               });
//             }),
//       ));
//     }

//     return bookedTiles;
//   }
// }
