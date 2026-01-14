
-- 最终还要关注磁盘钟占用..locks ,trsx, conns,,and write delay



--## dsk use
SELECT DISTINCT
    vs.volume_mount_point AS [DiskMountPoint],
    vs.logical_volume_name AS [DiskName],
    vs.total_bytes / 1024 / 1024 / 1024 AS [TotalGB],      -- 磁盘总容量 (GB)
    vs.available_bytes / 1024 / 1024 / 1024 AS [FreeGB],   -- 磁盘剩余空间 (GB)
    (vs.total_bytes - vs.available_bytes) / 1024 / 1024 / 1024 AS [UsedGB] -- 已用空间 (GB)
FROM sys.master_files AS mf
    CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS vs


--## mnt locks and trx

SELECT
    tl.request_session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    tl.resource_type,
    tl.resource_description,
    tl.request_mode,
    tl.request_status,
    r.status AS rq_request_status,
    r.command,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.wait_resource,
    st.text AS sql_text
FROM sys.dm_tran_locks AS tl
         JOIN sys.dm_exec_sessions AS s
              ON tl.request_session_id = s.session_id
         LEFT JOIN sys.dm_exec_requests AS r
                   ON tl.request_session_id = r.session_id
    OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st


---##  show trxs
SELECT
    r.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    r.status,
    r.command,
    r.transaction_id,
    s.transaction_isolation_level,
    s.open_transaction_count,
    r.start_time AS [TransactionStartTime],
    DATEDIFF(SECOND, r.start_time, GETDATE()) AS [ElapsedSeconds], -- 已执行秒数
    st.text AS [SqlText]
FROM sys.dm_exec_requests AS r
    JOIN sys.dm_exec_sessions AS s
ON r.session_id = s.session_id
    OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE r.session_id <> @@SPID   -- 排除当前会话
  and s.is_user_process = 1; -- 只看用户进程




--## wrte delay

SELECT
    DB_NAME(database_id) AS [数据库],
    file_id,
    num_of_writes AS [写入次数],
    (num_of_bytes_written / 1024 / 1024) AS [累计写入_MB],
    io_stall_write_ms AS [写入总延迟_ms],
    (io_stall_write_ms / NULLIF(num_of_writes, 0)) AS [平均写延迟_ms]
FROM sys.dm_io_virtual_file_stats(DB_ID('HxPay'), NULL);




SELECT
    [Drive] = LEFT(physical_name, 2),
    [Avg_Write_Latency_ms] = CASE WHEN num_of_writes = 0 THEN 0 ELSE (io_stall_write_ms / num_of_writes) END,
    [Avg_Read_Latency_ms] = CASE WHEN num_of_reads = 0 THEN 0 ELSE (io_stall_read_ms / num_of_reads) END,
    [Resource_Wait_Type] = CASE
        WHEN (io_stall_write_ms / NULLIF(num_of_writes, 0)) > 20 THEN '磁盘写入瓶颈'
        ELSE '正常' END
FROM sys.dm_io_virtual_file_stats(DB_ID('HxPay'), NULL) AS vfs
JOIN sys.master_files AS mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id;

-- ##  conns



SELECT
    c.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    c.client_net_address,
    s.status,
    s.cpu_time,
    s.memory_usage,
    s.reads,
    s.writes,
    r.status AS request_status,
    r.command,
    r.blocking_session_id,
    r.wait_type,
    r.wait_time,
    r.wait_resource
FROM sys.dm_exec_connections AS c
         JOIN sys.dm_exec_sessions AS s
              ON c.session_id = s.session_id
         LEFT JOIN sys.dm_exec_requests AS r
                   ON c.session_id = r.session_id
