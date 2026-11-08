import 'package:flutter/material.dart';

import '../models/facility.dart';

class AppColors {
  static const primary = Color(0xFF1E5EFF);
  static const primaryLight = Color(0xFFE8EFFF);
  static const green = Color(0xFF2EAA5B);
  static const red = Color(0xFFE5484D);
  static const orange = Color(0xFFF5A524);
  static const text = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const background = Color(0xFFF7F8FA);
}

Color typeColor(FacilityType t) {
  switch (t) {
    case FacilityType.rumahSakit:
      return AppColors.red;
    case FacilityType.puskesmas:
      return AppColors.green;
    case FacilityType.klinik:
      return AppColors.primary;
  }
}

IconData typeIcon(FacilityType t) {
  switch (t) {
    case FacilityType.rumahSakit:
      return Icons.local_hospital;
    case FacilityType.puskesmas:
      return Icons.health_and_safety;
    case FacilityType.klinik:
      return Icons.medical_services;
  }
}

IconData serviceIcon(String service) {
  switch (service) {
    case 'Poliklinik':
      return Icons.medical_services_outlined;
    case 'IGD':
      return Icons.emergency_outlined;
    case 'Rawat Inap':
      return Icons.bed_outlined;
    case 'Laboratorium':
      return Icons.science_outlined;
    case 'Radiologi':
      return Icons.monitor_heart_outlined;
    case 'Farmasi':
      return Icons.local_pharmacy_outlined;
    case 'Rehabilitasi':
      return Icons.accessibility_new;
    case 'Umum':
      return Icons.people_outline;
    case 'KIA':
      return Icons.child_care;
    case 'Imunisasi':
      return Icons.vaccines_outlined;
    case 'Gigi':
      return Icons.sentiment_satisfied_alt_outlined;
    default:
      return Icons.healing_outlined;
  }
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: null,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
  );
}
