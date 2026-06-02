import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary – HeroUI blue #0080FF
  static const Color primary = Color(0xFF0080FF);
  static const Color primary50 = Color(0xFFE6F1FF);
  static const Color primary100 = Color(0xFFCCE3FF);
  static const Color primary200 = Color(0xFF99C8FF);
  static const Color primary300 = Color(0xFF66ACFF);
  static const Color primary400 = Color(0xFF3391FF);
  static const Color primary500 = Color(0xFF0080FF);
  static const Color primary600 = Color(0xFF0066CC);
  static const Color primary700 = Color(0xFF004D99);
  static const Color primary800 = Color(0xFF003366);
  static const Color primary900 = Color(0xFF001A33);

  // Secondary – HeroUI orange #F1611D
  static const Color secondary = Color(0xFFF1611D);
  static const Color secondary50 = Color(0xFFFEF0E9);
  static const Color secondary100 = Color(0xFFFDE0D3);
  static const Color secondary200 = Color(0xFFFBC1A7);
  static const Color secondary300 = Color(0xFFF9A17B);
  static const Color secondary400 = Color(0xFFF5824F);
  static const Color secondary500 = Color(0xFFF1611D);
  static const Color secondary600 = Color(0xFFC14E17);
  static const Color secondary700 = Color(0xFF913B11);
  static const Color secondary800 = Color(0xFF60270B);
  static const Color secondary900 = Color(0xFF301306);

  // Semantic
  static const Color success = Color(0xFF17C964);
  static const Color success50 = Color(0xFFE8FAF0);
  static const Color successForeground = Color(0xFF166534);

  static const Color warning = Color(0xFFF5A524);
  static const Color warning50 = Color(0xFFFEF6E7);
  static const Color warningForeground = Color(0xFF92400E);

  static const Color danger = Color(0xFFF31260);
  static const Color danger50 = Color(0xFFFEE7F0);
  static const Color dangerForeground = Color(0xFF9B1239);

  // Light surface & neutrals (HeroUI light)
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF11181C);
  static const Color content1 = Color(0xFFFFFFFF);
  static const Color content2 = Color(0xFFF4F4F5);
  static const Color content3 = Color(0xFFE4E4E7);
  static const Color content4 = Color(0xFFD4D4D8);
  static const Color defaultGray = Color(0xFF71717A);
  static const Color divider = Color(0xFFF4F4F5);
  static const Color focus = Color(0xFF0080FF);

  // Gray scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray300 = Color(0xFFD4D4D8);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray500 = Color(0xFF71717A);
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray700 = Color(0xFF3F3F46);
  static const Color gray800 = Color(0xFF27272A);
  static const Color gray900 = Color(0xFF18181B);

  // Dark surface & neutrals (HeroUI dark)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkForeground = Color(0xFFECEDEE);
  static const Color darkContent1 = Color(0xFF18181B);
  static const Color darkContent2 = Color(0xFF27272A);
  static const Color darkContent3 = Color(0xFF3F3F46);
  static const Color darkContent4 = Color(0xFF52525B);
  static const Color darkDivider = Color(0xFF27272A);
}
