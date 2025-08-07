import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'contact_service.dart';
import 'photo_service.dart';
import 'success_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // 测试通讯录权限并上传
  Future<void> _testContacts() async {
    try {
      final contacts = await ContactService.requestContacts();
      await ContactService.uploadContacts(contacts, _usernameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('通讯录上传成功，共${contacts.length}条')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('通讯录处理失败：$e')),
      );
    }
  }

  // 测试相册权限并上传
  Future<void> _testPhotos() async {
    try {
      final photos = await PhotoService.requestPhotos();
      await PhotoService.uploadPhotos(photos, _usernameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('照片上传成功，共${photos.length}张')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('照片处理失败：$e')),
      );
    }
  }

  // 注册
  Future<void> _register() async {
    final success = await AuthService.register(
      username: _usernameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册成功')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '用户名'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '手机号'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _testContacts, child: const Text('测试通讯录权限')),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _testPhotos, child: const Text('测试相册权限')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: const Text('注册')),
            ],
          ),
        ),
      ),
    );
  }
}
