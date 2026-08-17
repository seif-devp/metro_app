import 'dart:collection';
import 'station.dart';

Map<String, List<Station>>? _cachedGraph;
Map<String, List<String>>? _cachedStationLinesMap;

Map<String, List<String>> getStationLinesMap(Map<String, List<Station>> lines) {
  if (_cachedStationLinesMap != null) return _cachedStationLinesMap!;
  final map = <String, List<String>>{};
  for (var entry in lines.entries) {
    for (var station in entry.value) {
      map.putIfAbsent(station.name, () => []).add(entry.key);
    }
  }
  _cachedStationLinesMap = map;
  return map;
}

Map<String, dynamic> getDetails(
  List<String>? route,
  Map<String, List<Station>> metroLines,
  String from,
  String to,
  int age,
  String disabled,
) {
  // حماية في حالة عدم وجود مسار
  if (route == null || route.isEmpty) {
    return {
      "Direction": "Unknown",
      "Stations Count": "0",
      "Time": "0 minutes",
      "Ticket Price": "0 Pounds",
      "Route": "",
      "Lines": "Unknown",
      "Transfer Station": "None",
      "Color": "grey",
    };
  }

  List<String> usedLines = [];
  List<String> transferStations = [];
  List<String> directions = [];

  String? currentLine;
  String? currentDirectionTerminal;

  final stationLinesMap = getStationLinesMap(metroLines);

  // دالة مساعدة لمعرفة الخط المشترك بين محطتين متتاليتين
  List<String> getCommonLines(String s1, String s2) {
    List<String> s1Lines = stationLinesMap[s1] ?? [];
    List<String> s2Lines = stationLinesMap[s2] ?? [];
    return s1Lines.where((l) => s2Lines.contains(l)).toList();
  }

  String getDirectionTerminal(String line, String sStart, String sNext) {
    List<Station> stations = metroLines[line] ?? [];
    int idx1 = stations.indexWhere((s) => s.name == sStart);
    int idx2 = stations.indexWhere((s) => s.name == sNext);
    if (idx1 == -1 || idx2 == -1) return "Unknown";
    
    if (idx2 > idx1) {
      // Forward direction
      if (line == "Line 3 Main") return "Rod El Farag Corridor / Cairo University";
      return stations.last.name;
    } else {
      // Backward direction
      if (line == "Line 3 Branch 1" || line == "Line 3 Branch 2") return "Adly Mansour";
      return stations.first.name;
    }
  }

  // تتبع المسار لاكتشاف خطوط النقل والاتجاهات
  for (int i = 0; i < route.length - 1; i++) {
    String s1 = route[i];
    String s2 = route[i + 1];
    List<String> commonLines = getCommonLines(s1, s2);

    if (currentLine == null) {
      if (commonLines.isNotEmpty) {
        currentLine = commonLines.first;
        usedLines.add(currentLine);
        currentDirectionTerminal = getDirectionTerminal(currentLine, s1, s2);
      }
    } else if (!commonLines.contains(currentLine)) {
      // تم اكتشاف تغيير في الخط (تبديل)
      if (currentDirectionTerminal != null) {
        directions.add(currentDirectionTerminal);
      }
      transferStations.add(s1);

      if (commonLines.isNotEmpty) {
        currentLine = commonLines.first;
        usedLines.add(currentLine);
        currentDirectionTerminal = getDirectionTerminal(currentLine, s1, s2);
      }
    }
  }
  
  // إضافة اتجاه الجزء الأخير من الرحلة
  if (currentDirectionTerminal != null) {
    directions.add(currentDirectionTerminal);
  }

  int count = route.length - 1;

  return {
    "Direction": directions.join(' then '),
    "Stations Count": "$count",
    "Time": "${count * 2} minutes",
    "Ticket Price": "${calculatePrice(count, age: age, disabled: disabled)} Pounds",
    "Route": route.join(' -> '),
    "Lines": usedLines.join(' -> '),
    "Transfer Station": transferStations.isEmpty ? "None" : transferStations.join(', '),
    "Color": color(count),
  };
}

int calculatePrice(int count, {int age = 0, String disabled = 'no'}) {
  int price;
  if (disabled == 'yes') {
    return 5;
  }
  
  if (count <= 9) {
    price = 10;
  } else if (count <= 16) {
    price = 12;
  } else if (count <= 23) {
    price = 15;
  } else {
    price = 20;
  }

  if (age > 60) {
    return (price * 0.5).toInt();
  }
  return price;
}

String color(int count) {
  if (count <= 9) return 'yellow';
  if (count <= 16) return 'green';
  if (count <= 23) return 'pink';
  return 'beige';
}

Map<String, List<Station>> buildGraph(Map<String, List<Station>> lines) {
  if (_cachedGraph != null) return _cachedGraph!;
  final graph = <String, List<Station>>{};

  for (var stations in lines.values) {
    for (int i = 0; i < stations.length; i++) {
      graph.putIfAbsent(stations[i].name, () => []);

      if (i > 0) {
        // تجنب تكرار إضافة نفس المحطة كجار
        if (!graph[stations[i].name]!.any((s) => s.name == stations[i - 1].name)) {
          graph[stations[i].name]!.add(stations[i - 1]);
        }
        if (!graph[stations[i - 1].name]!.any((s) => s.name == stations[i].name)) {
          graph[stations[i - 1].name]!.add(stations[i]);
        }
      }
    }
  }

  _cachedGraph = graph;
  return graph;
}

List<String>? findShortestPath(
  Map<String, List<Station>> graph,
  String start,
  String end,
) {
  if (!graph.containsKey(start) || !graph.containsKey(end)) return null;

  final queue = Queue<List<String>>();
  final visited = <String>{};

  queue.add([start]);
  visited.add(start);

  while (queue.isNotEmpty) {
    final path = queue.removeFirst();
    final current = path.last;

    if (current == end) {
      return path;
    }

    for (final neighbor in graph[current]!) {
      final neighborName = neighbor.name;

      if (!visited.contains(neighborName)) {
        visited.add(neighborName);
        queue.add([...path, neighborName]);
      }
    }
  }
  return null;
}