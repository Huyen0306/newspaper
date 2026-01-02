import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class PointsService {
  static const String _pointsKey = 'user_points';
  
  // ValueNotifier để notify khi có thay đổi
  final ValueNotifier<int> pointsNotifier = ValueNotifier<int>(0);
  
  // Singleton pattern
  static final PointsService _instance = PointsService._internal();
  factory PointsService() => _instance;
  PointsService._internal() {
    _init();
  }
  
  // Initialize và load points
  Future<void> _init() async {
    final points = await getPoints();
    pointsNotifier.value = points;
  }

  // Get current points
  Future<int> getPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_pointsKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Add points
  Future<bool> addPoints(int points) async {
    try {
      final currentPoints = await getPoints();
      final newPoints = currentPoints + points;
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setInt(_pointsKey, newPoints);
      if (success) {
        pointsNotifier.value = newPoints;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Set points
  Future<bool> setPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setInt(_pointsKey, points);
      if (success) {
        pointsNotifier.value = points;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Reset points
  Future<bool> resetPoints() async {
    return await setPoints(0);
  }
}

