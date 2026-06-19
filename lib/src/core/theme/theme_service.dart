import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../modules/home/controllers/home_controller.dart';

class ThemeService {
  final GetStorage _box = GetStorage();
  final String _key = 'isDarkMode';

  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  void _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  void switchTheme() {
    bool isDarkMode = _loadThemeFromBox();
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!isDarkMode);

    // Automatically reload news when theme changes
    if (Get.isRegistered<HomeController>()) {
      final controller = Get.find<HomeController>();
      controller.fetchNews(controller.selectedCategory.value);
    }
  }
}
