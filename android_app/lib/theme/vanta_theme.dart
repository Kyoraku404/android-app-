import 'package:flutter/material.dart';

class VantaTheme {
  static const bg = Color(0xFF0B0E14);
  static const red = Color(0xFFFF4655);
  static const neon = Color(0xFF00F5D4);

  static final theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(primary: red, secondary: neon),
  );
}
