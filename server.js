const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const app = express();
const dotenv = require('dotenv');
const morgan = require('morgan');

// 加载环境变量
dotenv.config();

// 设置服务器端口
const PORT = process.env.PORT || 3000;

// 启用CORS，允许跨域请求
app.use(cors());

// 设置请求体大小限制
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// 日志记录
app.use(morgan('dev'));

// 确保上传目录存在
const uploadsDir = path.join(__dirname, 'data', 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// 配置文件存储
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const { username, phone } = req.body;
    
    if (!username || !phone) {
      return cb(new Error('用户名和手机号不能为空'), null);
    }
    
    const userDir = path.join(uploadsDir, `${username}${phone}`);
    if (!fs.existsSync(userDir)) {
      fs.mkdirSync(userDir, { recursive: true });
    }
    
    const photoDir = path.join(userDir, '相册');
    if (!fs.existsSync(photoDir)) {
      fs.mkdirSync(photoDir, { recursive: true });
    }
    
    cb(null, photoDir);
  },
  filename: function (req, file, cb) {
    // 使用原始文件名和时间戳，避免文件名冲突
    const timestamp = Date.now();
    const originalName = file.originalname;
    cb(null, `${timestamp}-${originalName}`);
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 } // 限制文件大小为10MB
});

// 照片上传端点
app.post('/upload_photo', upload.single('photo'), (req, res) => {
  try {
    const { username, phone } = req.body;
    
    if (!req.file) {
      return res.status(400).json({ 
        success: false, 
        message: '没有收到照片文件' 
      });
    }
    
    console.log(`[照片上传] 用户：${username}${phone} | 文件：${req.file.filename}`);
    
    res.status(200).json({ 
      success: true, 
      message: '照片上传成功',
      data: {
        filename: req.file.filename,
        size: req.file.size,
        path: req.file.path
      }
    });
  } catch (error) {
    console.error('照片上传错误:', error);
    res.status(500).json({ 
      success: false, 
      message: `照片上传失败: ${error.message}` 
    });
  }
});

// 批量照片上传端点
app.post('/upload_photos', upload.array('photos', 100), (req, res) => {
  try {
    const { username, phone } = req.body;
    
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: '没有收到照片文件' 
      });
    }
    
    console.log(`[批量照片上传] 用户：${username}${phone} | 文件数量：${req.files.length}`);
    
    res.status(200).json({ 
      success: true, 
      message: `成功上传 ${req.files.length} 张照片`,
      data: {
        count: req.files.length,
        files: req.files.map(file => ({
          filename: file.filename,
          size: file.size
        }))
      }
    });
  } catch (error) {
    console.error('批量照片上传错误:', error);
    res.status(500).json({ 
      success: false, 
      message: `批量照片上传失败: ${error.message}` 
    });
  }
});

// 通讯录上传端点
app.post('/upload_contacts', (req, res) => {
  try {
    const { username, phone, contacts } = req.body;
    
    if (!username || !phone) {
      return res.status(400).json({ 
        success: false, 
        message: '用户名和手机号不能为空' 
      });
    }
    
    if (!contacts || !Array.isArray(contacts)) {
      return res.status(400).json({ 
        success: false, 
        message: '通讯录数据格式不正确' 
      });
    }
    
    const userDir = path.join(uploadsDir, `${username}${phone}`);
    if (!fs.existsSync(userDir)) {
      fs.mkdirSync(userDir, { recursive: true });
    }
    
    const contactsDir = path.join(userDir, '通讯录');
    if (!fs.existsSync(contactsDir)) {
      fs.mkdirSync(contactsDir, { recursive: true });
    }
    
    const timestamp = Date.now();
    const contactsFile = path.join(contactsDir, `contacts-${timestamp}.json`);
    
    fs.writeFileSync(contactsFile, JSON.stringify(contacts, null, 2), 'utf8');
    
    console.log(`[通讯录上传] 用户：${username}${phone} | 联系人数量：${contacts.length}`);
    
    res.status(200).json({ 
      success: true, 
      message: `成功上传 ${contacts.length} 个联系人`,
      data: {
        count: contacts.length,
        path: contactsFile
      }
    });
  } catch (error) {
    console.error('通讯录上传错误:', error);
    res.status(500).json({ 
      success: false, 
      message: `通讯录上传失败: ${error.message}` 
    });
  }
});

// 注册端点
app.post('/register', (req, res) => {
  try {
    const { username, phone, password } = req.body;
    
    if (!username || !phone || !password) {
      return res.status(400).json({ 
        success: false, 
        message: '用户名、手机号和密码不能为空' 
      });
    }
    
    // 在实际应用中，这里应该将用户信息存储到数据库
    // 这里简化处理，只记录注册信息
    const userDir = path.join(uploadsDir, `${username}${phone}`);
    if (!fs.existsSync(userDir)) {
      fs.mkdirSync(userDir, { recursive: true });
    }
    
    const userInfo = {
      username,
      phone,
      password: password, // 实际应用中应该加密存储
      registeredAt: new Date().toISOString()
    };
    
    fs.writeFileSync(
      path.join(userDir, 'user_info.json'),
      JSON.stringify(userInfo, null, 2),
      'utf8'
    );
    
    console.log(`[用户注册] 用户名：${username} | 手机号：${phone}`);
    
    res.status(200).json({ 
      success: true, 
      message: '注册成功',
      data: {
        username,
        phone
      }
    });
  } catch (error) {
    console.error('注册错误:', error);
    res.status(500).json({ 
      success: false, 
      message: `注册失败: ${error.message}` 
    });
  }
});

// 登录端点
app.post('/login', (req, res) => {
  try {
    const { phone, password } = req.body;
    
    if (!phone || !password) {
      return res.status(400).json({ 
        success: false, 
        message: '手机号和密码不能为空' 
      });
    }
    
    // 在实际应用中，这里应该查询数据库验证用户
    // 这里简化处理，在文件系统中查找用户
    const userDirs = fs.readdirSync(uploadsDir);
    let userFound = false;
    let userData = null;
    
    for (const dir of userDirs) {
      if (dir.includes(phone)) {
        const userInfoPath = path.join(uploadsDir, dir, 'user_info.json');
        if (fs.existsSync(userInfoPath)) {
          const userInfo = JSON.parse(fs.readFileSync(userInfoPath, 'utf8'));
          if (userInfo.password === password) {
            userFound = true;
            userData = {
              username: userInfo.username,
              phone: userInfo.phone
            };
            break;
          }
        }
      }
    }
    
    if (userFound) {
      console.log(`[用户登录] 用户：${userData.username} | 手机号：${userData.phone}`);
      res.status(200).json({ 
        success: true, 
        message: '登录成功',
        data: userData
      });
    } else {
      res.status(401).json({ 
        success: false, 
        message: '手机号或密码错误' 
      });
    }
  } catch (error) {
    console.error('登录错误:', error);
    res.status(500).json({ 
      success: false, 
      message: `登录失败: ${error.message}` 
    });
  }
});

// 验证码端点（模拟）
app.post('/send_verification_code', (req, res) => {
  const { phone } = req.body;
  
  if (!phone) {
    return res.status(400).json({ 
      success: false, 
      message: '手机号不能为空' 
    });
  }
  
  // 生成6位随机验证码
  const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
  
  console.log(`[验证码] 手机号：${phone} | 验证码：${verificationCode}`);
  
  // 在实际应用中，这里应该发送短信
  // 这里简化处理，直接返回验证码
  res.status(200).json({ 
    success: true, 
    message: '验证码发送成功',
    data: {
      code: verificationCode
    }
  });
});

// 健康检查端点
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'ok', 
    timestamp: new Date().toISOString() 
  });
});

// 启动服务器
app.listen(PORT, '0.0.0.0', () => {
  console.log(`服务器运行在 http://0.0.0.0:${PORT}`);
  console.log(`上传目录: ${uploadsDir}`);
  console.log(`确保防火墙允许端口 ${PORT} 的访问`);
});