class Space {
  final int roomNr;
  final int nrOfSeats;
  final String description;
  final String office;

  Space(this.roomNr, this.nrOfSeats, this.description,
      this.office);

  @override
  String toString() {
    return 'RoomNr: $roomNr. $description with $nrOfSeats seats';
  }
}