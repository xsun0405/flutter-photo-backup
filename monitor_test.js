// 实时监控测试结果
const fs = require('fs');
const path = require('path');

console.log('🎯 Flutter相册备份项目 - 实时测试监控');
console.log('='.repeat(60));
console.log('📡 服务器地址: http://192.168.110.116:3000');
console.log('📱 等待手机连接...\n');

const uploadDir = path.join(__dirname, 'data', 'uploads');

function formatTime() {
    return new Date().toLocaleTimeString('zh-CN');
}

function checkForNewUploads() {
    if (!fs.existsSync(uploadDir)) {
        console.log(`[${formatTime()}] 📁 等待上传目录创建...`);
        return;
    }
    
    try {
        const users = fs.readdirSync(uploadDir);
        
        if (users.length === 0) {
            console.log(`[${formatTime()}] 👤 等待用户注册...`);
            return;
        }
        
        console.log(`\n[${formatTime()}] 📊 发现用户活动:`);
        
        users.forEach(username => {
            const userDir = path.join(uploadDir, username);
            console.log(`\n👤 用户: ${username}`);
            
            // 检查通讯录
            const contactDir = path.join(userDir, '通讯录');
            if (fs.existsSync(contactDir)) {
                const contactFiles = fs.readdirSync(contactDir);
                console.log(`  📞 通讯录文件: ${contactFiles.length} 个`);
                contactFiles.forEach(file => {
                    const filePath = path.join(contactDir, file);
                    const stats = fs.statSync(filePath);
                    console.log(`    - ${file} (${stats.mtime.toLocaleString()})`);
                });
            } else {
                console.log(`  📞 通讯录: 未上传`);
            }
            
            // 检查相册
            const photoDir = path.join(userDir, '相册');
            if (fs.existsSync(photoDir)) {
                const photoFiles = fs.readdirSync(photoDir);
                console.log(`  📸 照片数量: ${photoFiles.length} 张`);
                if (photoFiles.length > 0) {
                    const totalSize = photoFiles.reduce((total, file) => {
                        const filePath = path.join(photoDir, file);
                        return total + fs.statSync(filePath).size;
                    }, 0);
                    console.log(`  📦 总大小: ${(totalSize / 1024 / 1024).toFixed(2)} MB`);
                }
            } else {
                console.log(`  📸 相册: 未上传`);
            }
            
            // 检查用户信息
            const userInfoFile = path.join(userDir, 'user_info.json');
            if (fs.existsSync(userInfoFile)) {
                console.log(`  ✅ 用户已注册`);
            }
        });
        
    } catch (error) {
        console.log(`[${formatTime()}] ❌ 检查错误: ${error.message}`);
    }
}

// 每5秒检查一次
console.log('🔄 开始监控（每5秒刷新）...\n');
setInterval(checkForNewUploads, 5000);

// 立即执行一次
checkForNewUploads();
