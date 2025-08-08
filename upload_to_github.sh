#!/bin/bash
# GitHub项目上传脚本
# 请先在GitHub上创建仓库：flutter-photo-backup

echo "🚀 开始上传项目到GitHub..."

# 检查远程仓库
echo "📡 配置远程仓库..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/xsun0405/flutter-photo-backup.git

# 确保分支名为main
echo "🌿 设置主分支..."
git branch -M main

# 推送到GitHub
echo "⬆️ 推送代码到GitHub..."
git push -u origin main

echo "✅ 项目已成功上传到GitHub!"
echo "🌐 访问链接: https://github.com/xsun0405/flutter-photo-backup"
