// 测试服务器API接口
const http = require('http');

console.log('🧪 测试服务器API接口');
console.log('='.repeat(40));

// 测试根路由
function testRoot() {
    return new Promise((resolve, reject) => {
        const req = http.get('http://localhost:3001', (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                console.log('✅ 根路由测试成功:');
                console.log(data);
                resolve(data);
            });
        });
        
        req.on('error', (err) => {
            console.log('❌ 根路由测试失败:', err.message);
            reject(err);
        });
        
        req.setTimeout(5000);
    });
}

// 测试注册接口
function testRegister() {
    return new Promise((resolve, reject) => {
        const postData = JSON.stringify({
            username: 'test_user',
            phone: '13800138000',
            password: '123456'
        });
        
        const options = {
            hostname: 'localhost',
            port: 3001,
            path: '/register',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(postData)
            }
        };
        
        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                console.log('✅ 注册接口测试成功:');
                console.log('状态码:', res.statusCode);
                console.log('响应:', data);
                resolve(data);
            });
        });
        
        req.on('error', (err) => {
            console.log('❌ 注册接口测试失败:', err.message);
            reject(err);
        });
        
        req.write(postData);
        req.end();
    });
}

// 主测试函数
async function runTests() {
    try {
        console.log('1. 测试根路由...');
        await testRoot();
        
        console.log('\n2. 测试注册接口...');
        await testRegister();
        
        console.log('\n🎉 所有API测试完成！');
        
    } catch (error) {
        console.log('\n❌ 测试失败:', error.message);
        console.log('💡 请确保服务器正在运行 (node server.js)');
    }
}

// 执行测试
runTests();
