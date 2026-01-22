# 植物大战僵尸联机版一键 FRP 工具

很简单的脚本，只需要有人提供一个有公网 IP 的服务器，其它人就可以一键启动 FRP，并且脚本会告诉他应该怎么填写，真正意义上的开箱即用。

## FRP

本仓库不包含 frpc.exe 或 frps，请在[官方仓库](https://github.com/fatedier/frp)中获取。

## 原理

客户端通过脚本生成随机的 frpc 配置文件，连接上 frps 服务器，并通过插件强制修改代理配置。创建完成后通过 api 接口获取随机分配的远程端口，打印在终端中，指导小白用户填写。

## 服务端

服务端需要这三个文件：

1. frps
2. frps.toml
3. server.py

python 需要以下库：

1. fastapi
2. uvicorn

服务端只需要做这两件事就可以提供服务：

1. 启动 frps，可以用仓库中的 frps.toml，只需要修改其中的 `auth.token`、`webServer.user`、`webServer.password` 这三个配置即可。
2. 启动 server.py，需要修改 `auth=("USER", "PASSWORD")` 这个配置。

需要放行以下端口（均可在配置中修改）：

1. `7000/tcp`：frps 入口端口
2. `14000-15000/udp`：对外映射的端口段
3. `9002/tcp`：server.py 的端口查询接口
4. `7500/tcp`：frps dashboard（这个可以不开放，如果你不想从外部访问 dashboard 的话）

## 客户端

客户端需要包含以下文件：

1. frpc.exe
2. 启动主机.bat

在将客户端打包分发前，需要修改 `启动主机.bat` 中的 `SERVER_ADDR` 和 `TOKEN`。

## 叠甲

写的很匆忙，属于能跑就行，欢迎贡献完善！
