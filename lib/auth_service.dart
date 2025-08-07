import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class AuthService extends ChangeNotifier {
  String? _username;
  String? _phone;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get phone => _phone;

  Future<bool> register(String username, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _username = username;
          _phone = phone;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('注册错误: $e');
    }
    return false;
  }

  Future<bool> login({required String phone, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _username = data['username'] ?? '';
          _phone = phone;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('登录错误: $e');
    }
    return false;
  }
          _phone = phone;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('注册错误: $e');
      return false;
    }
  }

  Future<bool> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _username = data['data']['username'];
          _phone = data['data']['phone'];
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('登录错误: $e');
      return false;
    }
  }

  Future<String?> sendVerificationCode(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/send_verification_code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data']['code'];
        }
      }
      return null;
    } catch (e) {
      print('发送验证码错误: $e');
      return null;
    }
  }

  void logout() {
    _username = null;
    _phone = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
