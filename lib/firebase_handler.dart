import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/booking.dart';
import 'models/space.dart';

class FirebaseHandler {
  // A singleton class which can keep track of rooms and bookings, both in general and for one user. Must be initialized
  var _username = 'init';
  var _office = 'init';
  static final FirebaseHandler _instance = FirebaseHandler._(); // Singleton

  FirebaseHandler._(); // Hidden constructor

  static void initialize(String username) {
    _instance._username = username.toLowerCase();
  }

  static FirebaseHandler getInstance() {
    // Singleton
    if (_instance._username == 'init') {
      throw Exception('Singleton not initialized with username');
    }
    return _instance;
  }

  //Returns a list of the names of offices
  Future<List<String>> getOffices() async {
    var offices = await FirebaseFirestore.instance.collection('Offices').get();
    return offices.docs.map((e) {
      return e.id;
    }).toList();
  }

  //Returns a list of all rooms in the currently selected office as Space objects.
  Future<List<Space>> getRooms() async {
    var data = await FirebaseFirestore.instance
        .collection('Rooms')
        .where('office', isEqualTo: _office)
        .get();
    return data.docs.map((roomSnapshot) => roomSnapshot.data()).map((room) {
      return Space(room['roomNr'], room['size'], room['description'], room['office']);
    }).toList();
  }

  //Adds rooms to Firebase
  Future<void> saveSpaceData(String office, int roomNr, String description,
      int size) async {
    FirebaseFirestore.instance.collection("Rooms").doc(roomNr.toString()).set({
      'office': office,
      'roomNr': roomNr,
      'description': description,
      'size': size
    });
  }

  //Adds bookings to Firebase.
  Future<void> addBooking(int roomNr, DateTime day) async {
    if (_username != "") {
      FirebaseFirestore.instance.collection('Bookings').add({
        'day': day,
        'roomNr': roomNr,
        'personID': _username
      });
    }
  }

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

  //Returns a list of all bookings made by the current user in Booking objects.
  Future<List<Booking>> getUserBookings() async {
    var data = await FirebaseFirestore.instance
        .collection('Bookings')
        .where('personID', isEqualTo: _username)
        .get();
    List<Booking> bookingList = [];
    for (var doc in data.docs) {
      var docData = doc.data();
      bookingList.add(Booking(
          DateTime.fromMicrosecondsSinceEpoch(
              docData['day'].microsecondsSinceEpoch),
          docData['personID'],
          docData['roomNr']
          ));
    }
    bookingList.sort((a, b) {
      return a.day.compareTo(b.day);
    });
    return bookingList;
  }

  Future<int> getRemainingSeats(int roomNr, DateTime day) async {
    //gets the entry for the appropriate room from Firebase.
    var nrRooms = await FirebaseFirestore.instance
        .collection('Rooms')
        .where('roomNr', isEqualTo: roomNr)
        .get();

    //Gets all appropriate bookings for this room at this day from Firebase
    var nrBooked = await FirebaseFirestore.instance
        .collection('Bookings')
        .where('roomNr', isEqualTo: roomNr)
        .where('day', isEqualTo: day)
        .get();

    // Compares the size of the room with the number of bookings.
    var spaceLeft = nrRooms.docs.first.get('size') - nrBooked.docs.length;
    return spaceLeft > 0 ? spaceLeft : 0;
  }

  static bool isInitialized() {
    return _instance._username != 'init';
  }

  String getName() => _username;

  String getSelectedOffice() => _office;

  void selectOffice(String office) {
    _office = office;
  }
}

