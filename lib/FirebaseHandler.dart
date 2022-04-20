import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHandler {
  // A singleton class which can keep track of rooms and bookings, both in general and for one user. Must be initialized
  var _spaces = <int, Space>{};
  var _allBookings = <String, int>{};
  var _userBookings = <String>[];
  var _username = 'init';
  static final FirebaseHandler _instance = FirebaseHandler._(); // Singleton

  FirebaseHandler._(); // Hidden constructor

  static void initialize(String username) {
    _instance._username = username.toLowerCase();
    _instance.getData();
  }

  static FirebaseHandler getInstance() {
    // Singleton
    if (_instance._username == 'init') {
      throw Exception('Singleton not initialized with username');
    }
    return _instance;
  }

  Future<void> getData() async {
    await retrieveSpaces();
    await retrieveBookings();
  }

  Future<void> retrieveSpaces() async {
    // retrieves the data from firebase and instantiate _spaces with Space objects
    _spaces = <int, Space>{};
    var allDocs = await FirebaseFirestore.instance
        .collection("OfficeData")
        .doc("Rooms")
        .get();

    var data = allDocs.data(); // local variable to make the null check work
    if (data != null) {
      for (var entry in data.entries) {
        // for each entry of room information make a Space object and store in _spaces
        _spaces[int.parse(entry.key)] = (Space(
            int.parse(entry.key), // id = room number
            entry.value['size'],
            entry.value['description'],
            entry.value['timeslots'] ?? 1));
      }
    }
  }

  Future<void> saveSpaceData(
      int roomNr, String description, int size, int nrOfTimeslots) async {
    // function for adding rooms
    await FirebaseFirestore.instance
        .collection("OfficeData")
        .doc("Rooms")
        .update({
      roomNr.toString(): {
        'description': description,
        'size': size,
        'timeslots': nrOfTimeslots
      }
    });
  }

  Future<void> retrieveBookings() async {
    // Map of all bookings {'Room # Day # Timeslot #': numberOfPeople}
    _allBookings = <String, int>{};
    // Array of all booking of the user
    _userBookings = <String>[];

    var currentData = await FirebaseFirestore.instance
        .collection('OfficeData')
        .doc('Bookings')
        .get();
    // need to be local variable for the null check.
    var data = currentData.data();
    if (data != null) {
      for (var entry in data.entries) {
        if (entry.value.contains(_username)) {
          // adds the booking to the user's list of bookings if they appear
          _userBookings.add(entry.key);
        }
        // adds to map with 'Room # Day # Timeslot #' as key and number of booked seats as value
        _allBookings[entry.key] = entry.value.length;
      }
    }
  }

  Future<void> addBooking(int roomNr, int day, int timeslot) async {
    // function for booking timeslots
    var docString =
        'Room ${roomNr.toString()} Day ${day.toString()} Timeslot ${timeslot.toString()}'; //just the file address in firestore

    await FirebaseFirestore.instance // update the array in firebase
        .collection('OfficeData')
        .doc('Bookings')
        .update({
      docString: FieldValue.arrayUnion([_username])
    });
  }

  Future<void> removeBooking(int roomNr, int day, int timeslot) async{
    var docString =
        'Room ${roomNr.toString()} Day ${day.toString()} Timeslot ${timeslot.toString()}'; //just the file address in firestore

    await FirebaseFirestore.instance // update the array in firebase
        .collection('OfficeData')
        .doc('Bookings')
        .update({
      docString: FieldValue.arrayRemove([_username])
    });
  }

  int remainingSeats(int roomNr, int day, int timeslot) {
    var nrOfSeats = _spaces[roomNr]?.nrOfSeats ?? 0;
    var booked = _allBookings['Room $roomNr Day $day Timeslot $timeslot'] ?? 0;

    return nrOfSeats - booked > 0 ? nrOfSeats - booked : 0;
  }

  static bool isInitialized() => _instance._username != 'init';

  Space getSpace(int roomNr) =>
      _spaces[roomNr] ?? Space(0, 1, 'errorSpace', 10);

  List<String> getUserBookings() => _userBookings;

  Map<int, Space> getSpaces() => _spaces;

  String getName() => _username;

}

class Space {
  final int roomNr;
  final int nrOfSeats;
  final String description;
  final int nrOfTimeslots;

  Space(this.roomNr, this.nrOfSeats, this.description, this.nrOfTimeslots);

  @override
  String toString() => 'RoomNr: $roomNr. $description with $nrOfSeats seats divided into $nrOfTimeslots timeslots';
}
