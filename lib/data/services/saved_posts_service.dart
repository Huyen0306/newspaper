import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

class SavedPostsService {
  static const String _key = 'saved_posts';
  
  // ValueNotifier để notify khi có thay đổi
  final ValueNotifier<List<PostModel>> savedPostsNotifier = ValueNotifier<List<PostModel>>([]);
  
  // Singleton pattern
  static final SavedPostsService _instance = SavedPostsService._internal();
  factory SavedPostsService() => _instance;
  SavedPostsService._internal() {
    _init();
  }
  
  // Initialize và load saved posts
  Future<void> _init() async {
    final posts = await getSavedPosts();
    savedPostsNotifier.value = posts;
  }

  // Get all saved posts
  Future<List<PostModel>> getSavedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedPostsJson = prefs.getString(_key);
      
      if (savedPostsJson == null || savedPostsJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = json.decode(savedPostsJson);
      return decoded.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save a post
  Future<bool> savePost(PostModel post) async {
    try {
      final savedPosts = await getSavedPosts();
      
      // Check if post already exists
      if (savedPosts.any((p) => p.id == post.id)) {
        return false; // Already saved
      }

      savedPosts.add(post);
      final success = await _savePosts(savedPosts);
      if (success) {
        savedPostsNotifier.value = savedPosts;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Remove a saved post
  Future<bool> removePost(int postId) async {
    try {
      final savedPosts = await getSavedPosts();
      savedPosts.removeWhere((post) => post.id == postId);
      final success = await _savePosts(savedPosts);
      if (success) {
        savedPostsNotifier.value = savedPosts;
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Check if post is saved
  Future<bool> isPostSaved(int postId) async {
    try {
      final savedPosts = await getSavedPosts();
      return savedPosts.any((post) => post.id == postId);
    } catch (e) {
      return false;
    }
  }

  // Save posts list to SharedPreferences
  Future<bool> _savePosts(List<PostModel> posts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> postsJson = 
          posts.map((post) => post.toJson()).toList();
      final String encoded = json.encode(postsJson);
      return await prefs.setString(_key, encoded);
    } catch (e) {
      return false;
    }
  }

  // Clear all saved posts
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_key);
      if (success) {
        savedPostsNotifier.value = [];
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

