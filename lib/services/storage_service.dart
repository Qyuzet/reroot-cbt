import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../utils/constants.dart';

class StorageService {
  // Save a session to local storage
  static Future<bool> saveSession(Session session) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing sessions
      List<Session> sessions = await getSessions();

      // Add new session
      sessions.add(session);

      // Convert to JSON and save
      List<String> sessionsJson =
          sessions.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(AppConstants.sessionHistoryKey, sessionsJson);

      return true;
    } catch (e) {
      debugPrint('Error saving session: $e');
      return false;
    }
  }

  // Get all sessions from local storage
  static Future<List<Session>> getSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get saved sessions
      List<String>? sessionsJson = prefs.getStringList(
        AppConstants.sessionHistoryKey,
      );

      if (sessionsJson == null || sessionsJson.isEmpty) {
        return [];
      }

      // Convert from JSON to Session objects
      return sessionsJson.map((s) => Session.fromJson(jsonDecode(s))).toList()
        // Sort by timestamp (newest first)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error getting sessions: $e');
      return [];
    }
  }

  // Save theme preference
  static Future<bool> saveThemePreference(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.themePreferenceKey, isDarkMode);
      return true;
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
      return false;
    }
  }

  // Get theme preference
  static Future<bool> getThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.themePreferenceKey) ?? false;
    } catch (e) {
      debugPrint('Error getting theme preference: $e');
      return false;
    }
  }

  // Save language preference
  static Future<bool> saveLanguagePreference(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languagePreferenceKey, languageCode);
      return true;
    } catch (e) {
      debugPrint('Error saving language preference: $e');
      return false;
    }
  }

  // Get language preference
  static Future<String> getLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.languagePreferenceKey) ?? 'en';
    } catch (e) {
      debugPrint('Error getting language preference: $e');
      return 'en';
    }
  }
}
