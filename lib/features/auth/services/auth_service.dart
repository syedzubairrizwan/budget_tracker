import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String email;

  User({required this.id, required this.email});
}

class AuthService {
  // Simulate a database of users
  final Map<String, String> _users = {
    'test@test.com': 'password123',
  };

  Future<User?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email) && _users[email] == password) {
      return User(id: '123', email: email);
    }
    return null;
  }

  Future<User?> register(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    if (_users.containsKey(email)) {
      // User already exists
      return null;
    }
    _users[email] = password;
    return User(id: DateTime.now().millisecondsSinceEpoch.toString(), email: email);
  }

  Future<void> logout() async {
    // In a real app, you would clear the user session here
    await Future.delayed(const Duration(seconds: 1));
  }
}