class Constants {
  // 后端API地址（替换为你的服务器IP或ngrok地址）
  static const String apiUrl = 'http://192.168.1.100:3000';
  
  // API接口路径
  static const String registerUrl = '$apiUrl/register';
  static const String loginUrl = '$apiUrl/login';
  static const String uploadPhotoUrl = '$apiUrl/upload-photo';
  static const String uploadContactUrl = '$apiUrl/upload-contact';
}
