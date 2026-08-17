import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _themeKey = 'isDarkMode';

  late final RxBool isDarkMode;

  @override
  void onInit() {
    super.onInit();
    // Load saved theme preference or default to false
    isDarkMode = (_storage.read<bool>(_themeKey) ?? false).obs;
  }

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool isDark) {
    isDarkMode.value = isDark;
    _storage.write(_themeKey, isDark);
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.dark) {
      isDarkMode.value = true;
      _storage.write(_themeKey, true);
      Get.changeThemeMode(ThemeMode.dark);
    } else if (mode == ThemeMode.light) {
      isDarkMode.value = false;
      _storage.write(_themeKey, false);
      Get.changeThemeMode(ThemeMode.light);
    } else {
      isDarkMode.value = Get.isPlatformDarkMode;
      _storage.remove(_themeKey);
      Get.changeThemeMode(ThemeMode.system);
    }
  }
}
