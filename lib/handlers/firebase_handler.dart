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

  /// Initializes the singleton with a username, only needs "Admin" at the moment.
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

  ///Gets data related to divisions to [buildStaticModel]
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

  ///Gets data related to rooms to [buildStaticModel]
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

      _rooms[int.parse(room.id)] =
          Room(int.parse(room.id), workspaces, timeslots, room.data()['Description'], room.data()['Office'], room.data()['Name']);
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

  /// Returns the specified Room object or a place holder Room object.
  Room getRoom(int roomNr) {
    return _rooms[roomNr] ??
        Room(
            -1,
            {
              1: ['Error workspace']
            },
            [
              {'start': '00:00', 'end': '12:00'}
            ],
            'Error room',
            'Error Office',
            'Error room');
  }

  /// Returns a [DivisionReportCard] with analytical information about a division.
  Future<DivisionReportCard> generateDivisionReportCard(String division) async {
    var pastBookings = await _getXDaysBookings(21, 21); // TODO REMOVE!!!!!
    var allOfficesInDivision = getDivisions()[division]?.offices.keys.toList() ?? ['ErrorOffice'];
    var allRoomsInDivision = _rooms.values.where((room1) => allOfficesInDivision.contains(room1.office)).toList();
    var allRoomNrInDivision = allRoomsInDivision.map((room2) => room2.roomNr).toList();
    var allPastBookingsInDivision = pastBookings.where((booking) => allRoomNrInDivision.contains(booking.roomNr)).toList();

    var futureBookings = await _getXDaysBookings(0, 1000);
    var allFutureBookingsInDivision = futureBookings.where((booking) => allRoomNrInDivision.contains(booking.roomNr)).toList();
    var numberOfFutureBookings = allFutureBookingsInDivision.length;

    var officeUse = getOfficeUsage(allPastBookingsInDivision);
    var roomUsage = getRoomUsage(allPastBookingsInDivision);
    var workspaceUsage = getWorkspaceUsage(allPastBookingsInDivision);
    var bookedMinutes = getNrBookedMinutes(allPastBookingsInDivision);
    var bookableMinutes = getPossibleBookableMinutes(allRoomsInDivision, 15);
    var usageRate = bookedMinutes / bookableMinutes;
    var equipmentUsage = getEquipmentUsage(allPastBookingsInDivision);
    return DivisionReportCard(officeUse, roomUsage, bookedMinutes, workspaceUsage, usageRate, numberOfFutureBookings, equipmentUsage);
  }

  /// Returns a [OfficeReportCard] with analytical information about an office.
  Future<OfficeReportCard> generateOfficeReportCard(String office) async {
    var pastBookings = await _getXDaysBookings(21, 21); // TODO REMOVE!!!!!
    var allRoomsInOffice = _rooms.values.where((room1) => room1.office == office).toList();
    var allRoomNrInOffice = allRoomsInOffice.map((room2) => room2.roomNr).toList();
    var allPastBookingsInOffice = pastBookings.where((booking) => allRoomNrInOffice.contains(booking.roomNr)).toList();

    var futureBookings = await _getXDaysBookings(0, 1000);
    var allFutureBookingsInOffice = futureBookings.where((booking) => allRoomNrInOffice.contains(booking.roomNr)).toList();
    var numberOfFutureBookings = allFutureBookingsInOffice.length;

    var roomUsage = getRoomUsage(allPastBookingsInOffice);
    var workspaceUsage = getWorkspaceUsage(allPastBookingsInOffice);
    var bookedMinutes = getNrBookedMinutes(allPastBookingsInOffice);
    var bookableMinutes = getPossibleBookableMinutes(allRoomsInOffice, 15);
    var usageRate = bookedMinutes / bookableMinutes;
    var equipmentUsage = getEquipmentUsage(allPastBookingsInOffice);
    return OfficeReportCard(roomUsage, bookedMinutes, workspaceUsage, usageRate, numberOfFutureBookings, equipmentUsage);
  }

  /// Returns all bookings made between [numberOfPastDays] and [numberOfFutureDays] as a list of [Booking].
  Future<List<Booking>> _getXDaysBookings(int numberOfPastDays, int numberOfFutureDays) async {
    final bookingData3Weeks = await FirebaseFirestore.instance
        .collection('Bookings_2')
        .where('Day', isGreaterThan: DateTime.now().subtract(Duration(days: numberOfPastDays)))
        .where('Day', isLessThan: DateTime.now().add(Duration(days: numberOfFutureDays)))
        .get();
    return _bookingDataToBookings(bookingData3Weeks);
  }

  /// Returns a sorted list of pairs containing offices and how many bookings for them were in the list.
  List<MapEntry<String, int>> getOfficeUsage(List<Booking> bookingList) {
    var officeUseMap = <String, int>{};

    for (var booking in bookingList) {
      officeUseMap.update(booking.room.office, (value) => ++value, ifAbsent: () => 1);
    }
    var pairs = officeUseMap.entries.toList();
    pairs.sort((a, b) => b.value - a.value);
    return pairs;
  }

  /// Returns a sorted list of pairs containing rooms and how many bookings for them were in the list.
  List<MapEntry<Room, int>> getRoomUsage(List<Booking> bookingList) {
    //Get most used room
    final roomUseMap = <int, int>{};
    for (var booking in bookingList) {
      roomUseMap.update(booking.roomNr, (value) => ++value, ifAbsent: () => 1);
    }
    var roomNrPairs = roomUseMap.entries.toList();
    var roomPairs = roomNrPairs.map((entry) => MapEntry(getRoom(entry.key), entry.value)).toList();
    roomPairs.sort((a, b) => b.value - a.value);
    return roomPairs;
  }

  /// Returns a sorted list of pairs containing workspaces and how many bookings for them were in the list.
  List<MapEntry<String, int>> getWorkspaceUsage(List<Booking> bookingList) {
    //Get most used workspace
    final workspaceUseMap = <String, int>{};
    for (var booking in bookingList) {
      workspaceUseMap.update('${booking.roomNr} ${booking.workspaceNr}', (value) => ++value, ifAbsent: () => 1);
    }
    var pairs = workspaceUseMap.entries.toList();
    pairs.sort((a, b) => b.value - a.value);
    return pairs;
  }

  /// Returns a sorted list of pairs containing equipment and how many times they have been booked.
  List<MapEntry<String, int>> getEquipmentUsage(List<Booking> bookingList) {
    //Get most used workspace
    final equipmentUseMap = <String, int>{};
    final equipmentList = <String>[];
    for (var booking in bookingList) {
      booking.room.workspaces[booking.workspaceNr]?.forEach((element) {
        equipmentList.add(element);
      });
    }
    for (var equipment in equipmentList) {
      equipmentUseMap.update(
        equipment,
            (value) => ++value,
        ifAbsent: () => 1,
      );
    }
    // Removes '', which represents workspaces without equipment.
    equipmentUseMap.remove('');
    var pairs = equipmentUseMap.entries.toList();
    pairs.sort((a, b) => b.value - a.value);
    return pairs;
  }

  /// Returns the total number of minutes booked in the bookings in the list.
  int getNrBookedMinutes(List<Booking> bookingList) {
    // Get total amount of booked time.
    int bookedTime3Weeks = 0;
    for (var booking in bookingList) {
      var hours = int.parse(booking.getEndTime().split(':')[0]) - int.parse(booking.getStartTime().split(':')[0]);
      var minutes = int.parse(booking.getEndTime().split(':')[1]) - int.parse(booking.getStartTime().split(':')[1]);
      bookedTime3Weeks += (hours * 60 + minutes);
    }
    return bookedTime3Weeks;
  }

  /// Returns the number of minutes which are bookable in the list of rooms during the number of days.
  int getPossibleBookableMinutes(List<Room> rooms, int numberOfWorkdays) {
    // Get all possible time last three weeks.
    int possibleTimePerDay = 0;
    for (var room in rooms) {
      var roomTime = 0; // The minutes in timeslots
      for (var timeslot in room.timeslots) {
        var hours = int.parse(timeslot['end']!.split(':')[0]) - int.parse(timeslot['start']!.split(':')[0]);
        var minutes = int.parse(timeslot['end']!.split(':')[1]) - int.parse(timeslot['start']!.split(':')[1]);
        roomTime += (hours * 60 + minutes);
      }
      var timeMultiplier = room.workspaces.length; // The time in the timeslots should be multiplied by the number of workspaces
      possibleTimePerDay += (roomTime * timeMultiplier);
    }
    return (possibleTimePerDay * numberOfWorkdays); // multiplying with the number of workdays.
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
      Room room = getRoom(roomNr);
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

  /// Returns a set of all equipment which is present in all rooms.
  /// Does not check for division or office.
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
  /// The inner map has timeslot number as key and String as value.
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
    //Changes bookings entries to the correct string if there's a timeslot booked
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

  ///Gets a list of all users with admin privileges
  Future<List<String>> getAdminList() async {
    var data = await FirebaseFirestore.instance.collection('Admins').where('Permissions', isEqualTo: "all").get();
    List<String> adminList = [];
    for (var doc in data.docs) {
      adminList.add(doc.id);
    }
    return adminList;
  }

  // ---------------- Modifiers ------------

  ///Adds an admin, needs "all" [permissions] in order to get admin privileges
  Future<void> addAdmin(String adminHashId, String permissions, String name) async {
    await FirebaseFirestore.instance.collection('Admins').doc(adminHashId).set({'Permissions': permissions, 'Name': name});
    return;
  }

  ///Removes an admin using email as [adminHashId]
  Future<void> removeAdmin(String adminHashId) async {
    await FirebaseFirestore.instance.collection('Admins').doc(adminHashId).delete();
    return;
  }

  Future<List<Admin>> getAllAdmins() async {
    var adminList = <Admin>[];
    var allAdmins = await FirebaseFirestore.instance.collection('Admins').get();

    for (var admin in allAdmins.docs) {
      adminList.add(Admin(admin.id, admin.data()['Name'], admin.data()['Permissions']));
    }
    return adminList;
  }

  ///Saves a division
  Future<void> saveDivision(String divisionName, String info) async {
    await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).set({'Info': info});
    return;
  }

  ///Removes a division, given name of division
  Future<void> removeDivision(String divisionName) async {

    // var offices = await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).collection('Offices').get();
    // for (var office in offices.docs) {
    //   office.reference.delete();
    // }
    _divisions[divisionName]?.offices.forEach((officeName, value) async {
      await removeOffice(divisionName, officeName);
    });

    await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).delete();
    return;
  }

  /// Adds an office to Firebase
  Future<void> saveOffice(String divisionName, String officeName, Office office) async {
    await FirebaseFirestore.instance
        .collection('Divisions')
        .doc(divisionName)
        .collection('Offices')
        .doc(officeName)
        .set({'Address': office.address, 'Description': office.description});
  }

  ///Removes an office, given a name of division and name of office
  Future<void> removeOffice(String divisionName, String officeName) async {
    _rooms.entries.where((roomEntry) => roomEntry.value.office == officeName).forEach((remainingEntry) async {
      await removeRoom(remainingEntry.key);
    });
    await FirebaseFirestore.instance.collection('Divisions').doc(divisionName).collection('Offices').doc(officeName).delete();
    return;
  }

  /// Adds a room to Firebase.
  Future<void> saveRoom(int roomNr, Room room) async {
    var timeslots = room.timeslots.map((timesMap) {
      var start = timesMap['start'] ?? "6:00";
      var end = timesMap['end'] ?? "12:00";
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
  Future<void> removeRoom(int roomNr) async {
    await FirebaseFirestore.instance.collection('Rooms_2').doc(roomNr.toString()).delete();
    var allBookingsInThatRoom = await FirebaseFirestore.instance.collection('Bookings_2').where('RoomNr', isEqualTo: roomNr).get();
    for (var booking in allBookingsInThatRoom.docs) {
      booking.reference.delete();
    }
    return;
  }

  ///Adds a booking to Firebase.
  ///
  ///[repeatKey] will be used to identify different bookings made with the repeat bookings function when added.
  Future<void> saveBooking(int roomNr, DateTime day, int timeslot, int workspaceNr, [int repeatKey = 0]) async {
    if (_username != "") {
      await FirebaseFirestore.instance
          .collection('Bookings_2')
          .doc('room:$roomNr workspace:$workspaceNr timeslot:$timeslot day:${day.year}-${day.month}-${day.day}')
          .set(
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

    for (var document in references.docs) {
      await document.reference.delete();
    }
    return;
  }
}

/// Immutable data class which represents an Admin user.
class Admin {
  final String adminHashId;
  final String name;
  final String permissions;

  Admin(this.adminHashId, this.name, this.permissions);

  @override
  String toString() {
    return 'Room{adminHashId: $adminHashId, name: $name, permissions: $permissions}';
  }

  String getName() {
    return name;
  }
}

// ----------------------------------------------------------------

/// immutable data class for reporting analytics
class DivisionReportCard {
  final List<MapEntry<String, int>> officeUse;
  final List<MapEntry<Room, int>> roomUse;
  final List<MapEntry<String, int>> workspaceUse;
  final int bookedMinutes;
  final double usageRate;
  final int numberOfFutureBookings;
  final List<MapEntry<String, int>> equipmentUsage;

  DivisionReportCard(
      this.officeUse, this.roomUse, this.bookedMinutes, this.workspaceUse, this.usageRate, this.numberOfFutureBookings, this.equipmentUsage);

  @override
  String toString() {
    return 'DivisionReportCard{officeUse: $officeUse, roomUse: $roomUse, workspaceUse: $workspaceUse, bookedMinutes: $bookedMinutes, usageRate: $usageRate, numberOfFutureBookings: $numberOfFutureBookings, equipmentUsage: $equipmentUsage}';
  }
}

/// immutable data class for reporting analytics
class OfficeReportCard {
  final List<MapEntry<Room, int>> roomUse;
  final List<MapEntry<String, int>> workspaceUse;
  final int bookedMinutes;
  final double usageRate;
  final int numberOfFutureBookings;
  final List<MapEntry<String, int>> equipmentUsage;

  OfficeReportCard(this.roomUse, this.bookedMinutes, this.workspaceUse, this.usageRate, this.numberOfFutureBookings, this.equipmentUsage);

  @override
  String toString() {
    return 'OfficeReportCard{roomUse: $roomUse, workspaceUse: $workspaceUse, bookedMinutes: $bookedMinutes, usageRate: $usageRate, numberOfFutureBookings: $numberOfFutureBookings, equipmentUsage: $equipmentUsage}';
  }
}

/// Immutable dataclass which models a room
class Room {
  /// Contains all the workspace in a room.
  /// Key is workspace number and value is a list of all equipment at that workspace as a list of strings.
  final Map<int, List<String>> workspaces;

  /// Contains all timeslots in a room. Entries are Maps structured as such
  /// {'start': '00:00', 'end': '12:00'}
  final int roomNr;
  final List<Map<String, String>> timeslots;
  final String description;
  final String office;
  final String name;

  Room(this.roomNr, this.workspaces, this.timeslots, this.description, this.office, this.name);

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
