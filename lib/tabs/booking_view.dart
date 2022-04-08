import 'package:flutter/material.dart';
import 'package:flutter_application_1/FirebaseHandler.dart';

class BookingView extends StatefulWidget {
  const BookingView({Key? key}) : super(key: key);

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> implements SelectorListener {
  int stepNr = 1;
  int dayNr = -1;
  int roomNr = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
        children: getContent());
  }

  List<Widget> getContent() {
    var content = <Widget>[];

    content.add(Container(
      height: 50,
    ));

    if (stepNr == 1) {
      content.add(Text('Hello ${FirebaseHandler.getInstance().getName()}. Please choose a day'));
    }
    content.add(const Divider(
      height: 20,
    ));

    if (stepNr == 1) {
      content.add(DaySelector(this));
    } else if(stepNr > 1){
      content.add(GestureDetector(
        child: Text(
          '${dayNrToWeekAndDay(dayNr)} chosen. Tap to change day',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          setState(() {
            stepNr = 1;
          });
        },
      ));
    }

    if (stepNr == 2) {
      content.add(RoomSelector(this));
    } else if (stepNr > 2) {
      content.add(const Divider(height: 10));
      content.add(GestureDetector(
        child: Text(
          'Room number $roomNr chosen. Tap to change room',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () {
          setState(() {
            stepNr = 2;
          });
        },
      ));
    }

    if(stepNr == 3) {
      content.add(TimeslotSelector(this, dayNr, roomNr));
    }

    return content;
  }

  @override
  void dayChosen(int dayNr) {
    setState(() {
      this.dayNr = dayNr;
      stepNr = 2;
    });
  }

  @override
  void roomChosen(int roomNr) {
    setState(() {
      this.roomNr = roomNr;
      stepNr = 3;
    });
  }

  @override
  void timeslotChosen(int timeslot) {
    setState(() {
      stepNr = 1;
      FirebaseHandler.getInstance().addBooking(roomNr, dayNr, timeslot);
      FirebaseHandler.getInstance().getData();
    });
  }

  String dayNrToWeekAndDay(int dayNr) {
    var weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${weekdays[(dayNr - 1) % 7]} Week ${((dayNr - 1) / 7 + 1).truncate()}';
  }

}

abstract class SelectorListener {
  void dayChosen(int day);
  void roomChosen(int room);
  void timeslotChosen(int timeslot);
}

class DaySelector extends StatelessWidget {
  final SelectorListener daySelectorListener;
  const DaySelector(this.daySelectorListener, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Expanded(
        child: ListView.builder(
          itemBuilder: (context, week) {
            return ListTile(
              title: SizedBox(
                height: 150,
                child: Column(
                  children: [
                    Text(
                      'Week ${week + 1}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Divider(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: getDayButtons(week, daySelectorListener),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }

  List<Widget> getDayButtons(int week, SelectorListener daySelectorListener) {
    var days = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    var dayButtons = <Widget>[];
    for (var day = 0; day <= 6; day++) {
      dayButtons.add(ElevatedButton(
          onPressed: () {
            daySelectorListener.dayChosen(week * 7 + day + 1);
          },
          child: Text(days[day])));
      if (day < 6) {
        dayButtons.add(const Spacer(flex: 1));
      }
    }
    return dayButtons;
  }
}

class RoomSelector extends StatelessWidget {
  final SelectorListener selectorListener;
  const RoomSelector(this.selectorListener, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView(
          children: getRoomTiles(selectorListener),
        ));
  }

  List<Widget> getRoomTiles(SelectorListener selectorListener) {
    var rooms = <Widget>[];
    for (var room in FirebaseHandler.getInstance().getSpaces().values) {
      rooms.add(ListTile(
        leading: Text('Room Nr:${room.roomNr.toString()}'),
        title: Text(room.description),
        trailing: ElevatedButton(
          child: const Text('View'),
          onPressed: () {
            selectorListener.roomChosen(room.roomNr);
          },
        ),
      ));
    }

    return rooms;
  }
}

class TimeslotSelector extends StatelessWidget {
  final SelectorListener selectorListener;
  final int roomNr;
  final int dayNr;
  const TimeslotSelector(this.selectorListener, this.dayNr, this.roomNr, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView(
          children: getTimeslotTiles(selectorListener,dayNr, roomNr),
        ));
  }

  List<Widget> getTimeslotTiles(SelectorListener selectorListener,int dayNr,  int roomNr, ) {
    var timeslots = <Widget>[];
    int nrOfTimeSlots = FirebaseHandler.getInstance().getSpace(roomNr).nrOfTimeslots;
    for(var timeslot = 1; timeslot <= nrOfTimeSlots; timeslot++) {
      int seatsRemaining = FirebaseHandler.getInstance().remainingSeats(roomNr, dayNr, timeslot);
      timeslots.add(ListTile(
        leading: Text('TimeSlot $timeslot'),
        title: Text('$seatsRemaining seats remaining'),
        trailing: ElevatedButton(
          child: const Text('Book'),
          onPressed: () {
            selectorListener.timeslotChosen(timeslot);
          },
        ),
      ));
    }
    return timeslots;
  }
}

