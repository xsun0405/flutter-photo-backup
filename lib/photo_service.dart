import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants.dart';

class PhotoService {
  // 请求相册权限并获取全部照片
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

    // 获取相册中全部照片的数量
    final totalCount = await albums.first.assetCountAsync;
    print('相册中共有 $totalCount 张照片');
    
    // 分批获取全部照片（避免内存溢出）
    final files = <File>[];
    const batchSize = 50; // 每次获取50张
    
    for (int start = 0; start < totalCount; start += batchSize) {
      final end = (start + batchSize > totalCount) ? totalCount : start + batchSize;
      print('正在获取第 ${start + 1} - $end 张照片...');
      
      final photos = await albums.first.getAssetListRange(start: start, end: end);
      
      for (final photo in photos) {
        final file = await photo.file;
        if (file != null) {
          files.add(file);
        }
      }
    }
    
    print('成功获取 ${files.length} 张照片');
    return files;
  }

  // 上传照片到服务器（带进度提示）
  static Future<void> uploadPhotos(List<File> photos, String username, {
    Function(int current, int total)? onProgress,
  }) async {
    print('开始上传 ${photos.length} 张照片到服务器...');
    
    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse(Constants.uploadPhotoUrl),
        );
        request.fields['username'] = username;
        request.fields['photoIndex'] = i.toString();
        request.fields['totalPhotos'] = photos.length.toString();
        
        // 添加文件名和时间戳
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${i + 1}.jpg';
        request.files.add(await http.MultipartFile.fromPath(
          'photo', 
          photo.path,
          filename: fileName,
        ));
        
        final response = await request.send();
        
        if (response.statusCode == 200) {
          print('照片 ${i + 1}/${photos.length} 上传成功');
          onProgress?.call(i + 1, photos.length);
        } else {
          print('照片 ${i + 1} 上传失败，状态码: ${response.statusCode}');
        }
      } catch (e) {
        print('照片 ${i + 1} 上传出错: $e');
      }
      
      // 短暂延迟，避免服务器压力过大
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    print('全部照片上传完成！');
  }
  
  // 获取全部相册照片并直接上传到服务器
  static Future<void> backupAllPhotosToServer(String username, {
    Function(int current, int total)? onProgress,
  }) async {
    try {
      // 1. 获取全部照片
      final photos = await requestPhotos();
      
      if (photos.isEmpty) {
        throw Exception('相册中没有找到照片');
      }
      
      // 2. 上传到服务器
      await uploadPhotos(photos, username, onProgress: onProgress);
      
      print('相册备份完成：共备份 ${photos.length} 张照片');
    } catch (e) {
      print('相册备份失败: $e');
      rethrow;
    }
  }
}
