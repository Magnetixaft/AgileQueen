import 'package:flutter/material.dart';

//This class represents the detailed my bookings view.
class DetailedView extends StatelessWidget {
  final String office;
  final String address;
  final String date;
  final String description; 

  const DetailedView(this.office, this.address,
    this.date, this.description, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      color: Colors.white,
      height: 300,
      width: 150,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Text(
                  office,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  address,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(date),
                const SizedBox(height: 10),
                Text(description),
                const SizedBox(height: 10),
                const Text("[Attribut]"), //TODO ska vi har kvar detta?
                const SizedBox(height: 10),
                const Text("Seats remaining: 10"), //TODO ska vi har kvar detta?
                const SizedBox(height: 10),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
