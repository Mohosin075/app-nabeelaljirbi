import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';

TextStyle globalTextStyle({
  double fontSize = 16.0,
  FontWeight fontWeight = FontWeight.normal,
  double lineHeight = 1.5,
  TextAlign textAlign = TextAlign.center,
  Color color = AppColors.darkTextColor,
  TextDecoration? decoration,
  double letterSpacing = 0.0,
}) {
  return GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: lineHeight,
    color: color,
    decoration: decoration,
    letterSpacing: letterSpacing,
  );
}
