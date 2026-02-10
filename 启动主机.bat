@echo off
chcp 65001 > nul
cd /d "%~dp0"

set SERVER_ADDR=SERVER_ADDR
set SERVER_PORT=7000
set LOCAL_PORT=1437
set TOKEN=TOKEN

echo ====== 
echo 使用前请仔细阅读《联机工具使用说明》 
echo 请注意不要点击该窗口进入【选择】模式，会导致脚本卡死 
echo 假如已经进入该模式，请按 ESC 退出【选择】模式 
echo ====== 

echo 正在确认管理员权限 
>nul 2>&1 net session
if %errorlevel% neq 0 (
  powershell -NoProfile -Command ^
    "Try { Start-Process '%~f0' -Verb RunAs -ErrorAction Stop; } " ^
    "Catch { Write-Host '管理员权限获取失败 '; pause; }"
  exit /b
)
echo 管理员权限确认完成 

set "FRPC_PATH=%~dp0frpc.exe"
powershell -NoProfile -Command ^
  "Try { Add-MpPreference -ExclusionProcess '%FRPC_PATH%' -ErrorAction Stop; " ^
  "Write-Host '添加 Windows Defender 白名单完成:' '%FRPC_PATH%'; } " ^
  "Catch { Write-Host '添加 Windows Defender 白名单失败，请自行为' '%FRPC_PATH%' '添加白名单 ' }"

netsh advfirewall firewall delete rule name="PVZOnline" > nul
netsh advfirewall firewall add rule name="PVZOnline" dir=in action=allow protocol=udp localport=%LOCAL_PORT% profile=any > nul
echo 防火墙规则"PVZOnline"创建完成 

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command ^
  "$chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';" ^
  "$r=1..8|ForEach-Object{$chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]};" ^
  "-join $r"`) do set "PROXY_NAME=pvzonline_%%i"
echo 隧道名创建完成: %PROXY_NAME% 

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

echo 正在启动 frpc.exe，请等待5秒 
start /B frpc.exe -c frpc.toml
timeout /T 5 /NOBREAK > nul
del frpc.toml
echo frpc.exe 启动完成 

for /f "usebackq" %%p in (`curl -s http://%SERVER_ADDR%:9002/port/%PROXY_NAME%`) do set REMOTE_PORT=%%p
echo 远程端口获取完成 

echo ======
if %REMOTE_PORT%==0 (
    echo 主机启动失败
    echo 请将frpc.log的内容发到群内询问解决方案
    pause
) else (
    echo 主机启动完成
    echo 你需要进入联机版，选择“是”来创建主机
    echo 然后输入端口：%LOCAL_PORT%
    echo ======
    echo 之后让另一个玩家进入联机版，选择“否”来连接主机
    echo 然后输入主机IP：%SERVER_ADDR%
    echo 再输入端口：%REMOTE_PORT%
    echo ======
    echo 在结束游戏之前请保持该窗口打开
)
