import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'nav_map'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F172A) : Colors.grey[200],
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          constrained: false, // Allows image to be larger than screen and panning
          boundaryMargin: const EdgeInsets.all(100), // Gives some padding when panning around
          child: Image.asset(
            'assets/images/map.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
