import 'package:flutter/material.dart';

//This class represents the detailed my bookings view. 
class DetailedView extends StatelessWidget {
  const DetailedView({Key? key}) : super(key: key);

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
            child: 
              ListView(
              scrollDirection: Axis.vertical,
              children: const <Widget>[
                Text(
                  "Kontor",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                Text(
                  "Adress",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 10),
                Text("Datum"),
                SizedBox(height: 10),
                Text("Rumsbeskrivning, med lorem ipsum Lorem ipsum dolor sit amet consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
                SizedBox(height: 10),
                Text("[Attribut]"),
                SizedBox(height: 10),
                Text("Seats remaining: 10"),
                SizedBox(height: 10),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

}
