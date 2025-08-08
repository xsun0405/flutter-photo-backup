import 'dart:convert';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'constants.dart';

class ContactService {
  // 请求通讯录权限并获取联系人（真实数据验证）
  static Future<List<Map<String, dynamic>>> requestContacts() async {
    // 1. 检查权限状态
    var status = await Permission.contacts.status;
    print('通讯录权限当前状态: $status');
    
    // 2. 如果未授权，请求权限
    if (!status.isGranted) {
      print('正在请求通讯录权限...');
      status = await Permission.contacts.request();
      print('权限请求结果: $status');
      
      if (!status.isGranted) {
        throw Exception('用户拒绝了通讯录权限访问');
      }
    }
    
    print('✅ 通讯录权限已获得，开始读取真实联系人数据...');

    // 3. 获取真实联系人数据
    final contacts = await FastContacts.getAllContacts();
    
    print('📞 从系统获取到 ${contacts.length} 个联系人');
    
    if (contacts.isEmpty) {
      print('⚠️  系统通讯录为空或无法访问');
      throw Exception('系统通讯录为空或无法访问，请检查是否真正授权');
    }

    // 4. 处理和验证联系人数据
    final result = <Map<String, dynamic>>[];
    int validContacts = 0;
    
    for (final contact in contacts) {
      // 验证联系人数据的真实性
      final name = contact.displayName?.trim();
      final phones = contact.phones.map((p) => p.number?.trim()).where((p) => p != null && p.isNotEmpty).toList();
      final emails = contact.emails.map((e) => e.address?.trim()).where((e) => e != null && e.isNotEmpty).toList();
      
      // 过滤掉完全空的联系人
      if (name != null && name.isNotEmpty || phones.isNotEmpty || emails.isNotEmpty) {
        result.add({
          'name': name ?? '无姓名',
          'phones': phones,
          'emails': emails,
          'hasName': name != null && name.isNotEmpty,
          'phoneCount': phones.length,
          'emailCount': emails.length,
          'contactId': contact.identifier, // 添加联系人ID作为验证
          'timestamp': DateTime.now().toIso8601String(), // 添加获取时间戳
        });
        validContacts++;
      }
    }
    
    print('✅ 处理完成：有效联系人 $validContacts 个');
    print('📊 数据统计：');
    print('   - 有姓名的联系人: ${result.where((c) => c['hasName'] == true).length}');
    print('   - 有电话的联系人: ${result.where((c) => (c['phoneCount'] as int) > 0).length}');
    print('   - 有邮箱的联系人: ${result.where((c) => (c['emailCount'] as int) > 0).length}');
    
    if (result.isEmpty) {
      throw Exception('无法获取有效的联系人数据，可能权限未真正生效');
    }
    
    return result;
  }

  // 上传通讯录到服务器（增强版，包含验证信息）
  static Future<void> uploadContacts(
    List<Map<String, dynamic>> contacts,
    String username,
  ) async {
    print('🔄 开始上传 ${contacts.length} 个联系人到服务器...');
    
    // 准备上传数据，包含验证信息
    final uploadData = {
      'username': username,
      'contacts': contacts,
      'metadata': {
        'totalContacts': contacts.length,
        'uploadTime': DateTime.now().toIso8601String(),
        'hasValidData': contacts.isNotEmpty,
        'statistics': {
          'withNames': contacts.where((c) => c['hasName'] == true).length,
          'withPhones': contacts.where((c) => (c['phoneCount'] as int) > 0).length,
          'withEmails': contacts.where((c) => (c['emailCount'] as int) > 0).length,
        },
        'dataSource': 'real_device_contacts', // 标记数据来源
        'appVersion': '1.0.0',
      }
    };
    
    final response = await http.post(
      Uri.parse(Constants.uploadContactUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(uploadData),
    );
    
    if (response.statusCode == 200) {
      print('✅ 通讯录上传成功');
      final responseData = json.decode(response.body);
      print('服务器响应: $responseData');
    } else {
      print('❌ 通讯录上传失败，状态码: ${response.statusCode}');
      throw Exception('通讯录上传失败：${response.statusCode}');
    }
  }
  
  // 验证权限是否真正生效
  static Future<bool> verifyContactPermission() async {
    try {
      final status = await Permission.contacts.status;
      if (!status.isGranted) {
        print('⚠️  通讯录权限未授权');
        return false;
      }
      
      // 尝试获取一个联系人来验证权限
      final contacts = await ContactsService.getContacts();
      print('✅ 权限验证成功，可访问 ${contacts.length} 个联系人');
      return true;
    } catch (e) {
      print('❌ 权限验证失败: $e');
      return false;
    }
  }
}
