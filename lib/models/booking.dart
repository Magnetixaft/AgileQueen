class Booking {
  final DateTime day;
  final String personID;
  final int roomNr;
  final int timeslot;

  Booking(this.day, this.personID, this.roomNr, this.timeslot);

  @override
  String toString() {
    return 'Booking{day: $day, personID: $personID, roomNr: $roomNr, timeslot: $timeslot}';
  }
}