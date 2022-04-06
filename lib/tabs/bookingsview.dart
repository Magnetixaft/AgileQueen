import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';

class BookingsView extends StatelessWidget {
  BookingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        color: elicitGreen,
        child: SizedBox(
          height: 400,
          width: 400,
          child: ElevatedButton(
            onPressed: () {
              pushData();
            },
            child: const Text("Book now"),
          ),
        ),
      ),
    );
  }

  //Push data generated from inputfields.
  Future pushData() async {
    await FirebaseFirestore.instance
        .collection("Test")
        .doc("andreas")
        .update({'numberOfBookings': FieldValue.increment(1)});
  }
}
