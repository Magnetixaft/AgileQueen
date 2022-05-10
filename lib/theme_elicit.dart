// import 'package:flutter/material.dart';

// ThemeData elicitTheme() {
//   Color elicitWhite = const Color(0xFFFFFFFF);
//   Color elicitGreen = const Color.fromRGBO(9, 158, 99, 1);
//   Color elicitGrey = const Color.fromRGBO(112, 112, 112, 1);

//   return ThemeData(
//     // Define the default brightness and colors.
//     brightness: Brightness.light,
//     primarySwatch: createMaterialColor(elicitGreen),
//     primaryColor: elicitGreen,

//     // Scaffold theme
//     scaffoldBackgroundColor: elicitWhite,

//     // Appbar theme
//     appBarTheme: AppBarTheme(
//       backgroundColor: elicitWhite,
//       foregroundColor: Colors.black,
//       elevation: 0.0, // To match mockup
//     ),

//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         fixedSize: const Size(double.maxFinite, 50),
//       ),
//     ),

//     // fontFamily: 'Georgia', // TODO choose font

//     //textTheme: const TextTheme(
//     //  headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//     //  headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//     //  bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//     //),
//   );
// }

// // Taken from https://medium.com/@nickysong/creating-a-custom-color-swatch-in-flutter-554bcdcb27f3
// MaterialColor createMaterialColor(Color color) {
//   List strengths = <double>[.05];
//   Map<int, Color> swatch = {};
//   final int r = color.red, g = color.green, b = color.blue;

//   for (int i = 1; i < 10; i++) {
//     strengths.add(0.1 * i);
//   }
//   for (var strength in strengths) {
//     final double ds = 0.5 - strength;
//     swatch[(strength * 1000).round()] = Color.fromRGBO(
//       r + ((ds < 0 ? r : (255 - r)) * ds).round(),
//       g + ((ds < 0 ? g : (255 - g)) * ds).round(),
//       b + ((ds < 0 ? b : (255 - b)) * ds).round(),
//       1,
//     );
//   }
//   return MaterialColor(color.value, swatch);
// }
