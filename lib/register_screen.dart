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
  
  // 上传进度状态
  bool _isUploading = false;
  int _uploadProgress = 0;
  int _totalPhotos = 0;

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

  // 测试相册权限并上传全部照片
  Future<void> _testPhotos() async {
    if (_usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入用户名')),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _totalPhotos = 0;
    });
    
    try {
      await PhotoService.backupAllPhotosToServer(
        _usernameController.text,
        onProgress: (current, total) {
          setState(() {
            _uploadProgress = current;
            _totalPhotos = total;
          });
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('相册备份成功！共上传 $_totalPhotos 张照片')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('相册备份失败：$e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // 注册
  Future<void> _register() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.register(
      _usernameController.text,
      _phoneController.text,
      _passwordController.text,
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
              
              // 相册备份按钮和进度显示
              if (_isUploading) ...[
                const Text('正在备份相册照片...'),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _totalPhotos > 0 ? _uploadProgress / _totalPhotos : 0,
                ),
                const SizedBox(height: 8),
                Text('$_uploadProgress / $_totalPhotos 张照片'),
                const SizedBox(height: 10),
              ] else ...[
                ElevatedButton(
                  onPressed: _testPhotos, 
                  child: const Text('备份全部相册照片'),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: const Text('注册')),
            ],
          ),
        ),
      ),
    );
  }
}
