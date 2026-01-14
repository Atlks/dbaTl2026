



MSSQL 监控工具（从最轻量到最强大）
下面这些工具都是 一键安装、开箱即用、跨平台 的，我把它们按“简单程度”排序，让你一眼就能选到最适合你的。

① dbForge Monitor for SQL Server（最简单、最漂亮）
Windows 专用

图形界面非常友好

安装即用，无需配置

监控内容包括：

CPU、IO、内存

活动会话

锁、死锁

慢查询

等待统计

适合你这种 小型项目 + Windows MSSQL。

② SQL Server 自带的监控工具（无需安装）
MSSQL 自带两个非常强大的监控工具：

SQL Server Activity Monitor
打开 SSMS → 右键服务器 → Activity Monitor

直接看到：

活动会话

等待任务

IO 统计

锁

SQL Server Performance Dashboard
微软官方扩展，安装一次即可。

监控 MSSQL（SQL Server）
Netdata 如何配置
要把 MSSQL（SQL Server） 接入 Netdata，其实比你想象的简单。Netdata 已经内置了一个 python.d/mssql 采集器，它通过 SQL Server 的 DMV（动态管理视图）采集整个实例的性能指标，而不是某个数据库的数据。

下面我给你一个 一步到位、可直接用的配置方案，你照着做就能看到图表。



## 第三步：确认 python3 和 pymssql 是否安装
MSSQL 插件依赖 Python3 + pymssql。

安装：

Code
sudo apt install python3 python3-pip
sudo pip3 install pymssql

## ⚠ 注意：你必须安装 Python MSSQL 驱动

Code
sudo apt install python3-pymssql
 否则 MSSQL 插件不会加载。

🟦 1. 确认 SQL Server 已启用 TCP 1433
Netdata 通过 TCP 连接 MSSQL，所以你需要确保：

SQL Server 开启 TCP/IP

监听端口 1433

用户（如 sa）允许登录

密码正确

如果你在 WSL2 里监控 Windows 上的 MSSQL，host 要写 Windows 的 IP（通常是 127.0.0.1 或 localhost）。

🟩 2. 创建 MSSQL 监控配置文件
Netdata 的 MSSQL 配置文件路径：

Code
/etc/netdata/python.d/mssql.conf
创建文件：

Code
sudo nano /etc/netdata/python.d/mssql.conf
写入以下内容（这是最小可用配置）：

Code
local:
name: 'mssql'
host: '127.0.0.1'
port: 1433
user: 'sa'
password: '你的密码'
database: 'master'
🔵 重要说明
database: 'master' 只是用于建立连接

Netdata 监控的是 整个 SQL Server 实例

不会限制在 master 库

所有数据库的指标都会被采集

🟦 3. 启用 MSSQL 插件（通常默认启用）
确认 python.d 插件已启用：

Code
sudo nano /etc/netdata/netdata.conf
确保：

Code
[plugins]
python.d = yes
🟩 4. 重启 Netdata
Code
sudo systemctl restart netdata
如果你在 WSL2：

Code
sudo service netdata restart
🟦 5. 打开浏览器查看监控
访问：

Code
http://localhost:19999
你会看到 MSSQL 的监控图表，例如：

active connections

transactions per second

buffer cache hit ratio

locks & waits

deadlocks

log flushes

IO stats

这些都是从 SQL Server 的 DMV 自动采集的。




🟩 如何确认 MSSQL 插件是否成功加载？
查看日志：

Code
sudo cat /var/log/netdata/python.d.log
如果成功，你会看到：

Code
INFO: mssql: started