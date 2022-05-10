import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_handler.dart';
import 'package:flutter_application_1/previousoffice_handler.dart';

/// View for bookings
///
/// Contains elements for selecting office, selecting day,
/// picking room and booking that room for a timeslot
class BookingView extends StatefulWidget {
  final Future<String> previousOfficeFuture = PreviousOfficeHandler.getInstance().readPrevChoice();
  BookingView({Key? key}) : super(key: key);

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  /// Determines if the office selector is visible
  bool isLocationSelected = false;
  bool ignorePreviousChoice = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      // The future contains the name of the previous office if PreviousOfficeHandler had one.
      future: widget.previousOfficeFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          String officeString = snapshot.data ?? 'null';
          // If the future contained a valid office name and the user is not trying to change office then the previous
          // office is chosen and the officeSelector is not displayed.
          if(!ignorePreviousChoice && FirebaseHandler.getInstance().getOffices().keys.toList().contains(officeString)) {
            isLocationSelected = true;
            FirebaseHandler.getInstance().selectOffice(officeString);
          }

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
        else {
          return const CircularProgressIndicator();
        }
      }
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
            ignorePreviousChoice = true;
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
                        PreviousOfficeHandler.getInstance().writeChoice(entry.key);
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
              'Select room in ${FirebaseHandler.getInstance().getSelectedOffice()} \nDate ${widget.dateTime.year} - ${widget.dateTime.month} - ${widget.dateTime.day}',
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
                    children: FirebaseHandler.getInstance().getCurrentOfficeRooms().entries.map((entry) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: ElevatedButton(
                      onPressed: () {
                        //loads booking information as soon as the user select room and day.
                        var bookingsFuture = FirebaseHandler.getInstance().getRoomBookingInformation(entry.key, widget.dateTime);

                        if (entry.value.hasSpecialEquipment()) {
                          Navigator.push(
                              // changes scene to where the user can select workspace in the given room.
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkspaceSelector(entry, widget.dateTime, bookingsFuture),
                              ));
                        } else {
                          Navigator.push(
                              // changes scene to where the user can select timeslot in the given room
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimeslotSelector(entry, widget.dateTime, bookingsFuture),
                              ));
                        }
                      },
                      child: Text(
                        'Room number ${entry.key} - ${entry.value.description}',
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

class WorkspaceSelector extends StatefulWidget {
  MapEntry<int, Room> roomEntry;
  DateTime dateTime;
  Future<Map<int, Map<int, String>>> bookingsFuture;
  WorkspaceSelector(this.roomEntry, this.dateTime, this.bookingsFuture, {Key? key}) : super(key: key);

  @override
  State<WorkspaceSelector> createState() => _WorkspaceSelectorState();
}

class _WorkspaceSelectorState extends State<WorkspaceSelector> {
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
              'Select workspace in ${widget.roomEntry.value.name} \nDate ${widget.dateTime.year} - ${widget.dateTime.month} - ${widget.dateTime.day}',
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
                    children: widget.roomEntry.value.workspaces.entries.map((entry) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    leading: Text('Workspace number ${entry.key}'),
                    title: Text(entry.value.reduce((value, element) => value + ", " + element)),
                    onTap: () {
                      Navigator.push(
                          // changes scene to where the user can select room in the given office.
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeslotSelector(widget.roomEntry, widget.dateTime, widget.bookingsFuture, workspaceNr: entry.key),
                          ));
                    },
                  );
                }).toList())),
          ],
        ),
      ),
    );
  }
}

class TimeslotSelector extends StatefulWidget {
  final MapEntry<int, Room> roomEntry;
  final int workspaceNr;
  final DateTime dateTime;
  final Future<Map<int, Map<int, String>>> bookingsFuture;
  const TimeslotSelector(this.roomEntry, this.dateTime, this.bookingsFuture, {Key? key, this.workspaceNr = 0}) : super(key: key);

  @override
  State<TimeslotSelector> createState() => _TimeslotSelectorState();
}

class _TimeslotSelectorState extends State<TimeslotSelector> {
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
            // This is just non-interactive information text
            Text(
              'Select timeslot in ${widget.roomEntry.value.name} \nDate ${widget.dateTime.year} - ${widget.dateTime.month} - ${widget.dateTime.day}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 20,
              ), // TODO remove this style when text styles has been added to the theme
            ),
            const Spacer(
              flex: 1,
            ),
            Expanded(
                flex: 10,
                child: FutureBuilder<Map<int, Map<int, String>>>(
                    future: widget.bookingsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<int, Map<int, String>> data = snapshot.data ?? <int, Map<int, String>>{};
                        return ListView(
                          children: generateTimeslotTiles(data),
                        );
                      }
                      return const CircularProgressIndicator();
                    })),
          ],
        ),
      ),
    );
  }

  // Map<int, Map<int, bool>> bookingInfo, int workspace
  List<Widget> generateTimeslotTiles(Map<int, Map<int, String>> bookingsData) {
    var tilesList = <Widget>[];
    for (var timeslotNr = 0; timeslotNr < widget.roomEntry.value.timeslots.length; timeslotNr++) {

      var timeslot = widget.roomEntry.value.timeslots[timeslotNr];
      var workspaceNr = widget.workspaceNr;

      // Selects an available workspace at each timeslot if none was provided.
      if (workspaceNr == 0) {
        for(var bookingEntry in bookingsData.entries) {
          if (bookingEntry.value[timeslotNr] == 'available') {
            workspaceNr = bookingEntry.key;
          }
        }
      }

      String bookingInfo = bookingsData[workspaceNr]?[timeslotNr] ?? 'null';
      if(bookingInfo == 'booked' || bookingInfo == 'null') {
        bookingInfo = 'Unavailable';
      } else if (bookingInfo == 'user') {
        bookingInfo = 'Already booked';
      } else if (bookingInfo == 'available') {
        bookingInfo = 'Available';
      }

      tilesList.add(ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        leading: Text('Timeslot number $timeslotNr   $bookingInfo'),
        title: Text('${timeslot['start']} - ${timeslot['end']}'),
        onTap: () {
          FirebaseHandler.getInstance().addBooking(widget.roomEntry.key, widget.dateTime, timeslotNr, workspaceNr);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('booking successful'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        },
      ));
    }
    return tilesList;
  }
}
