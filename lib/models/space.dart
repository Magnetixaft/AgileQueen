class Space {
  final int roomNr;
  final int nrOfSeats;
  final String description;
  final int nrOfTimeslots;
  final String office;

  Space(this.roomNr, this.nrOfSeats, this.description, this.nrOfTimeslots,
      this.office);

  @override
  String toString() {
    return 'RoomNr: $roomNr. $description with $nrOfSeats seats divided into $nrOfTimeslots timeslots';
  }
}