import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/booking.dart';
import 'models/space.dart';

/// Singleton class to communicate with Firebase.
///
/// Must be initialized with a username to work. Stores a username and selected office during bookings.
class FirebaseHandler {
  /// The current user of the app. Must be initialed .
  var _username = 'init';

  /// The currently selected office.
  var _office = 'init';

  var rooms = <int, Room>{};
  var divisions = <String, Division>{};

  static final FirebaseHandler _instance = FirebaseHandler._(); // Singleton

  FirebaseHandler._(); // Hidden constructor

  /// Initializes the singleton with a username
  static void initialize(String username) {
    _instance._username = username.toLowerCase();
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

  ///Returns a future with a list of the names of offices.
  Future<List<String>> getOffices() async {
    var offices = await FirebaseFirestore.instance.collection('Offices').get();
    return offices.docs.map((e) {
      return e.id;
    }).toList();
  }

  ///Returns a future with a list of all rooms in the currently selected office as Space objects.
  Future<List<Space>> getRooms() async {
    var data = await FirebaseFirestore.instance.collection('Rooms').where('office', isEqualTo: _office).get();
    return data.docs.map((roomSnapshot) => roomSnapshot.data()).map((room) {
      return Space(room['roomNr'], room['size'], room['description'], room['office']);
    }).toList();
  }

  ///Adds rooms to Firebase.
  Future<void> saveSpaceData(String office, int roomNr, String description, int size) async {
    FirebaseFirestore.instance
        .collection("Rooms")
        .doc(roomNr.toString())
        .set({'office': office, 'roomNr': roomNr, 'description': description, 'size': size});
  }

  ///Adds a booking to Firebase.
  Future<void> addBooking(int roomNr, DateTime day) async {
    if (_username != "") {
      FirebaseFirestore.instance.collection('Bookings').add({'day': day, 'roomNr': roomNr, 'personID': _username});
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

  /// Downloads data about rooms and offices from Firebase and builds a model.
  ///
  /// Data is stored in [rooms] and [divisions].
  /// This is information which is not supposed to be updated often.
  Future<void> buildStaticModel() async {

    //Downloads divisions and their offices
    var divisionsData = await FirebaseFirestore.instance.collection('Divisions').get();
    for (var divisonData in divisionsData.docs) {

      var officesData = await FirebaseFirestore.instance.collection('Divisions').doc(divisonData.id).collection('Offices').get();

      var offices = <String, Office>{};
      for (var office in officesData.docs) {
        offices[office.id] = Office(office.data()['Address'], office.data()['Description']);
      }

      divisions[divisonData.id] = Division(offices);
    }

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

      rooms[int.parse(room.id)] = Room(workspaces, timeslots, room.data()['Description'], room.data()['Office'], room.data()['Name']);
    }
    return;
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

  /// Returns a future with the number of remaining seats in a specific room on a specific day
  Future<int> getRemainingSeats(int roomNr, DateTime day) async {
    //TODO add back timeslots
    // gets the entry for the appropriate room from Firebase.
    var nrRooms = await FirebaseFirestore.instance.collection('Rooms').where('roomNr', isEqualTo: roomNr).get();

    //Gets all appropriate bookings for this room at this day from Firebase
    var nrBooked = await FirebaseFirestore.instance.collection('Bookings').where('roomNr', isEqualTo: roomNr).where('day', isEqualTo: day).get();

    // Compares the size of the room with the number of bookings.
    var spaceLeft = nrRooms.docs.first.get('size') - nrBooked.docs.length;
    return spaceLeft > 0 ? spaceLeft : 0;
  }

  /// Returns true if the singleton is initialized.
  static bool isInitialized() {
    return _instance._username != 'init';
  }

  /// Returns the name of current user.
  String getName() => _username;

  /// Returns the name of the currently selected office.
  String getSelectedOffice() => _office;

  /// Sets office to the currently selected office.
  void selectOffice(String office) {
    _office = office;
  }
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
