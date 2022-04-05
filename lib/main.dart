import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Room Booking',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Room Booking'),
        ),
        body: const Center(
          child: Text('Goodbye Gruesome World!'),
        ),
      ),
    );
  }
}