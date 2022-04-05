import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
        apiKey: "AIzaSyD71VJDiqwq5e2y7gpaszs4um91jR6tN1g",
        authDomain: "agilequeen-82096.firebaseapp.com",
        projectId: "agilequeen-82096",
        storageBucket: "agilequeen-82096.appspot.com",
        messagingSenderId: "883336254219",
        appId: "1:883336254219:web:7d2de78527260bb27e080e")
    );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garveriet',
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            print("Error");
          }
          if(snapshot.connectionState == ConnectionState.done){
            print("Det funkarde");
            return MyHomePage(title: "Testuing");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  TextEditingController firstController = TextEditingController();
  TextEditingController secondController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget> [
              Container(
                width: 200,
                child: TextField(
                  controller: firstController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter first',
                  ),
                ),

              ),
              Container(
                width: 200,
                child: TextField(
                  controller: secondController,
                  decoration: InputDecoration(
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
      )
    );
  }
  Future pushData(String first, String second) async {
    await FirebaseFirestore.instance.collection("Test").doc("test").set({
      'test1': first,
      'test2': second
    });
  }
  Future getDoc() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("Test").get();
    for(int i= 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      print(a.data());
    }

    /* Kollar om en path finns

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



