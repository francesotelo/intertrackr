import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  String? _token;
  String _userName = 'Mindaphil Francisca Sotelo';
  List<dynamic> _applications = [];
  Map<String, dynamic> _userProfile = {};
  bool _isLoading = false;
  bool _isDarkMode = false;

  String? get token => _token;
  String get userName => _userName;
  List<dynamic> get applications => _applications;
  Map<String, dynamic> get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _token != null;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await ApiService.login(email, password);
    // The ID token is our session marker. Fall back to the uid if the token
    // could not be fetched so the user is still treated as logged in.
    _token = (data['token'] as String?) ?? ApiService.currentUserId;
    if (_token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    }
    await loadProfile();
    notifyListeners();
  }

  Future<void> loadApplications() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _applications = await ApiService.getApplications(_token!);

      // Fallback: If no applications exist in Firestore yet, load dummy JSON data
      if (_applications.isEmpty) {
        final String response =
            await rootBundle.loadString('assets/dummy.json');
        final List<dynamic> data = json.decode(response);
        _applications = data;
      }

      await loadProfile(); // Sync profile data too
    } catch (e) {
      // Fallback to dummy data if offline or error occurs
      try {
        final String response =
            await rootBundle.loadString('assets/dummy.json');
        _applications = json.decode(response);
      } catch (_) {}
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (_token == null) return;
    try {
      _userProfile = await ApiService.getProfile(_token!);
      if (_userProfile['name'] != null) {
        _userName = _userProfile['name'];
      }
      notifyListeners();
    } catch (e) {
      // Profile not found or error loading
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> updateData) async {
    if (_token == null) return;
    try {
      _userProfile = await ApiService.updateProfile(_token!, updateData);
      if (_userProfile['name'] != null) _userName = _userProfile['name'];
      notifyListeners();
    } catch (e) {
      // Error updating profile
    }
  }

  Future<void> updateApplication(
    String id,
    Map<String, dynamic> updateData,
  ) async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.updateApplication(_token!, id, updateData);
      await loadApplications();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Firebase persists the session on-device, so clearing local state alone
    // would leave the user signed in. End the Firebase session too.
    await ApiService.logout();
    _token = null;
    _applications = [];
    _userProfile = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  /// Restores the session on app start. Firebase keeps the user signed in
  /// across restarts, so if a user exists we rehydrate our state instead of
  /// forcing a fresh login. Returns true when a session was restored.
  Future<bool> tryRestoreSession() async {
    if (!ApiService.isSignedIn) {
      _token = null;
      return false;
    }
    _token = (await ApiService.currentIdToken()) ?? ApiService.currentUserId;
    if (_token == null) return false;
    await loadApplications();
    return true;
  }
}
