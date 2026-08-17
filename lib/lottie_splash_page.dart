import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'app_routes.dart';

class LottieSplashPage extends StatefulWidget {
  const LottieSplashPage({super.key});

  @override
  State<LottieSplashPage> createState() => _LottieSplashPageState();
}

class _LottieSplashPageState extends State<LottieSplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed(AppRoutes.start);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Lottie.asset(
            'assets/images/Namma Metro.json',
            fit: BoxFit.contain,
            repeat: false, // Play once or let it loop if it's less than 3s
          ),
        ),
      ),
    );
  }
}
