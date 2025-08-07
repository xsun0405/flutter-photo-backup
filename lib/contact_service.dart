import 'dart:convert';
import 'package:contacts_service/contacts_service.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'constants.dart';

class ContactService {
  // 请求通讯录权限并获取联系人
  static Future<List<Map<String, dynamic>>> requestContacts() async {
    // 请求权限
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      throw Exception('未获得通讯录权限');
    }

    // 获取联系人
    final contacts = await ContactsService.getContacts();
    final result = <Map<String, dynamic>>[];
    for (final contact in contacts) {
      result.add({
        'name': contact.displayName ?? '未知',
        'phones': contact.phones?.map((p) => p.value).toList() ?? [],
        'emails': contact.emails?.map((e) => e.value).toList() ?? [],
      });
    }
    return result;
  }

  // 上传通讯录到服务器
  static Future<void> uploadContacts(
    List<Map<String, dynamic>> contacts,
    String username,
  ) async {
    await http.post(
      Uri.parse(Constants.uploadContactUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'contacts': contacts,
      }),
    );
  }
}
