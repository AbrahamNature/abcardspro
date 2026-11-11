import 'package:flutter/material.dart';
import '../theme/palette.dart';

OutlineInputBorder _border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );

InputDecoration appInput(String label, {String? hint, Widget? suffix}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffix,
    filled: true,
    fillColor: Palette.surface,
    labelStyle: const TextStyle(color: Palette.muted),
    hintStyle: const TextStyle(color: Palette.line),
    border: _border(Palette.line),
    enabledBorder: _border(Palette.line),
    focusedBorder: _border(Palette.marigold),
    errorBorder: _border(Palette.rose),
    focusedErrorBorder: _border(Palette.rose),
    errorStyle: const TextStyle(color: Palette.rose),
  );
}