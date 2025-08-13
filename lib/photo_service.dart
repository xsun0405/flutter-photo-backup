import 'dart:io';
import 'dart:core' as core;
// 全局日志输出，彻底解决 print 冲突
@pragma('vm:entry-point')
void print(Object? object) {
  core.debugPrint('$object');
}
import 'package:http/http.dart' as http;
// import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constants.dart';

@pragma('vm:entry-point')
void print(Object? object) {
  core.debugPrint('$object');
}

// 确保没有自定义print变量或方法，全部用系统print函数
  // ...existing code...
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
  
  // 获取全部相册照片并直接上传到服务器（内存优化版）
  static Future<void> backupAllPhotosToServer(String username, {
    Function(int current, int total)? onProgress,
  }) async {
    try {
      // 1. 请求权限
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        throw Exception('未获得相册权限');
      }

      // 2. 获取相册信息
      final albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      if (albums.isEmpty) {
        throw Exception('相册中没有找到照片');
      }

      final totalCount = await albums.first.assetCountAsync;
  print('相册中共有 $totalCount 张照片');
      
      if (totalCount == 0) {
        throw Exception('相册中没有找到照片');
      }

      // 3. 分批处理和上传（避免内存溢出）
      const batchSize = 20; // 减少批次大小，降低内存压力
      int uploadedCount = 0;
      
      for (int start = 0; start < totalCount; start += batchSize) {
        final end = (start + batchSize > totalCount) ? totalCount : start + batchSize;
  print('正在处理第 ${start + 1} - $end 张照片...');
        
        // 获取当前批次的照片
        final photos = await albums.first.getAssetListRange(start: start, end: end);
        
        // 逐张处理和上传
        for (int i = 0; i < photos.length; i++) {
          final photo = photos[i];
          final file = await photo.file;
          
          if (file != null) {
            try {
              // 单张上传
              await _uploadSinglePhoto(file, username, uploadedCount, totalCount);
              uploadedCount++;
              onProgress?.call(uploadedCount, totalCount);
              
              // 短暂延迟，减少服务器压力
              await Future.delayed(const Duration(milliseconds: 100));
            } catch (e) {
              print('照片 ${uploadedCount + 1} 上传失败: $e');
            }
          }
        }
        
        // 批次之间的延迟，让系统回收内存
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
  print('相册备份完成：共备份 $uploadedCount 张照片');
    } catch (e) {
  print('相册备份失败: $e');
      rethrow;
    }
  }
  
  // 单张照片上传（私有方法）
  static Future<void> _uploadSinglePhoto(File photo, String username, int index, int total) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Constants.uploadPhotoUrl),
    );
    request.fields['username'] = username;
    request.fields['photoIndex'] = index.toString();
    request.fields['totalPhotos'] = total.toString();
    
    // 添加文件名和时间戳
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${index + 1}.jpg';
    request.files.add(await http.MultipartFile.fromPath(
      'photo', 
      photo.path,
      filename: fileName,
    ));
    
    final response = await request.send();
    
    if (response.statusCode != 200) {
      throw Exception('上传失败，状态码: ${response.statusCode}');
    }
    
  print('照片 ${index + 1}/$total 上传成功');
  }
}
