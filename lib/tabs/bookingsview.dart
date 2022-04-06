import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';

class BookingsView extends StatelessWidget {
  const BookingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO fetch data from firebase
    return Column(
      children: [
        Card(
          color: elicitGreen,
          child: InkWell(
            onTap: () {
              print("tapped");
            },
            child: const SizedBox(
              height: 100,
              width: 300,
              child: Text("Room 1"),
            ),
          ),
        ),
        Card(
          color: elicitGreen,
          child: InkWell(
            onTap: () {
              print("tapped");
            },
            child: const SizedBox(
              height: 100,
              width: 300,
              child: Text("Room 2"),
            ),
          ),
        ),
      ],
    );
  }
}
