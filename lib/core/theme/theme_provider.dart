import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _load();
  }

  void _load() {
    state = LocalStorageService.isDarkMode()
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;

    state = isDark ? ThemeMode.light : ThemeMode.dark;

    await LocalStorageService.saveThemeMode(!isDark);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider =
StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});