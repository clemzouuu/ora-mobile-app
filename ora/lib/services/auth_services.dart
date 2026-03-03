import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';
  static const _loggedInKey = 'loggedIn';

  Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_usernameKey)) {
      return false;
    }

    await prefs.setString(_usernameKey, username);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_loggedInKey, true);

    return true;
  }

  Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final savedUsername = prefs.getString(_usernameKey);
    final savedPassword = prefs.getString(_passwordKey);

    if (savedUsername == username && savedPassword == password) {
      await prefs.setBool(_loggedInKey, true);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }
}
