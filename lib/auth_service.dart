import 'dart:convert';
import 'dart:io';
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

  // 检查网络连接和服务器可用性
  Future<bool> _checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse(Constants.apiUrl),
        headers: {'Connection': 'close'},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 404; // 服务器响应即可
    } catch (e) {
      print('网络连接检查失败: $e');
      return false;
    }
  }

  Future<bool> register(String username, String phone, String password) async {
    try {
      // 检查网络连接
      if (!await _checkConnection()) {
        throw Exception('无法连接到服务器，请检查网络连接和服务器地址');
      }
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

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
    } on SocketException {
      print('网络连接错误: 请检查网络连接');
      throw Exception('网络连接失败，请检查网络设置');
    } on HttpException {
      print('HTTP错误: 服务器响应异常');
      throw Exception('服务器响应异常，请稍后重试');
    } catch (e) {
      print('注册错误: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('请求超时，请检查网络连接');
      }
    }
    return false;
  }

  Future<bool> login({required String phone, required String password}) async {
    try {
      // 检查网络连接
      if (!await _checkConnection()) {
        throw Exception('无法连接到服务器，请检查网络连接和服务器地址');
      }
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

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
    } on SocketException {
      print('网络连接错误: 请检查网络连接');
      throw Exception('网络连接失败，请检查网络设置');
    } on HttpException {
      print('HTTP错误: 服务器响应异常');
      throw Exception('服务器响应异常，请稍后重试');
    } catch (e) {
      print('登录错误: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('请求超时，请检查网络连接');
      }
    }
    return false;
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
