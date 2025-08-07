import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants.dart';

class PhotoService {
  // 请求相册权限并获取最近100张照片
  static Future<List<File>> requestPhotos() async {
    // 请求权限
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      throw Exception('未获得相册权限');
    }

    // 获取全部相册
    final albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );
    if (albums.isEmpty) return [];

    // 获取最近100张照片
    final photos = await albums.first.getAssetListRange(start: 0, end: 100);
    final files = <File>[];
    for (final photo in photos) {
      final file = await photo.file;
      if (file != null) files.add(file);
    }
    return files;
  }

  // 上传照片到服务器
  static Future<void> uploadPhotos(List<File> photos, String username) async {
    for (final photo in photos) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Constants.uploadPhotoUrl),
      );
      request.fields['username'] = username;
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));
      await request.send();
    }
  }
}
