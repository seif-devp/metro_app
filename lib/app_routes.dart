import 'package:get/get.dart';
import 'start_page.dart';
import 'main_navigation_page.dart';
import 'details_page.dart';
import 'lottie_splash_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String start = '/start';
  static const String main = '/main';
  static const String details = '/details';

  static final pages = [
    GetPage(
      name: splash,
      page: () => const LottieSplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: start,
      page: () => const StartPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: main,
      page: () => const MainNavigationPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: details,
      page: () => const DetailsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
