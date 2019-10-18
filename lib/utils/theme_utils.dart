import 'dart:ui';

import 'package:flutter/material.dart';

class ThemeUtils {
  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
}
