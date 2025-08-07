import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart';
import '../utils/constants.dart';

class PhotoService {
  // 获取所有照片
  Future<List<File>> getAllPhotos() async {
    // 请求权限
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      // 获取所有资源
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      
      if (albums.isEmpty) {
        return [];
      }
      
      // 获取第一个相册（通常是"全部照片"）
      final AssetPathEntity album = albums.first;
      
      // 获取相册中的所有照片
      final List<AssetEntity> photos = await album.getAssetListRange(
        start: 0,
        end: 100, // 限制为最近的100张照片，以避免处理太多
      );
      
      // 将AssetEntity转换为File
      final List<File> files = [];
      for (final AssetEntity photo in photos) {
        final File? file = await photo.file;
        if (file != null) {
          files.add(file);
        }
      }
      
      return files;
    }
    
    return [];
  }

  // 上传单张照片
  Future<bool> uploadPhoto(
    File photo,
    String username,
    String phone,
  ) async {
    try {
      final uri = Uri.parse('${Constants.apiUrl}/upload_photo');
      
      // 创建multipart请求
      final request = http.MultipartRequest('POST', uri);
      
      // 添加文本字段
      request.fields['username'] = username;
      request.fields['phone'] = phone;
      
      // 添加文件
      final fileName = basename(photo.path);
      final mimeType = _getMimeType(fileName);
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photo.path,
          contentType: mimeType,
        ),
      );
      
      // 发送请求
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = responseData; // 如果服务器返回JSON，这里应该解析JSON
        return true;
      }
      return false;
    } catch (e) {
      print('上传照片错误: $e');
      return false;
    }
  }

  // 批量上传照片
  Future<bool> uploadPhotos(
    List<File> photos,
    String username,
    String phone,
  ) async {
    try {
      // 逐个上传照片
      for (final photo in photos) {
        await uploadPhoto(photo, username, phone);
      }
      return true;
    } catch (e) {
      print('批量上传照片错误: $e');
      return false;
    }
  }

  // 根据文件扩展名获取MIME类型
  MediaType? _getMimeType(String fileName) {
    final ext = extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.bmp':
        return MediaType('image', 'bmp');
      case '.webp':
        return MediaType('image', 'webp');
      case '.heic':
        return MediaType('image', 'heic');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}