

三个层级 使用者，维修这，建造者

# 安装运维  ，监控 ，报警

# 性能 优化

## 分区  
## 内存表 
## 查询缓存  写入缓存
## 延迟索引
## sp ，本地编译sp
## 物化试图 
## AlwaysOn 读写分离：读压力分散到多个副本


## io分流，Filegroup 规划：冷热数据分离、独立磁盘、独立备份
TempDB 独立磁盘：减少 tempdb 争用


# 再造数据库

加锁机制  事务机制   索引机制  分片机制  ha高可用



🚀 MSSQL 性能优化全景图（实战版）
🧱 1. 架构级优化（最重要）
🧱 1. 架构级优化（最重要）
分区表：大表拆分，减少扫描范围，提升维护速度

Filegroup 规划：冷热数据分离、独立磁盘、独立备份

内存表（Memory-Optimized Table）：极高并发场景

AlwaysOn 读写分离：读压力分散到多个副本

TempDB 独立磁盘：减少 tempdb 争用

⚙️ 2. 索引优化（性能提升最明显）
延迟索引（Delayed Index Creation）：减少写入压力

覆盖索引：避免回表

过滤索引：针对稀疏数据

列存储索引（Columnstore）：分析型查询神器

索引重建/重组：减少碎片

统计信息更新：让优化器做出正确计划



🧠 3. 查询优化（最常见的瓶颈来源）
**避免 SELECT ***：减少 IO

避免隐式转换：导致索引失效

避免 OR / LIKE '%xxx'：导致全表扫描

使用 APPLY / EXISTS 替代 IN

使用分页 OFFSET/FETCH

避免跨库 JOIN



🧩 4. 存储过程优化（你已经提到）
SP（Stored Procedure）：减少网络往返

本地编译 SP（Native Compiled SP）：内存表 + 极致性能

参数嗅探优化：OPTION(RECOMPILE) 或优化参数

强制计划 / Plan Guide：避免优化器选错计划



📦 6. 存储层优化
SSD / NVMe：IO 是数据库性能的天花板

日志文件独立磁盘：减少写入争用

TempDB 多文件：减少 GAM/SGAM 争用

压缩（Row/Page Compression）：减少 IO



🔥 7. 锁与并发优化
行版本控制（RCSI / Snapshot）：减少锁等待

降低事务范围：减少锁持有时间

避免大事务：减少阻塞

使用 NOLOCK（谨慎）：减少锁，但可能读脏数据



🧪 8. 监控与诊断
Query Store：查看慢 SQL、计划回退

Extended Events：捕获性能问题

DMV（动态管理视图）：分析锁、等待、IO

PerfMon：系统级性能监控