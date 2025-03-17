import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project/model/user/user.dart';

class AuthService extends ChangeNotifier {
  final PocketBase _pb;
  final FlutterSecureStorage _storage;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  User? _currentUser;

  AuthService({PocketBase? pb, FlutterSecureStorage? storage})
      : _pb = pb ?? PocketBase('http://10.0.2.2:8090'),
        _storage = storage ?? const FlutterSecureStorage();

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      _pb.authStore.save(token, null);
      try {
        await _pb.collection('users').authRefresh();
        _isLoggedIn = true;

        await loadUserInfo();
      } catch (e) {
        await _storage.delete(key: 'auth_token');
        _pb.authStore.clear();
        _isLoggedIn = false;
        _currentUser = null;
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final authData =
          await _pb.collection('users').authWithPassword(email, password);
      if (authData.token == null) {
        throw Exception("Auth token is null!");
      }

      if (authData.record == null) {
        throw Exception("Auth record (user data) is null!");
      }

      _pb.authStore.save(authData.token, authData.record);
      print("AuthStore after login: ${_pb.authStore.model}");

      await _storage.write(key: 'auth_token', value: authData.token);
      _isLoggedIn = true;

      await loadUserInfo();

      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    _pb.authStore.clear();
    _isLoggedIn = false;
    _currentUser = null; // Xóa thông tin người dùng khi logout
    notifyListeners();
  }

  Future<void> register(
      String email, String password, String passwordConfirm) async {
    try {
      final body = {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'emailVisibility': true,
      };
      print('Register request body: $body'); // Debug: Log the request body
      await _pb.collection('users').create(body: body);
    } catch (e) {
      print('Register error: $e'); // Debug: Log the full error
      throw Exception('Register failed: $e');
    }
  }

  Future<void> loadUserInfo() async {
    try {
      if (!_pb.authStore.isValid) {
        throw Exception("No valid session found");
      }

      final userModel = _pb.authStore.model;
      if (userModel == null) {
        throw Exception("User model is null!");
      }

      final userId = userModel.id;
      if (userId == null) {
        throw Exception("User ID is null!");
      }

      final userData = await _pb.collection('users').getOne(userId);

      print("User data: ${userData}");

      _currentUser = User.fromJson(userData.toJson());
      print("Current user: $_currentUser");
      notifyListeners();
    } catch (e) {
      print("Error loading user info: $e");
    }
  }

  Future<void> updateUserInfo(User user) async {
    try {
      if (!_pb.authStore.isValid || _pb.authStore.model == null) {
        throw Exception("No valid session or user model found");
      }

      final userModel = _pb.authStore.model!;
      if (userModel.id.isEmpty) {
        throw Exception("User model has no valid ID");
      }

      final userId = userModel.id;

      final updatedUser =
          await _pb.collection('users').update(userId, body: user.toJson());

      if (updatedUser == null) {
        throw Exception("Failed to update user: No response from server");
      }

      _currentUser = User.fromJson(updatedUser.toJson());
      notifyListeners();
    } on ClientException catch (e) {
      print("Client error updating user: $e");
    } catch (e, stackTrace) {
      print("Unexpected error updating user: $e");
      print(stackTrace);
    }
  }
}
