import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/booking.dart';
import 'models/space.dart';

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
    _instance._username = username.toLowerCase();
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
    for (var divisonData in divisionsData.docs) {
      var officesData = await FirebaseFirestore.instance.collection('Divisions').doc(divisonData.id).collection('Offices').get();

      var offices = <String, Office>{};
      for (var office in officesData.docs) {
        offices[office.id] = Office(office.data()['Address'], office.data()['Description']);
      }

      _divisions[divisonData.id] = Division(offices);
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
  Map<String, Office> getOffices() {
    return _divisions[_division]?.offices ?? {};
  }

  /// Returns all rooms in the selected office
  Map<int, Room> getRooms() {
    return Map.fromEntries(_rooms.entries.where((entry) => entry.value.office == _office));
  }

  ///Returns a list of all bookings made by the current user as Booking objects.
  Future<List<Booking>> getUserBookings() async {
    var data = await FirebaseFirestore.instance.collection('Bookings').where('personID', isEqualTo: _username).get();
    List<Booking> bookingList = [];
    for (var doc in data.docs) {
      var docData = doc.data();
      bookingList.add(Booking(
          //TODO add timeslots again
          DateTime.fromMicrosecondsSinceEpoch(docData['day'].microsecondsSinceEpoch),
          docData['personID'],
          docData['roomNr']));
    }
    bookingList.sort((a, b) {
      return a.day.compareTo(b.day); //TODO Reimplement the sorting function that looked at timeslots too.
    });
    return bookingList;
  }

  /// Returns a list of all bookings made by the current user as Booking objects.
  Future<List<Booking_2>> getUserBookings_2() async {
    var data = await FirebaseFirestore.instance.collection('Bookings_2').where('UserId', isEqualTo: _username).get();
    List<Booking_2> bookingList = [];
    for (var doc in data.docs) {
      var docData = doc.data();
      bookingList.add(Booking_2(DateTime.fromMicrosecondsSinceEpoch(docData['Day'].microsecondsSinceEpoch), docData['UserId'], docData['RoomNr'],
          docData['WorkspaceNr'], docData['Timeslot'], docData['RepeatedBooking']));
    }
    bookingList.sort((a, b) {
      if (a.day.compareTo(b.day) == 0) {
        return a.timeslot.compareTo(b.timeslot);
      }
      return a.day.compareTo(b.day);
    });
    return bookingList;
  }

  // /// Returns a future with the number of remaining seats in a specific room on a specific day
  // Future<int> getRemainingSeats(int roomNr, DateTime day) async {
  //   //TODO add back timeslots
  //   // gets the entry for the appropriate room from Firebase.
  //   var nrRooms = await FirebaseFirestore.instance.collection('Rooms').where('roomNr', isEqualTo: roomNr).get();
  //
  //   //Gets all appropriate bookings for this room at this day from Firebase
  //   var nrBooked = await FirebaseFirestore.instance.collection('Bookings').where('roomNr', isEqualTo: roomNr).where('day', isEqualTo: day).get();
  //
  //   // Compares the size of the room with the number of bookings.
  //   var spaceLeft = nrRooms.docs.first.get('size') - nrBooked.docs.length;
  //   return spaceLeft > 0 ? spaceLeft : 0;
  // }

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

  // ---------------- Modifiers ------------

  /// Adds a room to Firebase.
  Future<void> saveSpaceData(int roomNr, Room room) async {
    var timeslots = room.timeslots.map((timesMap) {
      var start = timesMap['start'] ?? "";
      var end = timesMap['end'] ?? "";
      return start + "-" + end;
    });

    FirebaseFirestore.instance.collection('Rooms_2').doc(roomNr.toString()).set(<String, dynamic>{
      'Office': room.office,
      'Name': room.name,
      'Workspaces': room.workspaces.map((key, value) => MapEntry(key.toString(), value)),
      'Description': room.description,
      'Timeslots': timeslots
    });
  }

  ///Adds a booking to Firebase.
  Future<void> addBooking(int roomNr, DateTime day, int timeslot, int workspaceNr) async {
    if (_username != "") {
      FirebaseFirestore.instance
          .collection('Bookings_2')
          .add({'UserId': _username, 'Timeslot': timeslot, 'Day': day, 'WorkspaceNr': workspaceNr, 'RoomNr': roomNr, 'RepeatedBooking': false});
    }
  }

  /// Removes all matching bookings from Firebase.
  Future<void> removeBooking(int roomNr, DateTime day) async {
    FirebaseFirestore.instance
        .collection('Bookings')
        .where('personID', isEqualTo: _username)
        .where('roomNr', isEqualTo: roomNr)
        .where('day', isEqualTo: day)
        .get()
        .then((value) {
      for (var document in value.docs) {
        document.reference.delete();
      }
    });
  }

// ----------------------------------------------------------------

}

class Room {
  final Map<int, List<String>> workspaces;
  final List<Map<String, String>> timeslots;
  final String description;
  final String office;
  final String name;

  Room(this.workspaces, this.timeslots, this.description, this.office, this.name);

  @override
  String toString() {
    return 'Room{workspaces: $workspaces, timeslots: $timeslots, description: $description, office: $office, name: $name}';
  }
}

class Division {
  final Map<String, Office> offices;

  Division(this.offices);

  @override
  String toString() {
    return 'Division{offices: $offices}';
  }
}

class Office {
  final String address;
  final String description;

  Office(this.address, this.description);

  @override
  String toString() {
    return 'Office{address: $address, description: $description}';
  }
}

class Booking_2 {
  final DateTime day;
  final String personID;
  final int roomNr;
  final int workspaceNr;
  final int timeslot;
  final bool repeatedBooking;

  Booking_2(this.day, this.personID, this.roomNr, this.workspaceNr, this.timeslot, this.repeatedBooking);

  @override
  String toString() {
    return 'Booking_2{day: $day, personID: $personID, roomNr: $roomNr, workspaceNr: $workspaceNr, timeslot: $timeslot, repeatedBooking: $repeatedBooking}';
  }
}

// ///Returns a future with a list of the names of offices.
// Future<List<String>> getOffices() async {
//   var offices = await FirebaseFirestore.instance.collection('Offices').get();
//   return offices.docs.map((e) {
//     return e.id;
//   }).toList();
// }

// ///Returns a future with a list of all rooms in the currently selected office as Space objects.
// Future<List<Space>> getRooms() async {
//   var data = await FirebaseFirestore.instance.collection('Rooms').where('office', isEqualTo: _office).get();
//   return data.docs.map((roomSnapshot) => roomSnapshot.data()).map((room) {
//     return Space(room['roomNr'], room['size'], room['description'], room['office']);
//   }).toList();
// }

// ///Adds a booking to Firebase.
// Future<void> addBooking(int roomNr, DateTime day) async {
//   if (_username != "") {
//     FirebaseFirestore.instance.collection('Bookings').add({'day': day, 'roomNr': roomNr, 'personID': _username});
//   }
// }

// ///Adds rooms to Firebase.
// Future<void> saveSpaceData(String office, int roomNr, String description, int size) async {
//   FirebaseFirestore.instance
//       .collection("Rooms")
//       .doc(roomNr.toString())
//       .set({'office': office, 'roomNr': roomNr, 'description': description, 'size': size});
// }
