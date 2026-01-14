import 'db_helper.dart';
import '../models/user.dart';
import 'session_service.dart';

class AuthService {
  final DBHelper _db = DBHelper();
  final SessionService _sessionService = SessionService();

  Future<User?> login(String username, String password) async {
    final user = await _db.getUser(username, password);
    if (user != null) {
      // Simpan session setelah login berhasil (with userId!)
      await _sessionService.saveSession(user.id!, user.username, user.role);
    }
    return user;
  }

  Future<int> register(User user) async {
    return await _db.insertUser(user);
  }

  Future<void> logout() async {
    await _sessionService.clearSession();
  }

  Future<Map<String,dynamic>?> getSession() async {
    return await _sessionService.getSession();
  }
}
