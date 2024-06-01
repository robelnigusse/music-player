// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

our_style({family = 'regular', double? size = 14, color = Colors.white}) {
  return TextStyle(
    fontSize: size,
    color: color,
    fontFamily: family,
  );
}
