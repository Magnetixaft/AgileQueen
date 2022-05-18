import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/handlers/firebase_handler.dart';
import 'package:flutter_application_1/handlers/previous_choice_handler.dart';
import 'package:flutter_application_1/themes/theme.dart';
import 'package:flutter_application_1/tabs/my_bookings_tab.dart';
import 'dart:math' as math;

/// Contains functionality that lets a user book a room.
class BookTab extends StatefulWidget {
  final Future<PreviousChoices> previousChoiceFuture =
      PreviousChoiceHandler.instance.readPrevChoice();
  BookTab({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BookTabState();
}

class _BookTabState extends State<BookTab> {
  FirebaseHandler backend = FirebaseHandler.getInstance();
  bool isLocationSelected = false;
  bool ignorePreviousChoice = false;
  bool isDivisionSelected = false;

  //Widget currentView = const CircularProgressIndicator();

  _BookTabState() {
    // backend.selectOffice("Göteborgskontoret");
    //currentView = buildMainView();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PreviousChoices>(
        future: widget.previousChoiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            String divisionString = snapshot.data?.division ?? 'nullDivision';
            String officeString = snapshot.data?.office ?? 'nullOffice';
            if (!ignorePreviousChoice &&
                backend.getDivisions().keys.toList().contains(divisionString)) {
              isDivisionSelected = true;
              backend.selectDivision(divisionString);
            }
            if (!isDivisionSelected) {
              return buildDivisionSelector();
            }
            if (!ignorePreviousChoice &&
                backend
                    .getDivisionOffices()
                    .keys
                    .toList()
                    .contains(officeString)) {
              isLocationSelected = true;
              backend.selectOffice(officeString);
              return buildMainView();
            } else if (isLocationSelected) {
              return buildMainView();
            } else {
              return buildOfficeSelector();
            }
            //return currentView;
          }
          return const CircularProgressIndicator();
        });
  }

  /// Sets [isLocationSelected] to true and calls [setState()]
  callbackFromOffice() {
    isLocationSelected = true;
    setState(() {});
  }

  /// Sets [isLocationSelected] to false, [ignorePreviousChoice] to true
  /// and calls [setState()]
  callbackToOffice() {
    isLocationSelected = false;
    ignorePreviousChoice = true;
    setState(() {});
  }

  /// Returns a [Column] that contains the main booking view.
  Widget buildMainView() {
    return Column(children: [
      Expanded(
          child: ListView(children: [
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 0, 0),
                child: SizedBox(
                    width: 50,
                    height: 30,
                    child: Image.asset('assets/images/Resurs 5@4x.png')))),
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 0, 10),
                child: GestureDetector(
                    onTap: () {
                      isDivisionSelected = false;
                      ignorePreviousChoice = true;
                      setState(() {});
                    },
                    child: Row(children: [
                      Text(backend.getSelectedDivision(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontFamily: "Poppins")),
                      const SizedBox(width: 10),
                      Transform.rotate(
                          angle: math.pi / 2,
                          child: const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.grey)),
                    ])))),
        const Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.fromLTRB(25, 5, 0, 0),
                child: Text("Change office",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins")))),
        _OfficeCard(
            backend.getSelectedOffice(),
            backend.getAllOffices()[backend.getSelectedOffice()]?.address ??
                'Address not found',
            math.pi / 2,
            Colors.white,
            ElliColors.darkBlue,
            Colors.white,
            25,
            callbackToOffice),
        const Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.fromLTRB(25, 10, 0, 0),
                child: Text("Choose a date",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    )))),
        Container(
          margin: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            boxShadow: [
              // BoxShadow(
              //   color: Colors.grey.withOpacity(0.5),
              //   spreadRadius: 5,
              //   blurRadius: 7,
              //   offset: const Offset(0, 3),
              // ),
            ],
            border: Border.all(color: ElliColors.darkBlue),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Card(
            child: CalendarDatePicker(
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
                }),
          ),
        )
      ]))
    ]);
  }

  /// Returns a [Column] that contains functionality to change divisions.
  Widget buildDivisionSelector() {
    List<Widget> divisionList = [];

    for (var divisionEntry in backend.getDivisions().entries) {
      GestureDetector listItem = GestureDetector(
          onTap: () {
            backend.selectDivision(divisionEntry.key);
            isDivisionSelected = true;
            isLocationSelected = false;
            backend.selectOffice('init');
            PreviousChoiceHandler.instance
                .setPreviousDivision(divisionEntry.key);
            setState(() {});
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(divisionEntry.key,
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              color: divisionEntry.key ==
                                      backend.getSelectedDivision()
                                  ? ElliColors.pink
                                  : Colors.black)),
                      const Icon(Icons.arrow_forward_ios, size: 14)
                    ]),
              ),
              const Divider(),
            ]),
          ));
      divisionList.add(listItem);
    }

    return Column(children: [
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 0, 10),
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text("Back",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Poppins",
                    )),
                onPressed: () {
                  isDivisionSelected = true;
                  setState(() {});
                },
              ))),
      const Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: EdgeInsets.fromLTRB(25, 5, 0, 10),
              child: Text("Choose company",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ElliColors.pink,
                  )))),
      const Divider(height: 0),
      Expanded(
          child: ListView(
        //padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        children: divisionList,
      ))
    ]);
  }

  /// Returns a [Column] that contains functionality to change offices.
  Widget buildOfficeSelector() {
    List<_OfficeCard> officeList = [];
    String currentOffice = backend.getSelectedOffice();
    _OfficeCard firstItem = _OfficeCard(
        currentOffice,
        backend.getAllOffices()[currentOffice]?.address ?? "Address not found",
        3 * math.pi / 2,
        Colors.white,
        ElliColors.darkBlue,
        Colors.white,
        5,
        callbackFromOffice);
    officeList.add(firstItem);

    for (var officeEntry in backend.getDivisionOffices().entries) {
      if (officeEntry.key != backend.getSelectedOffice()) {
        _OfficeCard listItem = _OfficeCard(
            officeEntry.key,
            officeEntry.value.address,
            math.pi,
            ElliColors.grey,
            ElliColors.whiteGrey,
            ElliColors.whiteGrey,
            5,
            callbackFromOffice);
        officeList.add(listItem);
      }
    }

    return Column(children: [
      const SizedBox(height: 65),
      const Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: EdgeInsets.fromLTRB(25, 10, 0, 10),
              child: Text("Select office",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins")))),
      Expanded(
          child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        children: officeList,
      ))
    ]);
  }
}

/// Represents a clickable card that contains information about an office.
class _OfficeCard extends StatelessWidget {
  final String _office;
  final String _address;
  final double _angle;
  final Color _textColor;
  final Color _backgroundColor;
  final Color _iconColor;
  final double _padding;
  final Function callback;
  final FirebaseHandler backend = FirebaseHandler.getInstance();

  _OfficeCard(this._office, this._address, this._angle, this._textColor,
      this._backgroundColor, this._iconColor, this._padding, this.callback,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          backend.selectOffice(_office);
          PreviousChoiceHandler.instance.setPreviousOffice(_office);
          callback();
        },
        child: Container(
            margin: EdgeInsets.all(_padding),
            height: 60.0,
            decoration: BoxDecoration(
                color: _backgroundColor, //Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(6))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                _office == 'init'
                                    ? "Select an office"
                                    : _office,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                  color: _textColor,
                                )),
                            if (_address != "Address not found") ...[
                              Text(_address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Poppins",
                                    color: _textColor,
                                  ))
                            ],
                          ])),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Transform.rotate(
                          angle: _angle,
                          child: Icon(Icons.arrow_forward_ios,
                              size: 14, color: _iconColor))),
                ])));
  }
}

/// Contains functionality to select a a room, bringing the user to a
/// [Workspaceselector] or [TimeslotSelector].
class RoomSelector extends StatefulWidget {
  final DateTime dateTime;
  const RoomSelector(this.dateTime, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends State<RoomSelector> {
  FirebaseHandler backend = FirebaseHandler.getInstance();

  @override
  Widget build(BuildContext context) {
    Date selectedDate =
        Date(widget.dateTime.year, widget.dateTime.month, widget.dateTime.day);
    return Scaffold(
        body: Column(children: [
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 5),
              child: TextButton.icon(
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  label: const Text("Back",
                      style: TextStyle(fontSize: 16, fontFamily: "Poppins")),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }))),
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 5, 0, 10),
              child: Text(selectedDate.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  )))),
      const Divider(),
      _OfficeCard(
          backend.getSelectedOffice(),
          backend.getAllOffices()[backend.getSelectedOffice()]?.address ??
              'Address not found',
          0,
          ElliColors.grey,
          ElliColors.lightGrey,
          ElliColors.lightGrey,
          25,
          dummyFunc),
      const Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: EdgeInsets.fromLTRB(25, 0, 0, 10),
              child: Text("Choose a room",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  )))),
      Expanded(
          //flex: 10,
          child: ListView(
              children: backend.getCurrentOfficeRooms().entries.map((entry) {
        return GestureDetector(
            onTap: () {
              var bookingsFuture =
                  backend.getRoomBookingInformation(entry.key, widget.dateTime);

              if (entry.value.hasSpecialEquipment()) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkspaceSelector(
                          entry, widget.dateTime, bookingsFuture),
                    ));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TimeslotSelector(
                            entry, widget.dateTime, bookingsFuture)));
              }
            },
            child: Container(
                margin: const EdgeInsets.fromLTRB(25, 5, 25, 5),
                height: 60,
                decoration: const BoxDecoration(
                  color: ElliColors.lightGrey,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(entry.value.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Poppins",
                                    )),
                                Text(
                                    "Capacity: " +
                                        entry.value.workspaces.length
                                            .toString() +
                                        " workspaces.",
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      color: ElliColors.grey,
                                    ))
                              ])),
                      const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Icon(Icons.arrow_forward_ios,
                              color: ElliColors.grey))
                    ])));
      }).toList()))
    ]));
  }

  void dummyFunc() {}
}

/// Contains functionality to select a workspace, bringing the user to
/// a [TimeslotSelector].
class WorkspaceSelector extends StatefulWidget {
  final MapEntry<int, Room> roomEntry;
  final DateTime dateTime;
  final Future<Map<int, Map<int, String>>> bookingsFuture;

  const WorkspaceSelector(this.roomEntry, this.dateTime, this.bookingsFuture,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _WorkspaceSelectorState();
}

class _WorkspaceSelectorState extends State<WorkspaceSelector> {
  FirebaseHandler backend = FirebaseHandler.getInstance();

  @override
  Widget build(BuildContext context) {
    Date selectedDate =
        Date(widget.dateTime.year, widget.dateTime.month, widget.dateTime.day);
    return FutureBuilder<Map<int, Map<int, String>>>(
        future: backend.getRoomBookingInformation(
            widget.roomEntry.key, widget.dateTime),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                body: Column(children: [
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 0, 5),
                      child: TextButton.icon(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        label: const Text("Back",
                            style:
                                TextStyle(fontSize: 16, fontFamily: "Poppins")),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ))),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 5, 0, 10),
                      child: Text(widget.roomEntry.value.name,
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )))),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
                      child: Text(
                          backend.getSelectedOffice() +
                              "\n" +
                              backend
                                  .getAllOffices()[backend.getSelectedOffice()]!
                                  .address,
                          style: const TextStyle(
                              fontSize: 14, fontFamily: "Poppins")))),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
                      child: Text(selectedDate.toString(),
                          style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              color: ElliColors.grey)))),
              Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
                      child: Text(widget.roomEntry.value.description,
                          style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 14,
                              color: ElliColors.grey)))),
              const Divider(),
              Expanded(
                  child:
                      ListView(children: buildWorkSpaceList(snapshot.data!))),
            ]));
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  /// Returns [workSpaceList], which is a list of Widgets containing
  /// information about specific workspaces.
  List<Widget> buildWorkSpaceList(Map<int, Map<int, String>> workspaces) {
    List<Widget> workSpaceList = [];
    workSpaceList.add(const Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: EdgeInsets.fromLTRB(25, 10, 0, 10),
            child: Text("Workspaces",
                style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.bold)))));

    var localVar = workspaces.entries.toList();
    localVar.sort((a, b) => a.key - b.key);
    for (var workspace in localVar) {
      String specialEquipment = widget.roomEntry.value.workspaces[workspace.key]
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "");
      GestureDetector card = GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TimeslotSelector(widget.roomEntry,
                        widget.dateTime, widget.bookingsFuture,
                        workspaceNr: workspace.key)));
          },
          child: Container(
              margin: const EdgeInsets.fromLTRB(25, 5, 25, 5),
              
              height: 80.0,
              decoration: const BoxDecoration(
                  color:
                      ElliColors.lightGrey), //Theme.of(context).primaryColor,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(workspace.key.toString(),
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  )),
                              if (specialEquipment.length > 1) ...[
                                Text(specialEquipment)
                              ],
                              const SizedBox(height: 10),
                              Row(
                                  children: buildAvailabilityRow(
                                      workspaces[workspace.key]!))
                            ]),
                      ),
                    ),
                    const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Icon(Icons.arrow_forward_ios,
                            color: ElliColors.grey))
                  ])));
      workSpaceList.add(card);
    }
    return workSpaceList;
  }

  /// Returns a list of Widgets representing timeslots, that are colored
  /// based on their availability.
  List<Widget> buildAvailabilityRow(Map<int, String> timeslots) {
    List<Widget> availability = [];

    for (String timeslot in timeslots.values) {
      Flexible item = Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: Container(
              margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              height: 7,
              decoration: BoxDecoration(
                  color: timeslot == 'booked'
                      ? ElliColors.darkPink
                      : timeslot == 'user'
                          ? Colors.yellow
                          : Colors.green,
                  borderRadius: const BorderRadius.all(Radius.circular(2)))));
      availability.add(item);
    }
    return availability;
  }
}

/// Contains functionality to select and book a timeslot.
class TimeslotSelector extends StatefulWidget {
  final MapEntry<int, Room> roomEntry;
  final int workspaceNr;
  final DateTime dateTime;
  final Future<Map<int, Map<int, String>>> bookingsFuture;

  const TimeslotSelector(this.roomEntry, this.dateTime, this.bookingsFuture,
      {Key? key, this.workspaceNr = 0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimeslotSelectorState();
}

class _TimeslotSelectorState extends State<TimeslotSelector> {
  FirebaseHandler backend = FirebaseHandler.getInstance();

  @override
  Widget build(BuildContext context) {
    Date selectedDate =
        Date(widget.dateTime.year, widget.dateTime.month, widget.dateTime.day);
    return Scaffold(
        body: Column(children: [
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 0, 5),
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text("Back",
                    style: TextStyle(fontFamily: "Poppins", fontSize: 16)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ))),
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 5, 0, 10),
              child: Text(widget.roomEntry.value.name,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )))),
      if (widget.workspaceNr != 0) ...[
        Align(
            alignment: Alignment.topLeft,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 5, 0, 10),
                child: Text(widget.workspaceNr.toString(),
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))))
      ],
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
              child: Text(
                  backend.getSelectedOffice() +
                      "\n" +
                      backend
                          .getAllOffices()[backend.getSelectedOffice()]!
                          .address,
                  style:
                      const TextStyle(fontFamily: "Poppins", fontSize: 14)))),
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
              child: Text(selectedDate.toString(),
                  style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      color: ElliColors.grey)))),
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 0, 10),
              child: Text(widget.roomEntry.value.description,
                  style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      color: ElliColors.grey)))),
      const Divider(),
      Expanded(
          child: FutureBuilder<Map<int, Map<int, String>>>(
              future: widget.bookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView(
                      children:
                          buildTimeslotList(snapshot.data!, selectedDate));
                }
                return const Center(child: CircularProgressIndicator());
              })),
    ]));
  }

  List<Widget> buildTimeslotList(
      Map<int, Map<int, String>> bookingData, Date date) {
    List<Widget> result = [];
    bool wholeDayFree = true; //TODO update this somewhere!!

    result.add(const Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: EdgeInsets.fromLTRB(25, 0, 0, 10),
            child: Text("All day",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )))));

    result.add(const Align(
        alignment: Alignment.topLeft,
        child: Padding(
            padding: EdgeInsets.fromLTRB(25, 15, 0, 10),
            child: Text("Time Slots",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )))));

    bool atLeastOneSlotBooked = false;
    for (var timeslotNr = 0;
        timeslotNr < widget.roomEntry.value.timeslots.length;
        timeslotNr++) {
      var timeslot = widget.roomEntry.value.timeslots[timeslotNr];
      var workspaceNr = widget.workspaceNr;
      bool userHasAlreadyBooked = false;

      if (workspaceNr == 0) {
        for (var bookingEntry in bookingData.entries) {
          if (bookingEntry.value[timeslotNr] == 'user') {
            userHasAlreadyBooked = true;
          }
          if (bookingEntry.value[timeslotNr] == 'available') {
            workspaceNr = bookingEntry.key;
          }
        }
      }

      String bookingInfo = bookingData[workspaceNr]?[timeslotNr] ?? 'null';

      if (bookingInfo != 'available') {
        wholeDayFree = false;
      }

      result.add(Container(
          decoration: const BoxDecoration(
            color: ElliColors.lightGrey,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          margin: const EdgeInsets.fromLTRB(25, 5, 25, 5),
          height: 70,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("From",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                            )),
                        Text(timeslot.values.first,
                            style: const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 18,
                                fontWeight: FontWeight.bold))
                      ])),
              Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(" ",
                            style:
                                TextStyle(fontSize: 16, fontFamily: "Poppins")),
                        Text("-",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 18,
                                fontWeight: FontWeight.bold))
                      ])),
              Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("To",
                            style:
                                TextStyle(fontSize: 16, fontFamily: "Poppins")),
                        Text(timeslot.values.last,
                            style: const TextStyle(
                                fontSize: 18,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold))
                      ]))
            ]),
            GestureDetector(
                onTap: () {
                  userHasAlreadyBooked == true
                      ? dummyFunc()
                      : bookingInfo == 'available'
                          ? bookOneTimeslot(timeslotNr, workspaceNr, date)
                          : dummyFunc();
                },
                child: Container(
                    width: 70,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: userHasAlreadyBooked == true
                          ? ElliColors.grey
                          : bookingInfo == 'available'
                              ? ElliColors.darkBlue
                              : ElliColors.grey,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    child: const Center(
                        child: Text("Book",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            )))))
          ])));
      if (userHasAlreadyBooked == true) {
        atLeastOneSlotBooked = true;
      }
    }

    result.insert(
        1,
        Container(
            decoration: const BoxDecoration(
              color: ElliColors.lightGrey,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            margin: const EdgeInsets.fromLTRB(25, 5, 25, 5),
            height: 70,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(date.toString(),
                                style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                )),
                            const Text("All day",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ))
                          ])),
                  GestureDetector(
                      onTap: () {
                        atLeastOneSlotBooked == true
                            ? dummyFunc()
                            : wholeDayFree == true
                                ? bookWholeDay(date, bookingData)
                                : dummyFunc();
                      },
                      child: Container(
                          width: 70,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: atLeastOneSlotBooked
                                ? ElliColors.grey
                                : wholeDayFree == true
                                    ? ElliColors.darkBlue
                                    : ElliColors.grey,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                          ),
                          child: const Center(
                              child: Text("Book",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  )))))
                ])));

    return result;
  }

  /// Does not do anything
  dummyFunc() {}

  /// Books a single timeslot.
  bookOneTimeslot(int timeslotNr, int workspaceNr, Date date) {
    backend.saveBooking(
        widget.roomEntry.key, widget.dateTime, timeslotNr, workspaceNr);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConfirmationScreen(widget.roomEntry, widget.workspaceNr, date),
        ));
  }

  /// Books a full day worth of timeslots.
  bookWholeDay(Date date, Map<int, Map<int, String>> bookingData) async {
    for (var timeslotNr = 0;
        timeslotNr < widget.roomEntry.value.timeslots.length;
        timeslotNr++) {
      var workspaceNr = widget.workspaceNr;

      if (workspaceNr == 0) {
        for (var bookingEntry in bookingData.entries) {
          if (bookingEntry.value[timeslotNr] == 'available') {
            workspaceNr = bookingEntry.key;
          }
        }
      }

      await backend.saveBooking(
          widget.roomEntry.key, widget.dateTime, timeslotNr, workspaceNr);
    }

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConfirmationScreen(widget.roomEntry, widget.workspaceNr, date),
        ));
  }
}

/// Shows the user a confirmation for their booking.
class ConfirmationScreen extends StatefulWidget {
  final MapEntry<int, Room> roomEntry;
  final int workspaceNr;
  final Date date;

  const ConfirmationScreen(this.roomEntry, this.workspaceNr, this.date,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  FirebaseHandler backend = FirebaseHandler.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          const SizedBox(height: 40),
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 0, 10),
                  child: Text(widget.roomEntry.value.name,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )))),
          if (widget.workspaceNr != 0) ...[
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 5, 0, 10),
                    child: Text(widget.workspaceNr.toString(),
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ))))
          ],
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 5, 0, 10),
                  child: Text(widget.roomEntry.value.description,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                        color: ElliColors.grey,
                      )))),
          const Align(
              alignment: Alignment.center,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                  child: Icon(Icons.check_circle,
                      size: 160, color: ElliColors.darkPink))),
          const Align(
              alignment: Alignment.center,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 50),
                  child: Text("Booking confirmed!",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ElliColors.grey)))),
          Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 0, 10),
                  child: Text(
                      widget.date.toString() +
                          "\n" +
                          backend.getSelectedOffice() +
                          "\n" +
                          backend
                              .getAllOffices()[backend.getSelectedOffice()]!
                              .address,
                      style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          color: ElliColors.grey)))),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      child: Container(
                          height: 60,
                          decoration: const BoxDecoration(
                            color: ElliColors.darkBlue,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          child: const Center(
                              child: Text("Go to Home Page",
                                  style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white)))))))
        ]));
  }
}
