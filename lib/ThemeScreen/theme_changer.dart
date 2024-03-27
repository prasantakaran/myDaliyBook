// import 'package:flutter/material.dart';

// class Styles {
//   static ThemeData themeData(BuildContext context, bool isDarkTheme) {
//     return ThemeData(
//         appBarTheme: AppBarTheme(),
//         textTheme: TextTheme(
//           // ignore: deprecated_member_use
//           bodyText2: TextStyle(
//             color: isDarkTheme ? Colors.white : Colors.black,
//           ),
//         ),
//         scaffoldBackgroundColor:
//             isDarkTheme ? Color(0xFF00001a) : Color(0xFFFFFFFF),
//         primaryColor: Colors.blue,
//         colorScheme: ThemeData().colorScheme.copyWith(
//             secondary: isDarkTheme ? Color(0xFF1a1f3c) : Color(0xFFE8FDFD),
//             brightness: isDarkTheme ? Brightness.dark : Brightness.light),
//         cardColor: isDarkTheme ? Color(0xFF0a0d2c) : Color(0xFFF2FFDFD),
//         canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
//         buttonTheme: Theme.of(context).buttonTheme.copyWith(
//             buttonColor: isDarkTheme ? Colors.green : Colors.pink,
//             colorScheme:
//                 isDarkTheme ? ColorScheme.dark() : ColorScheme.light()));
//   }
// }

import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepPurple,
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.cyan,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    centerTitle: true,
  ),
  colorScheme: const ColorScheme.light(
    background: Colors.white, // for scaffoldBackgroundColor
    onBackground: Colors.black, // for text color
    primary: Colors.cyan, // for appbar background color
    onPrimary: Colors.black, // for appbar text color
    surface: Colors.white, // for card background color
    onSurface: Colors.black, // for card text color
    // secondary: buttonColor, // for button background color
    // onSecondary: lightColor, // for button text color
    onError: Colors.red, // for error text color
    error: Color(0xffffffff), // for error background color
    primaryContainer: Colors.white, // for container background color
    secondaryContainer: Colors.cyan, // for container background color
    onPrimaryContainer: Colors.black, // for container text color
    onSecondaryContainer: Colors.black, // for container text color
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.deepOrange,
  useMaterial3: true,
  scaffoldBackgroundColor: Color(0xff242424),
  // inputDecorationTheme: InputDecorationTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[800],
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    centerTitle: true,
  ),
  colorScheme: const ColorScheme.dark(
    background: Color(0xff242424), // for scaffoldBackgroundColor
    onBackground: Colors.white, // for text color
    primary: Colors.deepPurple, // for appbar background color
    onPrimary: Colors.white, // for appbar text color
    surface: Color(0xff373737), // for card background color
    onSurface: Colors.white, // for card text color
    secondary: Colors.white, // for button background color
    onSecondary: Color(0xff000000), // for button text color
    onError: Colors.red, // for error text color
    error: Color(0xff373737), // for error background color
    primaryContainer: Color(0xff373737), // for container background color
    secondaryContainer: Color(0xff373737), // for container background color
    onPrimaryContainer: Colors.white, // for container text color
    onSecondaryContainer: Colors.white, // for container text color
  ),
);
