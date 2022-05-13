import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_handler.dart';
import 'package:flutter_application_1/previousoffice_handler.dart';
import 'package:flutter_application_1/theme.dart';
import 'dart:math' as math;

/// Contains functionality that lets a user book a room.
class BookingView2 extends StatefulWidget {
  final Future<String> previousOfficeFuture =
      PreviousOfficeHandler.getInstance().readPrevChoice();
  BookingView2({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BookingView2State();
}

class _BookingView2State extends State<BookingView2> {
  FirebaseHandler backend = FirebaseHandler.getInstance();
  bool isLocationSelected = false;
  bool ignorePreviousChoice = false;
  bool isDivisionSelected = false;

  //Widget currentView = const CircularProgressIndicator();

  _BookingView2State() {
    // backend.selectOffice("Göteborgskontoret");
    //currentView = buildMainView();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: widget.previousOfficeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            String officeString = snapshot.data ?? 'null';
            if (!isDivisionSelected) {
              return buildDivisionSelector();
            }
            if (!ignorePreviousChoice &&
                backend.getOffices().keys.toList().contains(officeString)) {
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
      Align(
          alignment: Alignment.topLeft,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 0, 10),
              child: GestureDetector(
                  onTap: () {
                    isDivisionSelected = false;
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
              padding: EdgeInsets.fromLTRB(25, 10, 0, 0),
              child: Text("Change office",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins")))),
      _OfficeCard(
          backend.getSelectedOffice(),
          backend.getOffices()[backend.getSelectedOffice()]?.address ??
              'Address not found',
          math.pi / 2,
          Colors.white,
          ElliColors.darkBlue,
          Colors.white,
          25,
          callbackToOffice),
      const Spacer(
        flex: 2,
      ),
      Container(
        margin: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ]),
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
            setState(() {});
          },
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
                                ? const Color.fromARGB(
                                    255,
                                    254,
                                    131,
                                    139,
                                  )
                                : Colors.black //TODO Add this color to theme?
                            )),
                    const Icon(Icons.arrow_forward_ios, size: 14)
                  ]),
            ),
            const Divider(),
          ]));
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
                    color: Color.fromARGB(
                        255, 254, 131, 139), //TODO Add this color to theme?
                  )))),
      const Divider(),
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
        backend.getOffices()[currentOffice]?.address ?? "Address not found",
        3 * math.pi / 2,
        Colors.white,
        ElliColors.darkBlue,
        Colors.white,
        5,
        callbackFromOffice);
    officeList.add(firstItem);

    for (var officeEntry in backend.getOffices().entries) {
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
                            Text(_office,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                  color: _textColor,
                                )),
                            Text(_address,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins",
                                  color: _textColor,
                                )),
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

class RoomSelector extends StatefulWidget {

  final DateTime dateTime;
  const RoomSelector(this.dateTime, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoomSelectorState();
}

class _RoomSelectorState extends State<RoomSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 0, 10),
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text("Back",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Poppins"
                  )
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }
              )
            )
          )
        ]
      )
    );
  }
}
