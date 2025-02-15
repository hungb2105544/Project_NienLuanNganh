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
        // Làm mới phiên đăng nhập
        await _pb.collection('users').authRefresh();
        _isLoggedIn = true;

        // Tải thông tin người dùng
        await loadUserInfo();
      } catch (e) {
        // Xóa token nếu phiên không hợp lệ
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
      // Kiểm tra token và record
      if (authData.token == null) {
        throw Exception("Auth token is null!");
      }

      if (authData.record == null) {
        throw Exception("Auth record (user data) is null!");
      }

      // Lưu token và user vào authStore
      _pb.authStore.save(authData.token, authData.record);
      print(
          "AuthStore after login: ${_pb.authStore.model}"); // Kiểm tra model sau khi lưu

      // Lưu token vào Secure Storage
      await _storage.write(key: 'auth_token', value: authData.token);
      _isLoggedIn = true;

      // Tải thông tin người dùng sau khi đăng nhập
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

  Future<void> register(String email, String password) async {
    try {
      await _pb
          .collection('users')
          .create(body: {'email': email, 'password': password});
    } catch (e) {
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

      // Cập nhật thông tin user trên PocketBase
      final updatedUser =
          await _pb.collection('users').update(userId, body: user.toJson());

      // Kiểm tra dữ liệu trả về
      if (updatedUser == null) {
        throw Exception("Failed to update user: No response from server");
      }

      // Cập nhật dữ liệu mới từ server
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

  // Future<String?> uploadImage(File imageFile, String userId) async {
  //   try {
  //     var url = Uri.parse(
  //         'http://10.0.2.2:8090//api/collections/users/records/$userId');

  //     var request = http.MultipartRequest('PATCH', url)
  //       ..headers['Authorization'] =
  //           'Bearer YOUR_AUTH_TOKEN' // Thay bằng token hợp lệ
  //       ..headers['Content-Type'] = 'multipart/form-data'
  //       ..files.add(
  //         await http.MultipartFile.fromPath(
  //           'avatar', // Tên field của file trong PocketBase
  //           imageFile.path,
  //           contentType: MediaType('image', 'jpeg'),
  //         ),
  //       );

  //     var client = http.Client();
  //     var streamedResponse = await client.send(request);
  //     var response = await http.Response.fromStream(streamedResponse);

  //     client.close();

  //     if (response.statusCode == 200) {
  //       var jsonResponse = jsonDecode(response.body);
  //       return jsonResponse['avatar']; // Trả về tên file avatar mới
  //     } else {
  //       throw Exception('Failed to upload image: ${response.body}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error uploading image: $e');
  //   }
  // }
