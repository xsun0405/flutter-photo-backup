// 通讯录数据真实性验证脚本
const fs = require('fs');
const path = require('path');

console.log('📞 通讯录数据真实性验证');
console.log('='.repeat(60));

function analyzeContactData(contactFile) {
    try {
        const data = JSON.parse(fs.readFileSync(contactFile, 'utf8'));
        
        console.log(`📄 文件: ${path.basename(contactFile)}`);
        console.log(`📅 上传时间: ${data.uploadTime}`);
        console.log(`📊 联系人总数: ${data.totalContacts}`);
        
        if (data.metadata) {
            console.log(`📱 数据来源: ${data.metadata.dataSource || '未知'}`);
            if (data.metadata.statistics) {
                const stats = data.metadata.statistics;
                console.log(`👤 有姓名: ${stats.withNames}`);
                console.log(`📞 有电话: ${stats.withPhones}`);
                console.log(`📧 有邮箱: ${stats.withEmails}`);
            }
        }
        
        if (data.serverValidation) {
            const validation = data.serverValidation;
            console.log(`✅ 数据完整性: ${validation.dataIntegrity ? '通过' : '失败'}`);
            console.log(`🔍 真实数据检测: ${validation.hasRealData ? '是真实数据' : '可能是假数据'}`);
            
            if (validation.sampleContact) {
                const sample = validation.sampleContact;
                console.log(`📋 样本联系人:`);
                console.log(`   - 有姓名: ${sample.hasName ? '是' : '否'}`);
                console.log(`   - 有电话: ${sample.hasPhone ? '是' : '否'}`);
                console.log(`   - 有邮箱: ${sample.hasEmail ? '是' : '否'}`);
            }
        }
        
        // 分析联系人数据质量
        if (data.contacts && data.contacts.length > 0) {
            const contacts = data.contacts;
            const realDataIndicators = contacts.filter(c => 
                c.contactId && c.timestamp && 
                (c.name || (c.phones && c.phones.length > 0))
            ).length;
            
            console.log(`🎯 真实数据指标: ${realDataIndicators}/${contacts.length} (${((realDataIndicators/contacts.length)*100).toFixed(1)}%)`);
            
            // 显示前3个联系人样本
            console.log(`📝 联系人样本 (前3个):`);
            contacts.slice(0, 3).forEach((contact, index) => {
                console.log(`   ${index + 1}. ${contact.name || '无姓名'}`);
                console.log(`      电话: ${contact.phones?.length || 0} 个`);
                console.log(`      邮箱: ${contact.emails?.length || 0} 个`);
                console.log(`      ID: ${contact.contactId ? '有' : '无'}`);
            });
        }
        
        console.log('-'.repeat(50));
        return true;
    } catch (error) {
        console.error(`❌ 解析文件失败: ${error.message}`);
        return false;
    }
}

// 查找所有通讯录文件
function findContactFiles() {
    const uploadDir = path.join(__dirname, 'data', 'uploads');
    const contactFiles = [];
    
    if (!fs.existsSync(uploadDir)) {
        console.log('❌ 上传目录不存在，请先运行应用并上传通讯录');
        return contactFiles;
    }
    
    function scanDir(dir) {
        const entries = fs.readdirSync(dir);
        for (const entry of entries) {
            const fullPath = path.join(dir, entry);
            const stat = fs.statSync(fullPath);
            
            if (stat.isDirectory()) {
                scanDir(fullPath);
            } else if (entry.startsWith('contacts_') && entry.endsWith('.json')) {
                contactFiles.push(fullPath);
            }
        }
    }
    
    scanDir(uploadDir);
    return contactFiles;
}

// 主执行
const contactFiles = findContactFiles();

if (contactFiles.length === 0) {
    console.log('📭 未找到通讯录文件');
    console.log('💡 请先运行Flutter应用并测试通讯录功能');
} else {
    console.log(`🔍 找到 ${contactFiles.length} 个通讯录文件\n`);
    
    contactFiles.forEach((file, index) => {
        console.log(`\n📂 分析文件 ${index + 1}/${contactFiles.length}:`);
        analyzeContactData(file);
    });
    
    console.log('\n🎯 验证结论:');
    console.log('✅ 如果看到"真实数据检测: 是真实数据"，说明获取的是真实通讯录');
    console.log('✅ 如果联系人有contactId和timestamp，说明是从系统API获取的真实数据');
    console.log('⚠️  如果数据质量指标低于50%，可能存在权限问题');
}

console.log('\n' + '='.repeat(60));
