import 'package:flutter/material.dart';

class UserPreferences extends ChangeNotifier {
  List<String> _preferredTypes = [];
  String? _preferredZone;
  int? _maxBudget;
  String? _preferredVisitTime;
  int? _maxDistanceFromAirport;
  String? _preferredWeeklyOff;

  List<String> get preferredTypes => _preferredTypes;
  String? get preferredZone => _preferredZone;
  int? get maxBudget => _maxBudget;
  String? get preferredVisitTime => _preferredVisitTime;
  int? get maxDistanceFromAirport => _maxDistanceFromAirport;
  String? get preferredWeeklyOff => _preferredWeeklyOff;

  void setPreferredType(String? type) {
    _preferredTypes = type as List<String>;
    notifyListeners();
  }

  void setPreferredZone(String? zone) {
    _preferredZone = zone;
    notifyListeners();
  }

  void setMaxBudget(int? budget) {
    _maxBudget = budget;
    notifyListeners();
  }

  void setPreferredVisitTime(String? visitTime) {
    _preferredVisitTime = visitTime;
    notifyListeners();
  }

  void setMaxDistanceFromAirport(int? distance) {
    _maxDistanceFromAirport = distance;
    notifyListeners();
  }

  void setPreferredWeeklyOff(String? weeklyOff) {
    _preferredWeeklyOff = weeklyOff;
    notifyListeners();
  }

  void setPreferredTypes(List<String> types) {
    _preferredTypes = types;
    notifyListeners();
  }

  void togglePreferredType(String type) {
    if (_preferredTypes.contains(type)) {
      _preferredTypes.remove(type);
    } else {
      _preferredTypes.add(type);
      if (_preferredTypes.isNotEmpty) {
        _preferredTypes.remove('Any Type');
      }
    }
    notifyListeners();
  }
}
