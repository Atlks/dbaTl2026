


tidb也会造成在业务上的问题

适合10tb以上的业务
单字段高频读写这类业务的tps下降一个数量级
监控体系庞大：Prometheus + Grafana
高性能 OLTP
不支持存储过程  / 函数 / 触发器
🥈 2. 没有 SQL Server Agent（作业调度）
🥉 3. 没有复杂的权限体系
MSSQL 有：

Server 级别权限

Database 级别权限

Schema 级别权限

Column 级别权限

🧱 4. 没有高级企业特性（MSSQL 独有）
❌ Service Broker

❌ Change Data Capture (CDC)（TiDB 有 TiCDC，但机制不同）

❌ SQL Server Audit

❌ Policy-Based Management

❌ Always Encrypted

❌ Transparent Data Encryption（TiDB 有 TDE，但实现不同）

❌ FILESTREAM / FileTable



🧩 5. 没有复杂的索引类型
MSSQL 支持：

聚集索引

非聚集索引

列存储索引

过滤索引

空间索引

XML 索引

全文索引

TiDB：

✔ B+Tree 索引

✔ 列存（TiFlash）

❌ 空间索引

❌ XML 索引

❌ 全文索引（需要外部工具）


🔥 6. 没有跨数据库事务（MSSQL 支持）
MSSQL：

✔ 分布式事务（MSDTC）

✔ 跨数据库事务


🧠 7. 没有复杂的执行计划控制
MSSQL 有：

Query Hint

Plan Guide

强制执行计划

Query Store 自动回退


🧪 8. 没有 TempDB 这种全局临时数据库
MSSQL：

TempDB 是核心组件

全局临时表

表变量

临时对象

TiDB：

❌ 无 TempDB

✔ 有普通临时表（但功能有限）



🧭 最终总结（非常明确）
TiDB 相比 MSSQL 缺少：

存储过程、函数、触发器

SQL Agent / SSIS

复杂权限体系

多种索引类型

跨数据库事务

Plan Guide / 强制执行计划

TempDB

企业级高级功能（CDC、Audit、Service Broker 等）

但 TiDB 提供 MSSQL 没有的：

分布式强一致事务

自动水平扩容

自动高可用

TiFlash 列存

Region 调度

Raft 多副本

云原生架构

# 不支持分区备份
这就是 TiDB 版的“按表备份”。

但 TiDB 不支持按分区备份（因为 TiDB 的分区是逻辑分区，不是物理 filegroup）。


#  单字段余额高频读写场合 增加业务复杂度
类似于单字段余额高频读写场合，tidb反而更慢，造成需要分片余额模式，增加业务代码逻辑复杂度。。还有哪些类似的tidb的弱点


#  🚨 TiDB 的弱点（工程师实战版）
1. 热点 Key（你提到的余额场景）
2. 单账户余额

单库存扣减

单计数器

单 ID 生成器

2. 热点范围（Range Hotspot）
   例如：

自增主键（连续写入同一个 Region）

时间序列数据（按时间递增写入）

日志类表（append-only）
解决方式：随机主键 / hash 分区 / auto_random

3. 高频小事务（OLTP 极端场景）
   例如：

每秒几十万次的 UPDATE

高频写入小行

高频点查 + 写入

4. 复杂 SQL（特别是多表 JOIN）
5. 没有存储过程 / 函数 / 触发器
      你已经知道：

逻辑必须放在应用层

无法做复杂的数据库内逻辑

无法做触发器级别的约束

迁移成本高。


6. 没有 Filegroup / 分区备份
   TiDB：

不能按分区备份

不能按 filegroup 备份

只能按表 / 库 / 全量备份

大表备份策略不如 MSSQL 灵活。

7. 没有 TempDB 这种强大的临时库
   TiDB 的临时表能力弱：

无全局临时表

无表变量

无 TempDB 优化

复杂 ETL / 报表场景不如 MSSQL。


8. 没有高级企业特性（MSSQL 独有）
   例如：

Service Broker

SQL Agent

SSIS

CLR

行级安全

列级权限

强制执行计划（Plan Guide）

Query Store 自动回退

TiDB 的功能更“云原生”，但不够“企业级”。
9. 写入延迟比单机数据库高
10. 10. 大事务性能差
        例如：

一次更新几十万行


🎯 总结：TiDB 的弱点集中在“单点高写入”和“复杂 SQL”
你可以这样理解：

TiDB 强在“分布式扩展 + 高并发 + 大数据量”，
弱在“单点高写入 + 复杂 SQL + 企业级特性”。

如果你的业务是：

单账户余额

单库存扣减

高频写入单行

高频更新计数器

高频写入 append-only

大量复杂 SQL

依赖存储过程

依赖 filegroup

依赖 TempDB

那么 MSSQL / MySQL 单机 + 分片 反而更适合。