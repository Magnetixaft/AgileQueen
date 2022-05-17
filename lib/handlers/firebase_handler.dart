import 'package:cloud_firestore/cloud_firestore.dart';

/// Singleton class to communicate with Firebase.
///
/// Must be initialized with a username to work. Stores a username and selected office during bookings.
class FirebaseHandler {
  /// The current user of the app. Must be initialized.
  var _username = 'init';

  /// The currently selected division.
  var _division = 'init';

  /// The currently selected office.
  var _office = 'init';

  var _rooms = <int, Room>{};
  var _divisions = <String, Division>{};

  static final FirebaseHandler _instance = FirebaseHandler._(); // Singleton

  FirebaseHandler._(); // Hidden constructor

  /// Initializes the singleton with a username
  static void initialize(String username) {
    _instance._username = username;
  }

  /// Downloads data about rooms and offices from Firebase and builds a model.
  ///
  /// Data is stored in [_rooms] and [_divisions].
  /// This is information which is not supposed to be updated often.
  Future<void> buildStaticModel() async {
    _divisions = <String, Division>{};
    _rooms = <int, Room>{};
    //Downloads divisions and their offices
    await _buildDivision();
    //Downloads rooms
    await _buildRooms();
    //set the division to the first one provided by default
    _division = _divisions.entries.first.key;
    return;
  }

  Future<void> _buildDivision() async {
    var divisionsData = await FirebaseFirestore.instance.collection('Divisions').get();
    for (var divisionData in divisionsData.docs) {
      var officesData = await FirebaseFirestore.instance.collection('Divisions').doc(divisionData.id).collection('Offices').get();

      var offices = <String, Office>{};
      for (var office in officesData.docs) {
        offices[office.id] = Office(office.data()['Address'], office.data()['Description']);
      }

      _divisions[divisionData.id] = Division(offices);
    }
    return;
  }

  Future<void> _buildRooms() async {
    var roomsData = await FirebaseFirestore.instance.collection('Rooms_2').get();
    for (var room in roomsData.docs) {
      var workspaces = <int, List<String>>{};
      for (var workspace in room.data()['Workspaces'].entries) {
        workspaces[int.parse(workspace.key)] = workspace.value.cast<String>();
      }

      var timeslots = <Map<String, String>>[];
      for (var timeslot in room.data()['Timeslots']) {
        var times = timeslot.split('-');
        timeslots.add({'start': times[0], 'end': times[1]});
      }

      _rooms[int.parse(room.id)] = Room(workspaces, timeslots, room.data()['Description'], room.data()['Office'], room.data()['Name']);
    }
    return;
  }

  /// Returns the singleton instance.
  ///
  /// Throws exception if the singleton is not initialized
  static FirebaseHandler getInstance() {
    // Singleton
    if (_instance._username == 'init') {
      throw Exception('Singleton not initialized with username');
    }
    return _instance;
  }

  /// Returns all divisions
  Map<String, Division> getDivisions() {
    return _divisions;
  }

  /// Returns all the offices in the selected division
  Map<String, Office> getDivisionOffices() {
    return _divisions[_division]?.offices ?? {};
  }

  /// Returns all the offices in the model
  Map<String, Office> getAllOffices() {
    var allOffices = <String, Office>{};
    for (var division in _divisions.values) {
      for (var office in division.offices.entries) {
        allOffices[office.key] = office.value;
      }
    }
    return allOffices;
  }

  /// Returns all rooms in the selected office
  Map<int, Room> getCurrentOfficeRooms() {
    return Map.fromEntries(_rooms.entries.where((entry) => entry.value.office == _office));
  }

  /// Returns all rooms in the model
  Map<int, Room> getAllRooms() {
    return _rooms;
  }

  Future<ReportCard> generateReportCard() async {
    final bookingData3Weeks = await FirebaseFirestore.instance
        .collection('Bookings_2')
        .where('Day', isGreaterThan: DateTime.now().subtract(const Duration(days: 21)))
        .where('Day', isLessThan: DateTime.now())
        .get();
    final bookingList = _bookingDataToBookings(bookingData3Weeks);

    final numberOfWorkSpacesPerDay = _rooms.values.expand((room) => room.workspaces.values).length;
    final numberOfTimeslotsPerDay = _rooms.values.expand((room) => room.timeslots).length;
    final numberOfBookings3Weeks = bookingList.length;

    //Get most used room
    final roomUseMap = <int, int>{};
    for (var booking in bookingList) {
      roomUseMap.update(booking.roomNr, (value) => ++value, ifAbsent: () => 1);
    }
    var mostUsedRoom = {'room':-1, 'number':0};
    for(var roomUseData in roomUseMap.entries) {
      if(roomUseData.value > (mostUsedRoom['number'] ?? 0)) {
        mostUsedRoom = {'room':roomUseData.key, 'number':roomUseData.value};
      }
    }

    //Get most used workspace
    final workspaceUseMap = <String, int>{};
    for (var booking in bookingList) {
      workspaceUseMap.update('${booking.roomNr} ${booking.workspaceNr}', (value) => ++value, ifAbsent: () => 1);
    }
    var mostUsedWorkSpace = {'room': -1, 'workspace':-1, 'number':0};
    for(var workspaceUseData in workspaceUseMap.entries) {
      if(workspaceUseData.value > (mostUsedWorkSpace['number'] ?? 0)) {
        mostUsedWorkSpace = {'room': int.parse(workspaceUseData.key.split(' ')[0]), 'workspace':int.parse(workspaceUseData.key.split(' ')[1]), 'number':workspaceUseData.value};
      }
    }


    // for(var booking in allBookings.docs) {
    //   print(booking.data());
    // }

    return ReportCard();
  }

  /// Returns a list of all bookings made by the current user as Booking objects.
  Future<List<Booking>> getUserBookings() async {
    var bookingData = await FirebaseFirestore.instance.collection('Bookings_2').where('UserId', isEqualTo: _username).get();
    return _bookingDataToBookings(bookingData);
  }

  List<Booking> _bookingDataToBookings(QuerySnapshot<Map<String, dynamic>> bookingData) {
    List<Booking> bookingList = [];
    for (var doc in bookingData.docs) {
      var docData = doc.data();
      int roomNr = docData['RoomNr'];
      Room room = _rooms[roomNr] ?? Room({1:['Error workspace']}, [{'start': '00:00', 'end': '12:00'}], 'Error room', 'Error Office', 'Error room');
      bookingList.add(Booking(DateTime.fromMicrosecondsSinceEpoch(docData['Day'].microsecondsSinceEpoch), docData['UserId'], roomNr,
          docData['WorkspaceNr'], docData['Timeslot'], docData['RepeatedBookingKey'], room));
    }
    bookingList.sort((a, b) {
      if (a.day.compareTo(b.day) == 0) {
        return a.timeslot.compareTo(b.timeslot);
      }
      return a.day.compareTo(b.day);
    });
    return bookingList;
  }

  Set<String> getAllEquipment() {
    var allEquipment = <String>{};
    for (var room in getAllRooms().values) {
      for (var workspace in room.workspaces.values) {
        for (var equipment in workspace) {
          allEquipment.add(equipment);
        }
      }
    }
    allEquipment.remove("");
    return allEquipment;
  }


  /// Returns information about bookings for a room on a certain day.
  ///
  /// Returns a map with workspace number as key and another map as value.
  /// The inner map has timeslot number as key and boolean as value.
  Future<Map<int, Map<int, String>>> getRoomBookingInformation(int roomNr, DateTime day) async {
    Map<int, Map<int, String>> bookings = {};
    //Generates a 2D map of appropriate size and populate it with 'available'
    _rooms[roomNr]?.workspaces.entries.forEach((workspace) {
      bookings[workspace.key] = <int, String>{};
      for (var timeslot = 0; timeslot < (_rooms[roomNr]?.timeslots.length ?? 0); timeslot++) {
        bookings[workspace.key]?[timeslot] = 'available';
      }
    });
    //Gets the correct bookings data from Firebase
    var bookingDocs = await FirebaseFirestore.instance.collection('Bookings_2').where('RoomNr', isEqualTo: roomNr).where('Day', isEqualTo: day).get();
    //Changes bookings entries to true if there's a timeslot booked
    for (var bookingDoc in bookingDocs.docs) {
      var infoString = bookingDoc['UserId'] == _username ? 'user' : 'booked';
      bookings[bookingDoc['WorkspaceNr']]?[bookingDoc['Timeslot']] = infoString;
    }
    return bookings;
  }

  /// Sets [_office] to the currently selected office.
  void selectOffice(String office) {
    _office = office;
  }

  /// Sets [_division] to the currently selected division.
  void selectDivision(String division) {
    _division = division;
  }

  /// Returns the name of current user.
  String getName() => _username;

  /// Returns the name of the currently selected office.
  String getSelectedOffice() => _office;

  /// Returns the name of the currently selected division. 
  String getSelectedDivision() => _division;

  // ---------------- Modifiers ------------

  Future<void> addAdmin(String adminHashId, String permissions) async{
    await FirebaseFirestore.instance.collection('Admins').doc(adminHashId).set({'Permissions': permissions});
    return;
  }

  Future<void> removeAdmin(String adminHashId) async{
    await FirebaseFirestore.instance.collection('Admins').doc(adminHashId).delete();
    return;
  }

  Future<void> saveDivision(String divisionName, String info) async{
    await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).set({'Info': info});
    return;
  }

  Future<void> removeDivision(String divisionName) async {
    var offices = await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).collection('Offices').get();
    for(var office in offices.docs) {
      office.reference.delete();
    }
    await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).delete();
    return;
  }

  Future<void> saveOffice(String divisionName, String officeName, Office office) async{
    await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).collection('Offices').doc(officeName).set({
      'Address': office.address,
      'Description': office.description
    });
  }

  Future<void> removeOffice(String divisionName, String officeName) async {
    await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).collection('Offices').doc(officeName).delete();
    return;
  }


  /// Adds a room to Firebase.
  Future<void> saveRoom(int roomNr, Room room) async {
    var timeslots = room.timeslots.map((timesMap) {
      var start = timesMap['start'] ?? "";
      var end = timesMap['end'] ?? "";
      return start + "-" + end;
    }).toList();

    FirebaseFirestore.instance.collection('Rooms_2').doc(roomNr.toString()).set(<String, dynamic>{
      'Office': room.office,
      'Name': room.name,
      'Workspaces': room.workspaces.map((key, value) => MapEntry(key.toString(), value)),
      'Description': room.description,
      'Timeslots': timeslots
    });
  }

  /// Removes a room from Firebase and deletes all corresponding bookings
  Future<void> removeRoom(int roomNr) async{
    await FirebaseFirestore.instance.collection('Rooms_2').doc(roomNr.toString()).delete();
    var allBookingsInThatRoom = await FirebaseFirestore.instance.collection('Bookings_2').where('RoomNr', isEqualTo: roomNr).get();
    for(var booking in allBookingsInThatRoom.docs) {
      booking.reference.delete();
    }
    return;
  }

  ///Adds a booking to Firebase.
  ///
  ///[repeatKey] will be used to identify different bookings made with the repeat bookings function when added.
  Future<void> saveBooking(int roomNr, DateTime day, int timeslot, int workspaceNr, [int repeatKey = 0]) async {
    if (_username != "") {
      await FirebaseFirestore.instance.collection('Bookings_2').doc('room:$roomNr workspace:$workspaceNr timeslot:$timeslot day:${day.year}-${day.month}-${day.day}').set(
          {'UserId': _username, 'Timeslot': timeslot, 'Day': day, 'WorkspaceNr': workspaceNr, 'RoomNr': roomNr, 'RepeatedBookingKey': repeatKey});
    }
    return;
  }

  //TODO implement repeat bookings

  /// Removes all matching bookings from Firebase.
  Future<void> removeBooking(Booking booking) async {
    // TODO add remove repeat when implemented

    var references = await FirebaseFirestore.instance
      .collection('Bookings_2')
      .where('UserId', isEqualTo: booking.personID)
      .where('RoomNr', isEqualTo: booking.roomNr)
      .where('WorkspaceNr', isEqualTo: booking.workspaceNr)
      .where('Timeslot', isEqualTo: booking.timeslot)
      .where('Day', isEqualTo: booking.day)
      .get();
    
    for(var document in references.docs) {
      await document.reference.delete();
    }
    return;
  }

// ----------------------------------------------------------------

}

class ReportCard {
  // TODO fill with all analysis information.
}

/// Immutable dataclass which models a room
class Room {
  /// Contains all the workspace in a room.
  /// Key is workspace number and value is a list of all equipment at that workspace as a list of strings.
  final Map<int, List<String>> workspaces;
  /// Contains all timeslots in a room. Entries are Maps structured as such
  /// {'start': '00:00', 'end': '12:00'}
  final List<Map<String, String>> timeslots;
  final String description;
  final String office;
  final String name;

  Room(this.workspaces, this.timeslots, this.description, this.office, this.name);

  @override
  String toString() {
    return 'Room{workspaces: $workspaces, timeslots: $timeslots, description: $description, office: $office, name: $name}';
  }

  /// Returns true if the room has any workspaces with equipment
  bool hasSpecialEquipment() {
    var special = false;
    for (var workspace in workspaces.entries) {
      for (var item in workspace.value) {
        if (item != "") {
          special = true;
        }
      }
    }
    return special;
  }
}


/// Immutable dataclass which models a corporate division
class Division {
  /// Contains all the division's offices. Office name is key.
  final Map<String, Office> offices;

  Division(this.offices);

  @override
  String toString() {
    return 'Division{offices: $offices}';
  }
}


/// Immutable dataclass which models an office
class Office {
  final String address;
  final String description;

  Office(this.address, this.description);

  @override
  String toString() {
    return 'Office{address: $address, description: $description}';
  }
}


/// Immutable dataclass which models a booking
class Booking {
  final DateTime day;
  final String personID;
  final int roomNr;
  final int workspaceNr;
  final int timeslot;
  // repeatedBookingKey is not currently used. Meant to identify several bookings which were made simultaneously.
  final int repeatedBookingKey;
  final Room room;

  Booking(this.day, this.personID, this.roomNr, this.workspaceNr, this.timeslot, this.repeatedBookingKey, this.room);

  @override
  String toString() {
    return 'Booking_2{day: $day, personID: $personID, roomNr: $roomNr, workspaceNr: $workspaceNr, timeslot: $timeslot, repeatedBooking: $repeatedBookingKey}';
  }

  String getStartTime() {
    return room.timeslots[timeslot]['start'] ?? "00:00";
  }

  String getEndTime() {
    return room.timeslots[timeslot]['end'] ?? "24:00";
  }
}
