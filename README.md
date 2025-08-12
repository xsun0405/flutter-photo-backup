# 📱 Flutter 全量相册备份应用

一个功能完整的Flutter应用，支持用户相册照片全量备份到服务器。

## ✨ 主要功能

### 🔐 用户系统
- 用户注册/登录
- 安全的身份验证

### 📸 相册备份
- **全量照片获取**：获取用户相册中的所有照片（不限制数量）
- **智能分批处理**：避免内存溢出，每次处理50张照片
- **实时进度显示**：上传进度条和状态提示
- **断点续传**：支持上传失败重试

### 📱 权限管理
- 相册访问权限
- 通讯录访问权限
- 完整的权限请求和处理流程

### 🌐 跨平台支持
- ✅ **iOS** - 完整支持，包含GitHub Actions自动编译
- ✅ **Android** - 完整支持
- ⚠️ **HarmonyOS** - 基础功能兼容，部分插件需适配

## 🚀 技术架构

### 前端 (Flutter)
- **状态管理**: Provider模式
- **权限处理**: permission_handler
- **相册访问**: photo_manager
- **网络请求**: http
- **UI框架**: Material Design

### 后端 (Node.js)
- **Web框架**: Express.js
- **文件上传**: Multer
- **跨域支持**: CORS
- **文件存储**: 本地文件系统

### DevOps
- **CI/CD**: GitHub Actions
- **iOS自动编译**: 生成未签名IPA包
- **代码质量**: Flutter分析和格式化

## 📦 快速开始

### 1. 环境准备
```bash
# Flutter环境
flutter --version
flutter doctor

# Node.js环境  
node --version
npm --version
```

### 2. 启动后端服务
```bash
# 安装依赖
npm install

# 启动服务器
node server.js
# 或
./start.bat
```

### 3. 启动Flutter应用
```bash
# 安装Flutter依赖
flutter pub get

# 运行应用（Android）
flutter run

# 编译iOS（需要macOS）
flutter build ios --release --no-codesign
```

### 4. GitHub Actions自动编译
推送到main分支即可自动编译iOS包：
```bash
git push origin main
```

## 📱 使用流程

1. **用户注册**：输入用户名、手机号、密码
2. **权限授权**：授权相册和通讯录访问权限
3. **相册备份**：
   - 点击"备份全部相册照片"
   - 查看实时进度："正在上传 X/Y 张照片"
   - 等待完成提示
4. **服务器存储**：照片保存到 `data/uploads/{username}/相册/`

## 📊 技术特性

### 🔧 性能优化
- **内存管理**: 分批处理照片，避免大量照片导致内存溢出
- **网络优化**: 100ms上传间隔，减少服务器压力
- **用户体验**: 实时进度反馈，防止重复操作

### 🛡️ 安全特性
- **权限控制**: 完整的iOS/Android权限声明
- **数据隔离**: 按用户名分目录存储
- **错误处理**: 完善的异常捕获和用户提示

### 📈 扩展特性
- **日志记录**: 详细的上传日志和状态记录
- **进度查询**: RESTful API查询上传进度
- **批量操作**: 支持大量文件的高效处理

## 🌍 平台兼容性

| 平台 | 支持状态 | 说明 |
|------|----------|------|
| **iOS** | ✅ 完全支持 | GitHub Actions自动编译 |
| **Android** | ✅ 完全支持 | 标准Android项目 |
| **HarmonyOS** | ⚠️ 部分兼容 | 基础功能可用，权限插件需适配 |

## 📂 项目结构

```
├── lib/                    # Flutter Dart代码
│   ├── main.dart          # 应用入口
│   ├── auth_service.dart  # 用户认证服务
│   ├── photo_service.dart # 相册服务（核心功能）
│   ├── contact_service.dart # 通讯录服务
│   └── screens/           # 界面组件
├── android/               # Android原生配置
├── ios/                   # iOS原生配置
├── .github/workflows/     # GitHub Actions配置
├── server.js             # Node.js后端服务
└── package.json          # 后端依赖配置
```

## 🔧 核心API

### PhotoService (Dart)
```dart
// 获取全部相册照片
static Future<List<File>> requestPhotos()

// 批量上传照片（带进度回调）
static Future<void> uploadPhotos(
  List<File> photos, 
  String username, {
  Function(int current, int total)? onProgress,
})

// 一键备份全部照片
static Future<void> backupAllPhotosToServer(
  String username, {
  Function(int current, int total)? onProgress,
})
```

### 服务器API
```javascript
POST /upload-photo        // 上传单张照片
GET  /upload-progress/:username  // 查询上传进度
POST /register           // 用户注册
POST /login              // 用户登录
```

## 🎯 开发计划

### 已完成 ✅
- [x] 基础Flutter项目结构
- [x] iOS/Android双平台支持
- [x] 用户认证系统
- [x] 全量相册备份功能
- [x] 实时进度显示
- [x] GitHub Actions自动编译
- [x] 完整的权限管理

### 进行中 🚧
- [ ] HarmonyOS平台适配
- [ ] 更多文件格式支持
- [ ] 云存储集成（AWS S3/阿里云OSS）

### 计划中 📋
- [ ] 照片智能分类
- [ ] 增量备份功能
- [ ] 多设备同步
- [ ] Web管理后台

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

1. Fork项目
2. 创建功能分支: `git checkout -b feature/新功能`
3. 提交更改: `git commit -m '添加新功能'`
4. 推送分支: `git push origin feature/新功能`
5. 提交Pull Request

## 📄 License

MIT License - 详见 [LICENSE](LICENSE) 文件

## 📞 联系方式

- GitHub: [@xsun0405](https://github.com/xsun0405)
- 问题反馈: [Issues](https://github.com/xsun0405/flutter-photo-backup/issues)

---

⭐ 如果这个项目对您有帮助，请给一个Star！

# 强制触发CI编译
# 更新时间：2025-08-12
