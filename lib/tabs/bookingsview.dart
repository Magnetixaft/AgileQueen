import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingsView extends StatelessWidget {
  BookingsView({Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                pushData();
              },
              child: const Text("Book now"),
            ),
          ]),
    );
  }

  //Push data generated from inputfields.
  Future pushData() async {
    await FirebaseFirestore.instance.collection("Test").doc("andreas")
        .update({'numberOfBookings': FieldValue.increment(1)});
  }

}
