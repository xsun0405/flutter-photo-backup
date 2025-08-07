import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ContactService {
  // 获取所有联系人
  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      // 获取设备上的所有联系人
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      
      // 转换为可以JSON序列化的格式
      return contacts.map((contact) {
        final phones = contact.phones?.map((phone) => phone.value).toList() ?? [];
        
        return {
          'displayName': contact.displayName ?? '',
          'givenName': contact.givenName ?? '',
          'familyName': contact.familyName ?? '',
          'phones': phones,
          'emails': contact.emails?.map((email) => email.value).toList() ?? [],
          'note': contact.note ?? '',
        };
      }).toList();
    } catch (e) {
      print('获取联系人错误: $e');
      return [];
    }
  }

  // 上传联系人到服务器
  Future<bool> uploadContacts(
    List<Map<String, dynamic>> contacts,
    String username,
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/upload_contacts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'phone': phone,
          'contacts': contacts,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('上传联系人错误: $e');
      return false;
    }
  }
}