import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SavedRide {
  final String id;
  final String from;
  final String to;
  final String time;
  final String price;
  final String stationsCount;
  final String line;
  final String transferStation;
  final DateTime date;

  SavedRide({
    required this.id,
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    required this.stationsCount,
    required this.line,
    required this.transferStation,
    required this.date,
  });

  factory SavedRide.fromJson(Map<String, dynamic> json) {
    return SavedRide(
      id: json['id'],
      from: json['from'],
      to: json['to'],
      time: json['time'],
      price: json['price'],
      stationsCount: json['stationsCount'],
      line: json['line'],
      transferStation: json['transferStation'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'time': time,
      'price': price,
      'stationsCount': stationsCount,
      'line': line,
      'transferStation': transferStation,
      'date': date.toIso8601String(),
    };
  }
}

class RidesController extends GetxController {
  final savedRides = <SavedRide>[].obs;
  final _storage = GetStorage();
  final String _storageKey = 'savedRides';

  @override
  void onInit() {
    super.onInit();
    _loadRides();
  }

  void _loadRides() {
    final List<dynamic>? storedRides = _storage.read<List<dynamic>>(_storageKey);
    if (storedRides != null && storedRides.isNotEmpty) {
      savedRides.assignAll(storedRides.map((e) => SavedRide.fromJson(e)).toList());
    } else {
      // Populate dummy initial recent rides for a great first experience
      savedRides.addAll([
        SavedRide(
          id: '1',
          from: 'Helwan',
          to: 'Sadat',
          time: '36 minutes',
          price: '15 Pounds',
          stationsCount: '18',
          line: 'Line 1',
          transferStation: 'None',
          date: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        SavedRide(
          id: '2',
          from: 'Attaba',
          to: 'Cairo University',
          time: '18 minutes',
          price: '10 Pounds',
          stationsCount: '9',
          line: 'Line 2 -> Line 3',
          transferStation: 'Attaba',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
      _saveRides();
    }
  }

  void _saveRides() {
    _storage.write(_storageKey, savedRides.map((e) => e.toJson()).toList());
  }

  void addRide({
    required String from,
    required String to,
    required String time,
    required String price,
    required String stationsCount,
    required String line,
    required String transferStation,
  }) {
    // Avoid duplicate immediately identical top ride
    if (savedRides.isNotEmpty &&
        savedRides.first.from == from &&
        savedRides.first.to == to) {
      return;
    }

    savedRides.insert(
      0,
      SavedRide(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        from: from,
        to: to,
        time: time,
        price: price,
        stationsCount: stationsCount,
        line: line,
        transferStation: transferStation,
        date: DateTime.now(),
      ),
    );
    _saveRides();
  }

  void removeRide(String id) {
    savedRides.removeWhere((ride) => ride.id == id);
    _saveRides();
  }

  void clearAllRides() {
    savedRides.clear();
    _saveRides();
  }
}
