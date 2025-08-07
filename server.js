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
    const userDir = path.join(uploadDir, req.body.username || 'unknown');
    const photoDir = path.join(userDir, '相册');
    fs.mkdirSync(photoDir, { recursive: true });
    cb(null, photoDir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

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
  res.send({ success: true });
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
