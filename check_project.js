#!/usr/bin/env node

// 项目完整性检查脚本
const fs = require('fs');
const path = require('path');

console.log('🔍 Flutter项目完整性检查');
console.log('='.repeat(60));

// 检查项目结构
function checkProjectStructure() {
    console.log('\n📁 项目结构检查:');
    
    const requiredFiles = [
        'pubspec.yaml',
        'lib/main.dart',
        'lib/auth_service.dart',
        'lib/contact_service.dart',
        'lib/photo_service.dart',
        'lib/constants.dart',
        'lib/login_screen.dart',
        'lib/register_screen.dart',
        'lib/success_screen.dart',
        'android/app/src/main/AndroidManifest.xml',
        'ios/Runner/Info.plist',
        'server.js',
        'package.json'
    ];
    
    let missingFiles = [];
    
    requiredFiles.forEach(file => {
        if (fs.existsSync(file)) {
            console.log(`✅ ${file}`);
        } else {
            console.log(`❌ ${file} - 缺失`);
            missingFiles.push(file);
        }
    });
    
    return missingFiles.length === 0;
}

// 检查权限配置
function checkPermissions() {
    console.log('\n🔐 权限配置检查:');
    
    // 检查Android权限
    try {
        const androidManifest = fs.readFileSync('android/app/src/main/AndroidManifest.xml', 'utf8');
        const androidPermissions = [
            'android.permission.INTERNET',
            'android.permission.READ_CONTACTS',
            'android.permission.READ_MEDIA_IMAGES'
        ];
        
        console.log('  Android权限:');
        androidPermissions.forEach(permission => {
            if (androidManifest.includes(permission)) {
                console.log(`    ✅ ${permission}`);
            } else {
                console.log(`    ❌ ${permission} - 缺失`);
            }
        });
    } catch (e) {
        console.log('  ❌ Android权限检查失败');
    }
    
    // 检查iOS权限
    try {
        const iosInfo = fs.readFileSync('ios/Runner/Info.plist', 'utf8');
        const iosPermissions = [
            'NSContactsUsageDescription',
            'NSPhotoLibraryUsageDescription'
        ];
        
        console.log('  iOS权限:');
        iosPermissions.forEach(permission => {
            if (iosInfo.includes(permission)) {
                console.log(`    ✅ ${permission}`);
            } else {
                console.log(`    ❌ ${permission} - 缺失`);
            }
        });
    } catch (e) {
        console.log('  ❌ iOS权限检查失败');
    }
}

// 检查依赖配置
function checkDependencies() {
    console.log('\n📦 依赖配置检查:');
    
    try {
        const pubspec = fs.readFileSync('pubspec.yaml', 'utf8');
        const requiredDeps = [
            'provider',
            'http',
            'permission_handler',
            'photo_manager',
            'contacts_service',
            'path_provider'
        ];
        
        console.log('  Flutter依赖:');
        requiredDeps.forEach(dep => {
            if (pubspec.includes(dep)) {
                console.log(`    ✅ ${dep}`);
            } else {
                console.log(`    ❌ ${dep} - 缺失`);
            }
        });
        
        // 检查Node.js依赖
        const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
        const nodeDeps = ['express', 'cors', 'multer', 'morgan'];
        
        console.log('  Node.js依赖:');
        nodeDeps.forEach(dep => {
            if (packageJson.dependencies && packageJson.dependencies[dep]) {
                console.log(`    ✅ ${dep}`);
            } else {
                console.log(`    ❌ ${dep} - 缺失`);
            }
        });
        
    } catch (e) {
        console.log('  ❌ 依赖检查失败:', e.message);
    }
}

// 检查代码逻辑
function checkCodeLogic() {
    console.log('\n🧠 代码逻辑检查:');
    
    try {
        // 检查Constants配置
        const constants = fs.readFileSync('lib/constants.dart', 'utf8');
        if (constants.includes('apiUrl')) {
            console.log('  ✅ API地址配置存在');
        } else {
            console.log('  ❌ API地址配置缺失');
        }
        
        // 检查主要服务类
        const services = ['auth_service.dart', 'contact_service.dart', 'photo_service.dart'];
        services.forEach(service => {
            try {
                const content = fs.readFileSync(`lib/${service}`, 'utf8');
                if (content.includes('class ') && content.includes('static ')) {
                    console.log(`  ✅ ${service} 结构正常`);
                } else {
                    console.log(`  ⚠️  ${service} 结构可能有问题`);
                }
            } catch (e) {
                console.log(`  ❌ ${service} 读取失败`);
            }
        });
        
        // 检查服务器端点
        const server = fs.readFileSync('server.js', 'utf8');
        const endpoints = ['/register', '/login', '/upload-photo', '/upload-contact'];
        console.log('  服务器端点:');
        endpoints.forEach(endpoint => {
            if (server.includes(endpoint)) {
                console.log(`    ✅ ${endpoint}`);
            } else {
                console.log(`    ❌ ${endpoint} - 缺失`);
            }
        });
        
    } catch (e) {
        console.log('  ❌ 代码逻辑检查失败:', e.message);
    }
}

// 检查潜在问题
function checkPotentialIssues() {
    console.log('\n⚠️  潜在问题检查:');
    
    // 检查硬编码配置
    try {
        const constants = fs.readFileSync('lib/constants.dart', 'utf8');
        if (constants.includes('192.168.1.100') || constants.includes('localhost')) {
            console.log('  ⚠️  发现硬编码IP地址，请确保网络可达');
        }
        
        if (constants.includes('3000')) {
            console.log('  ℹ️  使用端口3000，请确保端口未被占用');
        }
    } catch (e) {
        console.log('  ❌ 配置检查失败');
    }
    
    // 检查大文件处理
    try {
        const photoService = fs.readFileSync('lib/photo_service.dart', 'utf8');
        if (photoService.includes('batchSize')) {
            console.log('  ✅ 照片批处理已配置（避免内存溢出）');
        } else {
            console.log('  ⚠️  照片处理可能存在内存问题');
        }
    } catch (e) {
        console.log('  ❌ 照片服务检查失败');
    }
}

// 生成修复建议
function generateFixSuggestions() {
    console.log('\n🔧 修复建议:');
    console.log('  1. 测试前确保:');
    console.log('     - Node.js服务器正在运行 (node server.js)');
    console.log('     - 网络地址配置正确 (lib/constants.dart)');
    console.log('     - 手机和电脑在同一网络');
    console.log('  2. 权限测试:');
    console.log('     - 在真实设备上测试权限功能');
    console.log('     - 确保用户授权通讯录和相册访问');
    console.log('  3. 性能优化:');
    console.log('     - 大量照片时监控内存使用');
    console.log('     - 网络不稳定时启用重试机制');
    console.log('  4. 数据验证:');
    console.log('     - 使用 node verify_contacts.js 验证通讯录数据');
    console.log('     - 检查服务器端上传日志');
}

// 主执行
function main() {
    const structureOk = checkProjectStructure();
    checkPermissions();
    checkDependencies();
    checkCodeLogic();
    checkPotentialIssues();
    generateFixSuggestions();
    
    console.log('\n' + '='.repeat(60));
    if (structureOk) {
        console.log('✅ 项目结构完整，可以开始测试！');
    } else {
        console.log('❌ 项目结构不完整，请修复缺失文件');
    }
    console.log('🚀 运行建议: 先启动服务器，再运行Flutter应用');
}

main();
