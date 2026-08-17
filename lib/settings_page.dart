import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme_controller.dart';
import 'rides_controller.dart';
import 'language_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final ridesController = Get.find<RidesController>();
    final languageController = Get.find<LanguageController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'nav_settings'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // Section: Appearance
          _buildSectionTitle(context, 'appearance'.tr),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                      value: themeController.isDarkMode.value,
                      onChanged: (value) {
                        themeController.toggleTheme(value);
                      },
                      title: Text(
                        'dark_mode'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'dark_mode_sub'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          themeController.isDarkMode.value
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                      activeColor: const Color(0xFF4F46E5),
                    )),
                Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                Obx(() => ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.language_rounded, color: Colors.orange),
                      ),
                      title: Text(
                        'language'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        languageController.isArabic ? 'arabic'.tr : 'english'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ChoiceChip(
                            label: const Text('EN'),
                            selected: !languageController.isArabic,
                            onSelected: (selected) {
                              if (selected) languageController.changeLanguage('en');
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('عربي'),
                            selected: languageController.isArabic,
                            onSelected: (selected) {
                              if (selected) languageController.changeLanguage('ar');
                            },
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section: Travel Preferences
          _buildSectionTitle(context, 'preferences'.tr),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_city_rounded, color: Colors.blue),
                  ),
                  title: Text(
                    'default_network'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text('cairo_network_sub'.tr),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section: Data & History
          _buildSectionTitle(context, 'clear_history_title'.tr),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: Text('clear_all_rides'.tr),
                    content: Text('clear_rides_confirm'.tr),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('cancel'.tr),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          ridesController.clearAllRides();
                          Get.back();
                        },
                        child: Text(
                          'clear'.tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              ),
              title: Text(
                'clear_all_rides'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
              subtitle: Text('remove_all_history'.tr),
            ),
          ),

          const SizedBox(height: 28),

          // Section: About & Info
          _buildSectionTitle(context, 'about_app'.tr),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.purple),
                  ),
                  title: Text(
                    'app_version'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_outline_rounded, color: Colors.amber),
                  ),
                  title: Text(
                    'rate_app'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          Center(
            child: Text(
              'metro_companion_desc'.tr,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }
}

