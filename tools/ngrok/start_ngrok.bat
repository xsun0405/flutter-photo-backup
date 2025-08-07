@echo off
echo 启动内网穿透...
echo 请确保服务器已经启动
echo.
ngrok.exe start ios_test_server --config=ngrok.yml
pause