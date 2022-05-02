import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_handler.dart';

/// View for bookings
///
/// Contains elements for selecting office, selecting day,
/// picking room and booking that room for a timeslot
class BookingView extends StatefulWidget {
  const BookingView({Key? key}) : super(key: key);

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  /// Determines if the office selector is visible
  bool isLocationSelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          //This is just the title text
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(25, 10, 0, 10),
            child: Text(
              'Select Office',
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto', fontSize: 20),
            ),
          ),
        ),
        // this is either showing the selected office or showing the office selector
        isLocationSelected ? showSelectedOffice() : showOfficeSelector(),
        const Spacer(
          flex: 2,
        ),
        //CalendarDatePicker is a built in class
        if (isLocationSelected)
          // TODO Change the locale of our app in order to get the CalendarDatePicker to start weeks on Monday https://stackoverflow.com/questions/57975312/flutter-showdatepicker-set-first-day-of-week-to-monday
          CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 1000)),
              onDateChanged: (selected) {
                setState(() {
                  Navigator.push(
                      // changes scene to where the user can select room in the given office.
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomSelector(selected),
                      ));
                });
              })
      ],
    );
  }

  /// View that shows the currently selected office.
  ///
  /// Click to show [showOfficeSelector] widget instead.
  Widget showSelectedOffice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isLocationSelected = false;
          });
        },
        child: Text(
          '${FirebaseHandler.getInstance().getSelectedOffice()} - tap to change',
        ),
      ),
    );
  }

  /// View for selecting offices
  ///
  /// Loads a list of offices from Firebase via [FirebaseHandler].
  /// When office is selected the [showSelectedOffice] widget is shown instead
  Widget showOfficeSelector() {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: ListView(
              children: FirebaseHandler.getInstance().getOffices().entries.map((entry) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: ElevatedButton(
                    // TODO consider changing these buttons to Cards when we include description/images etc.
                    onPressed: () {
                      setState(() {
                        FirebaseHandler.getInstance().selectOffice(entry.key);
                        isLocationSelected = true;
                      });
                    },
                    child: Text(
                      entry.key,
                    ),
                  ),
                );
              }).toList(),
            )));
  }
}

/// View for selecting a room and booking a timeslot
///
/// Displays rooms as tiles in a certain office via [FirebaseHandler].
/// When a tile is clicked, it shows an [AlertDialog] with bookable timeslots.
class RoomSelector extends StatefulWidget {
  /// The day that the user selected in [BookingView]
  final DateTime dateTime;
  const RoomSelector(this.dateTime, {Key? key}) : super(key: key);

  @override
  State<RoomSelector> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends State<RoomSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Back'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(
              flex: 1,
            ),
            //This is just non-interactive information text
            Text(
              'Select work area in ${FirebaseHandler.getInstance().getSelectedOffice()} \nDate ${widget.dateTime.year} - ${widget.dateTime.month} - ${widget.dateTime.day}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 20,
              ), // TODO remove this style when text styles has been added to the theme
            ),
            const Spacer(
              flex: 1,
            ),
            //This is a list of all the rooms in that office. The user can tap top view, and then book, timeslots.
            Expanded(
                flex: 10,
                child: ListView(
                    children: FirebaseHandler.getInstance().getRooms().entries.map((entry) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              //This shows a pop-up where the user can view and book timeslots.
                              return AlertDialog(
                                  content: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          FirebaseHandler.getInstance().addBooking(entry.key, widget.dateTime, 0, 14); // TODO add workspace and timeslot
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('booking successful'),
                                              backgroundColor: Theme.of(context).primaryColor,
                                            ),
                                          );
                                        });
                                      },
                                      child: const Text('Book')));
                            },
                            barrierColor: Colors.transparent);
                      },
                      child: Text(
                        'Room number ${entry.key} - ${entry.value.description} - Seats left ${5} of total ${entry.value.workspaces.length}', // TODO fetch number of booked seats
                      ),
                    ),
                  );
                }).toList()))
          ],
        ),
      ),
    );
  }
}
