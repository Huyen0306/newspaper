import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TaskService {
  static const String _readArticleTaskKey = 'read_article_task_completed';
  static const String _readArticleTaskTimeKey = 'read_article_task_time';
  static const int _requiredReadTime = 5; // seconds
  static const int _rewardPoints = 100;

  // ValueNotifier để notify khi có thay đổi
  final ValueNotifier<bool> taskCompletedNotifier = ValueNotifier<bool>(false);

  // Singleton pattern
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal() {
    _init();
  }

  // Initialize và load task status
  Future<void> _init() async {
    final isCompleted = await isTaskCompleted();
    taskCompletedNotifier.value = isCompleted;
  }

  // Check if task is completed
  Future<bool> isTaskCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_readArticleTaskKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get remaining read time (in seconds)
  Future<int> getRemainingReadTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTime = prefs.getInt(_readArticleTaskTimeKey) ?? 0;
      return _requiredReadTime - savedTime;
    } catch (e) {
      return _requiredReadTime;
    }
  }

  // Update read time
  Future<void> updateReadTime(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentTime = prefs.getInt(_readArticleTaskTimeKey) ?? 0;
      final newTime = currentTime + seconds;
      
      if (newTime >= _requiredReadTime) {
        // Task completed
        await prefs.setBool(_readArticleTaskKey, true);
        await prefs.setInt(_readArticleTaskTimeKey, _requiredReadTime);
        taskCompletedNotifier.value = true;
      } else {
        await prefs.setInt(_readArticleTaskTimeKey, newTime);
      }
    } catch (e) {
      // Handle error
    }
  }

  // Reset task (for testing or daily reset)
  Future<bool> resetTask() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_readArticleTaskKey);
      await prefs.remove(_readArticleTaskTimeKey);
      taskCompletedNotifier.value = false;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get required read time
  int get requiredReadTime => _requiredReadTime;

  // Get reward points
  int get rewardPoints => _rewardPoints;
}

