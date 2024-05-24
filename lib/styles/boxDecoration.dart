import 'package:flutter/material.dart';

BoxDecoration buildBoxDecoration({
  required double borderRadius,
  required Color borderColor,
  required Color focusedBorderColor,
  required Color backgroundColor,
}) {
  return BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: borderColor,
      width: 1.0,
    ),
  );
}

BoxDecoration buildFocusedBoxDecoration({
  required double borderRadius,
  required Color borderColor,
  required Color focusedBorderColor,
  required Color backgroundColor,
}) {
  return BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: focusedBorderColor,
      width: 2.0,
    ),
  );
}
