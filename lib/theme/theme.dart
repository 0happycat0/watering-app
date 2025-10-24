import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme,
  // splashFactory: NoSplash.splashFactory,
  textTheme: GoogleFonts.robotoTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      splashFactory: NoSplash.splashFactory,
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      splashFactory: NoSplash.splashFactory,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    splashColor: Colors.transparent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        width: 1.8,
        color: Color.fromARGB(123, 0, 0, 0),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        width: 1.8,
        color: Color.fromARGB(123, 0, 0, 0),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        width: 2.4,
        color: Color.fromARGB(255, 95, 196, 75),
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        width: 1.8,
        color: Color.fromARGB(255, 211, 80, 102),
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        width: 2.4,
        color: Color.fromARGB(255, 211, 80, 102),
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        width: 1.8,
        color: Color.fromARGB(255, 208, 208, 208),
      ),
    ),
    errorStyle: TextStyle(fontSize: 14),
  ),
  snackBarTheme: SnackBarThemeData().copyWith(
    elevation: 0,
    behavior: SnackBarBehavior.fixed,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(12),
    ),
  ),
);

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color.fromARGB(255, 91, 145, 59),
).copyWith(surface: Colors.white);
