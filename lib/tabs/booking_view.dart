import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_handler.dart';
import '../models/space.dart';

class BookingView extends StatefulWidget {
  const BookingView({Key? key}) : super(key: key);

  @override
  State<BookingView> createState() => _BookingViewState();
}

//Widget for selecting office, picking day, picking room and then booking a timeslot
class _BookingViewState extends State<BookingView> {
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
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  fontSize: 20),
            ),
          ),
        ),
        // this is either showing the selected office or showing the office selector
        isLocationSelected ? showSelectedOffice() : showOfficeSelector(),
        const Spacer(
          flex: 2,
        ),
        //CalendarDatePicker is a built in class. It would look more like the mockup if the conditional was removed, but I prefer it this way
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

  //shows the selected office and when clicked it switches the view to showOfficeSelector widget
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

  //Shows a list of all offices from Firebase. When clicked it sets the office in FirebaseHandler and closes this widget
  Widget showOfficeSelector() {
    return FutureBuilder<List<String>>(
      future: FirebaseHandler.getInstance().getOffices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: ListView(
                    //maps the names of offices to clickable Listtiles.
                    children: snapshot.data?.map((office) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: ElevatedButton(
                              // TODO consider changing these buttons to Cards when we include description/images etc.
                              onPressed: () {
                                setState(() {
                                  FirebaseHandler.getInstance()
                                      .selectOffice(office);
                                  isLocationSelected = true;
                                });
                              },
                              child: Text(
                                office,
                              ),
                            ),
                          );
                        }).toList() ??
                        [const Text('No offices found')],
                  )));
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

//This appears when the user has selected an office and a day. It lets the user view and select the rooms.
class RoomSelector extends StatefulWidget {
  final DateTime dateTime;
  final future = FirebaseHandler.getInstance().getRooms();
  RoomSelector(this.dateTime, {Key? key}) : super(key: key);

  @override
  State<RoomSelector> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends State<RoomSelector> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Space>>(
      future:
          widget.future, //this refers to the FirebaseHandler getRooms future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
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
                        children: snapshot.data?.map((workSpace) {
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
                                                      FirebaseHandler.getInstance().addBooking(workSpace.roomNr,widget.dateTime);
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
                                    'Room number ${workSpace.roomNr} - ${workSpace.description} - Seats left ${5} of total ${workSpace.nrOfSeats}', // TODO fetch number of booked seats
                                  ),
                                ),
                              );
                            }).toList() ??
                            [const Text('No Rooms found')],
                      ))
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
