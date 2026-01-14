import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyUserId = 'session_user_id';
  static const String _keyUsername = 'session_username';
  static const String _keyRole = 'session_role';
  static const String _keyIsLoggedIn = 'session_is_logged_in';

  // Simpan session setelah login berhasil
  Future<void> saveSession(int userId, String username, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyRole, role);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Ambil session yang tersimpan
  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    if (!isLoggedIn) return null;
    
    final userId = prefs.getInt(_keyUserId);
    final username = prefs.getString(_keyUsername);
    final role = prefs.getString(_keyRole);
    
    if (userId == null || username == null || role == null) return null;
    
    return {
      'userId': userId,
      'username': username,
      'role': role,
    };
  }

  // Hapus session (untuk logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRole);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Check apakah user sudah login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }
}
