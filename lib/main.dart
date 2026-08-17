import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_routes.dart';
import 'theme_controller.dart';
import 'rides_controller.dart';
import 'language_controller.dart';
import 'app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(RidesController());
  Get.put(LanguageController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'app_title'.tr,
          translations: AppTranslations(),
          locale: languageController.currentLocale.value,
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.pages,
          themeMode: themeController.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xFF4F46E5),
            scaffoldBackgroundColor: const Color(0xFFF8FAFD),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2D3748),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFF4F46E5),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ));
  }
}
