import 'package:budget_tracker/features/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('login', () {
      test('should return a user when login is successful', () async {
        final user = await authService.login('test@test.com', 'password123');
        expect(user, isA<User>());
        expect(user?.email, 'test@test.com');
      });

      test('should return null when password is incorrect', () async {
        final user = await authService.login('test@test.com', 'wrongpassword');
        expect(user, isNull);
      });

      test('should return null when email does not exist', () async {
        final user = await authService.login('nouser@test.com', 'password123');
        expect(user, isNull);
      });
    });

    group('register', () {
      test('should return a new user when registration is successful', () async {
        final user = await authService.register('new@test.com', 'newpassword');
        expect(user, isA<User>());
        expect(user?.email, 'new@test.com');
      });

      test('should return null when email already exists', () async {
        final user = await authService.register('test@test.com', 'password123');
        expect(user, isNull);
      });
    });
  });
}