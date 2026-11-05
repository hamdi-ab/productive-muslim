import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ArabicFontFamily {
  amiri('amiri', 'Amiri (Traditional Naskh)', 'أميري - النسخ الأصيل'),
  scheherazadeNew(
    'scheherazadeNew',
    'Scheherazade (Uthmanic Style)',
    'شهرزاد - خط المصحف',
  ),
  notoNaskhArabic(
    'notoNaskhArabic',
    'Noto Naskh (Clean & Crisp)',
    'نوتو نسخ - واضح وحديث',
  ),
  cairo('cairo', 'Cairo (Modern Geometric)', 'كايرو - خط عصري'),
  arefRuqaa(
    'arefRuqaa',
    'Aref Ruqaa (Artistic Calligraphy)',
    'عارف رقعة - خط الرقعة الفني',
  );

  final String key;
  final String labelEn;
  final String labelAr;

  const ArabicFontFamily(this.key, this.labelEn, this.labelAr);

  static ArabicFontFamily fromKey(String? key) {
    return ArabicFontFamily.values.firstWhere(
      (f) => f.key == key,
      orElse: () => ArabicFontFamily.amiri,
    );
  }

  TextStyle getTextStyle({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double height = 1.8,
  }) {
    switch (this) {
      case ArabicFontFamily.amiri:
        return GoogleFonts.amiri(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case ArabicFontFamily.scheherazadeNew:
        return GoogleFonts.scheherazadeNew(
          fontSize: fontSize * 1.05,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case ArabicFontFamily.notoNaskhArabic:
        return GoogleFonts.notoNaskhArabic(
          fontSize: fontSize * 0.95,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
      case ArabicFontFamily.cairo:
        return GoogleFonts.cairo(
          fontSize: fontSize * 0.90,
          fontWeight: fontWeight,
          color: color,
          height: height * 0.95,
        );
      case ArabicFontFamily.arefRuqaa:
        return GoogleFonts.arefRuqaa(
          fontSize: fontSize * 1.05,
          fontWeight: fontWeight,
          color: color,
          height: height,
        );
    }
  }
}
