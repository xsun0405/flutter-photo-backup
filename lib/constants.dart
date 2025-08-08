class Constants {
  // 后端API地址配置
  // 本地开发：使用localhost或具体IP
  // 生产环境：请修改为实际服务器地址
  static const String _localHost = '192.168.1.100'; // 请修改为您的实际IP
  static const String _port = '3000';
  static const String apiUrl = 'http://$_localHost:$_port';
  
  // 替代方案配置（如果上面的IP不可用）
  static const String alternativeApiUrl = 'http://localhost:3000';
  
  // API接口路径
  static const String registerUrl = '$apiUrl/register';
  static const String loginUrl = '$apiUrl/login';
  static const String uploadPhotoUrl = '$apiUrl/upload-photo';
  static const String uploadContactUrl = '$apiUrl/upload-contact';
  static const String uploadProgressUrl = '$apiUrl/upload-progress';
  
  // 配置验证
  static bool isValidUrl() {
    try {
      Uri.parse(apiUrl);
      return true;
    } catch (e) {
      return false;
    }
  }
}
