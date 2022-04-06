import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseDemoView extends StatelessWidget {
  FirebaseDemoView({Key? key}) : super(key: key);
  
  //Controllers for input fields
  TextEditingController firstController = TextEditingController();
  TextEditingController secondController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget> [
              Container(
                width: 200,
                child: TextField(
                  controller: firstController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter first',
                  ),
                ),

              ),
              Container(
                width: 200,
                child: TextField(
                  controller: secondController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter second',
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  pushData(firstController.text, secondController.text);
                }, child: Text("Submitta datan"),
              ),

              ElevatedButton(
                onPressed: () {
                  print(getDoc());
                }, child: Text("Kolla datan"),
              ),
            ]
        ),
    );
  }

  //Push data generated from inputfields.
  Future pushData(String first, String second) async {
    await FirebaseFirestore.instance.collection("Test").doc("test").set({
      'test1': first,
      'test2': second
    });
  }
  //Gets all docs under "Test" and prints data from every doc.
  Future getDoc() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("Test").get();
    for(int i= 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      print(a.data());
    }

    /* Checks if path exists.

    var documentPath = FirebaseFirestore.instance.collection('Test').doc(
        "test");
    var docTest = await documentPath.get();
    if (docTest.exists) {
      print('Exists');
      print(docTest
          .data()
          ?.keys);
      await docTest;
    }
    if (!docTest.exists) {
      print('Not exists');
      return null;
    }

     */
  }

}