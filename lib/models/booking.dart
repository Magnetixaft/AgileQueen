class Booking {
  final DateTime day;
  final String personID;
  final int roomNr;

  Booking(this.day, this.personID, this.roomNr);

  @override
  String toString() {
    return 'Booking{day: $day, personID: $personID, roomNr: $roomNr}';
  }
}