import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'station.dart';
import 'stations_data.dart';
import 'logic.dart';
import 'rides_controller.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  List<String>? _route;
  Map<String, dynamic> _details = {};
  Map<String, List<String>> _stationLinesMap = {};
  Map<String, dynamic> _args = {};
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _args = Get.arguments ?? {};
      final fromStationName = _args['from'] ?? '';
      final toStationName = _args['to'] ?? '';
      final ageStr = _args['age']?.toString() ?? '0';
      final disabledStr = _args['disabled'] ?? 'no';

      _stationLinesMap = getStationLinesMap(metroLines);
      final graph = buildGraph(metroLines);
      _route = findShortestPath(graph, metroLines, fromStationName, toStationName);
      _details = getDetails(
        _route,
        metroLines,
        fromStationName,
        toStationName,
        int.tryParse(ageStr) ?? 0,
        disabledStr,
      );

      // Automatically save ride to RidesController
      if (_route != null && fromStationName.isNotEmpty && toStationName.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isRegistered<RidesController>()) {
            Get.find<RidesController>().addRide(
              from: fromStationName,
              to: toStationName,
              time: _details["Time"] ?? "--",
              price: _details["Ticket Price"] ?? "--",
              stationsCount: _details["Stations Count"] ?? "0",
              line: _details["Lines"] ?? "Unknown",
              transferStation: _details["Transfer Station"] ?? "None",
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: Text(
          'trip_details'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2D3748),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: _route == null 
        ? Center(
            child: Text(
              'no_route_found'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          )
        : Column(
        children: [
          _buildHeaderSection(_args, _details, isDark),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTripInformationSection(_details, isDark),
                  const SizedBox(height: 24),
                  _buildRouteStationsSection(_route!, metroLines, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> args, Map<String, dynamic> details, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFromToRow(args),
          const SizedBox(height: 24),
          _buildSummaryCards(details, isDark),
        ],
      ),
    );
  }

  Widget _buildFromToRow(Map<String, dynamic> args) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'departure'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (args['from'] ?? '').toString().tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'destination'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (args['to'] ?? '').toString().tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> details, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard(
          icon: Icons.access_time_rounded,
          value: details["Time"] ?? "--",
          label: 'duration'.tr,
          color: Colors.blue[100]!,
          iconColor: Colors.blue[800]!,
          isDark: isDark,
        ),
        _buildSummaryCard(
          icon: Icons.directions_subway_rounded,
          value: details["Stations Count"] ?? "--",
          label: 'stations'.tr,
          color: Colors.purple[100]!,
          iconColor: Colors.purple[800]!,
          isDark: isDark,
        ),
        _buildSummaryCard(
          icon: Icons.attach_money_rounded,
          value: details["Ticket Price"] ?? "--",
          label: 'price'.tr,
          color: Colors.green[100]!,
          iconColor: Colors.green[800]!,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }

  String _generateTripDescription(Map<String, dynamic> details, Map<String, dynamic> args) {
    String lang = Get.locale?.languageCode ?? 'en';
    final lines = (details["Lines"] ?? "").toString().split(" -> ");
    final dirs = (details["Direction"] ?? "").toString().split(" then ");
    final transfersStr = details["Transfer Station"]?.toString() ?? "none";
    final List<String> transfers = (transfersStr == "None" || transfersStr.toLowerCase() == "none") 
        ? <String>[] 
        : transfersStr.split(", ");

    if (lines.isEmpty || lines[0] == "Unknown" || lines[0].isEmpty) {
      return 'no_route_found'.tr;
    }

    if (lang == 'ar') {
      // Egyptian Arabic
      String desc = "هتركب ${lines[0].tr} اتجاه ${dirs[0].split(' / ').map((e) => e.tr).join(' / ')}";
      
      for (int i = 0; i < transfers.length; i++) {
        if (i + 1 < lines.length && i + 1 < dirs.length) {
          desc += " وهتحول من محطة ${transfers[i].tr} لـ ${lines[i + 1].tr} اتجاه ${dirs[i + 1].split(' / ').map((e) => e.tr).join(' / ')}";
        }
      }
      return desc;
    } else {
      // English
      String desc = "You will take ${lines[0].tr} towards ${dirs[0].split(' / ').map((e) => e.tr).join(' / ')}";
      
      for (int i = 0; i < transfers.length; i++) {
        if (i + 1 < lines.length && i + 1 < dirs.length) {
          desc += " and transfer at ${transfers[i].tr} to ${lines[i + 1].tr} towards ${dirs[i + 1].split(' / ').map((e) => e.tr).join(' / ')}";
        }
      }
      return desc;
    }
  }

  Widget _buildTripInformationSection(Map<String, dynamic> details, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'your_trip_details'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _generateTripDescription(details, _args),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildRouteStationsSection(List<String> route, Map<String, List<Station>> metroLines, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'route_stations'.tr,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.list_rounded, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'stations_list'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              ..._buildRouteList(route, metroLines, isDark),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRouteList(List<String> route, Map<String, List<Station>> metroLines, bool isDark) {
    return List.generate(route.length, (index) {
      final station = route[index];
      final linesList = _stationLinesMap[station] ?? [];
      final linesForStation = linesList.join(' / ');
      final isTransfer = index != 0 && index != route.length - 1 && linesList.length > 1;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: index == route.length - 1
                ? BorderSide.none
                : BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                  ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getStationColor(index, route.length),
                shape: BoxShape.circle,
              ),
              child: index == 0
                  ? const Icon(Icons.flag_rounded, color: Colors.white, size: 18)
                  : index == route.length - 1
                      ? const Icon(Icons.location_on_rounded, color: Colors.white, size: 18)
                      : Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    linesForStation,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isTransfer)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50]!.withOpacity(isDark ? 0.2 : 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'transfer'.tr,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.orange[300] : Colors.orange[800],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Color _getStationColor(int index, int total) {
    if (index == 0) return Colors.green;
    if (index == total - 1) return Colors.red;
    return Colors.blue;
  }

  Color getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'yellow':
        return Colors.yellow[600]!;
      case 'green':
        return Colors.green[600]!;
      case 'pink':
        return Colors.pink[400]!;
      case 'beige':
        return const Color(0xFFD2B48C);
      case 'red':
        return Colors.red[600]!;
      case 'blue':
        return Colors.blue[600]!;
      default:
        return Colors.grey;
    }
  }
}