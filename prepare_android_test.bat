@echo off
echo 📱 Android测试准备脚本
echo ==========================================

echo.
echo 🔍 检查当前IP地址...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    echo 当前IP地址: !ip!
)

echo.
echo 🔧 检查项目配置...
if exist "lib\constants.dart" (
    echo ✅ 找到constants.dart文件
    findstr "_localHost" lib\constants.dart
) else (
    echo ❌ constants.dart文件不存在
)

echo.
echo 📦 检查Node.js依赖...
if exist "node_modules" (
    echo ✅ Node.js依赖已安装
) else (
    echo 📥 正在安装Node.js依赖...
    npm install
)

echo.
echo 🎯 准备编译APK...
echo 请确认以下信息：
echo 1. IP地址是否正确配置在constants.dart中
echo 2. 手机和电脑是否在同一网络
echo 3. Flutter环境是否已安装

echo.
echo 📋 下一步操作建议：
echo 1. 运行: flutter build apk --release
echo 2. 启动: node server.js
echo 3. 传输: build\app\outputs\flutter-apk\app-release.apk 到手机
echo 4. 安装并测试应用

echo.
pause
