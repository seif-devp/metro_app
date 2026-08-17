import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final _storage = GetStorage();
  final currentLocale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguageFromStorage();
  }

  void _loadLanguageFromStorage() {
    String? langCode = _storage.read('languageCode');
    if (langCode == 'ar') {
      currentLocale.value = const Locale('ar', 'EG');
    } else {
      currentLocale.value = const Locale('en', 'US');
    }
  }

  bool get isArabic => currentLocale.value.languageCode == 'ar';

  void changeLanguage(String langCode) {
    _storage.write('languageCode', langCode);
    if (langCode == 'ar') {
      currentLocale.value = const Locale('ar', 'EG');
      Get.updateLocale(const Locale('ar', 'EG'));
    } else {
      currentLocale.value = const Locale('en', 'US');
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}
