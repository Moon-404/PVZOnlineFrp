@echo off
chcp 65001 > nul
cd /d "%~dp0"

set SERVER_ADDR=SERVER_ADDR
set SERVER_PORT=7000
set LOCAL_PORT=1437
set TOKEN=TOKEN

echo 请以管理员权限运行此脚本
echo 正在启动主机
echo 大约需要10秒左右的时间

netsh advfirewall firewall delete rule name="PVZOnline" > nul
netsh advfirewall firewall add rule name="PVZOnline" dir=in action=allow protocol=udp localport=%LOCAL_PORT% profile=any > nul

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command ^
  "$chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';" ^
  "$r=1..8|ForEach-Object{$chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]};" ^
  "-join $r"`) do set "PROXY_NAME=pvzonline_%%i"

> frpc.toml (
  echo serverAddr = "%SERVER_ADDR%"
  echo serverPort = %SERVER_PORT%
  echo auth.method = "token"
  echo auth.token = "%TOKEN%"
  echo log.to = "./frpc.log"
  echo log.level = "info"
  echo log.maxDays = 3
  echo [[proxies]]
  echo name = "%PROXY_NAME%"
  echo type = "udp"
  echo localIP = "127.0.0.1"
  echo localPort = %LOCAL_PORT%
  echo remotePort = 0
)

start /B frpc.exe -c frpc.toml

timeout /T 5 /NOBREAK > nul

del frpc.toml

for /f "usebackq" %%p in (`curl -s http://%SERVER_ADDR%:9002/port/%PROXY_NAME%`) do set REMOTE_PORT=%%p

echo ======
if %REMOTE_PORT%==0 (
    echo 主机启动失败
    echo 请将frpc.log的内容发到群内询问解决方案
    pause
) else (
    echo 主机启动完成
    echo ======
    echo 你需要进入联机版，选择“是”来创建主机
    echo 然后输入端口：%LOCAL_PORT%
    echo ======
    echo 之后让另一个玩家进入联机版，选择“否”来连接主机
    echo 然后输入主机IP：%SERVER_ADDR%
    echo 再输入端口：%REMOTE_PORT%
    echo ======
    echo 在结束游戏之前请保持该窗口打开
)
