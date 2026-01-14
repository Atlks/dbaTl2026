

监控内容包括：

剩余磁盘

锁、死锁，事务

写入延迟

活动会话 conns

慢查询

等待统计

CPU、IO、内存

buffer cache 与命中率




🟩 🟦 监控 MSSQL（SQL Server）
Netdata 内置 MSSQL 监控插件：python.d.plugin  → mssql.conf

你只需要创建配置文件：

Code
sudo nano /etc/netdata/python.d/mssql.conf
写入：

Code
local:
name: 'local-mssql'
host: '127.0.0.1'
port: 1433
user: 'sa'
password: '你的密码'
database: 'master'
保存后重启 Netdata：

Code
sudo systemctl restart netdata
然后你会看到：

mssql connections

mssql transactions

mssql locks

mssql buffer cache

这些图表会自动出现。




🟩 Netdata 监控 MSSQL 时，实际监控的是整个实例
包括：

所有数据库的连接数

所有数据库的事务

所有数据库的锁

所有数据库的缓冲池

所有数据库的日志写入

所有数据库的死锁

所有数据库的 CPU / IO

这些指标来自：

sys.dm_exec_sessions

sys.dm_exec_requests

sys.dm_os_performance_counters

sys.dm_os_wait_stats

sys.dm_io_virtual_file_stats

sys.dm_os_memory_clerks