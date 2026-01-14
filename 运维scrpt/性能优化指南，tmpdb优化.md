
高 TempDB 压力场景”，需要进一步优化。

下面我给你一个非常清晰的诊断路径，让你一步步定位问题。

🧩 第一步：确认 TempDB 文件是否“均衡使用”
即使你有 8 个文件，如果 SQL Server 只用其中 1～2 个，仍然会争用。

运行这个：

sql
SELECT
file_id,
num_of_reads,
num_of_writes
FROM sys.dm_io_virtual_file_stats(2, NULL)
ORDER BY num_of_writes DESC;
如果你看到：

1～2 个文件写入量远高于其他文件
→ 文件不均衡，仍然会争用

解决方式：

确保所有文件 大小一致

确保所有文件 增长方式一致

重启 SQL Server（TempDB 重建后才会均衡）

🧩 第二步：确认是否是“元数据争用”
如果你有大量临时表创建/删除，会导致：

PFS/GAM/SGAM 争用

系统表（sysobjvalues）争用

运行：

sql
SELECT
wait_type,
waiting_tasks_count,
wait_time_ms,
resource_description
FROM sys.dm_os_waiting_tasks
WHERE wait_type LIKE 'LATCH_%'
AND resource_description LIKE '2:%';
如果出现：

LATCH_EX

LATCH_SH

resource_description 包含 2:（TempDB）

说明是 元数据争用。

解决方式：

减少临时表创建/删除

避免表变量滥用

避免频繁创建 #temp 索引

避免游标

🧩 第三步：检查是否有大量排序 / 哈希溢出（spill）
如果你的 SQL 频繁 spill 到 TempDB，会导致 PAGELATCH 争用。

运行：

sql
SELECT
session_id,
request_id,
total_spills,
last_spill_time
FROM sys.dm_exec_query_memory_grants
WHERE total_spills > 0;
如果有大量 spill：

增加内存

优化 SQL（减少排序、哈希）

增加合适索引

避免 SELECT DISTINCT

避免大 GROUP BY

🧩 第四步：检查是否是版本存储（Version Store）压力
如果你启用了：

RCSI

Snapshot

Online Index Rebuild

TempDB 会存储版本行。

运行：

sql
SELECT
SUM(version_store_reserved_page_count) * 8 / 1024 AS VersionStoreMB
FROM sys.dm_db_file_space_usage;
如果 VersionStoreMB 很大（> 500MB），说明：

大量更新

大量长事务

大量 RCSI 读

解决方式：

避免长事务

避免大批量更新

优化索引重建策略

必要时关闭 RCSI（谨慎）

🧩 第五步：检查 TempDB 日志（templog）是否瓶颈
运行：

sql
SELECT *
FROM sys.dm_os_wait_stats
WHERE wait_type = 'WRITELOG';
如果 WRITELOG 很高：

TempDB 日志盘太慢

TempDB 日志太小

自动增长频繁

解决方式：

把 templog 放到最快磁盘

固定大小（例如 2GB）

固定增长（256MB）

🎯 最终判断：你属于哪种 TempDB 争用？
根据你的等待数据：

PAGELATCH_SH：非常高

PAGELATCH_EX：非常高

PAGELATCH_UP：有但不多

这通常意味着：

你的系统存在大量 TempDB 分配页争用（PFS/GAM/SGAM），而不是文件数量不足。

🧠 下一步建议（按优先级）
⭐ 必做（最有效）
确保 8 个文件大小一致

确保增长方式一致

重启 SQL Server（TempDB 重建）

检查是否有大量临时表创建/删除

检查是否有大量 spill

检查是否有长事务导致版本存储膨胀

⭐ 可选（视情况）
增加到 12 个 TempDB 文件（如果 8 个仍争用）

增加内存

优化 SQL（减少排序/哈希）

优化 RCSI 使用场景