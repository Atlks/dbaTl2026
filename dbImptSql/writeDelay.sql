

SELECT      TOP (100) PERCENT DB_NAME(vfs.database_id) AS 数据库, vfs.file_id, mf.type_desc AS 文件类型,

            vfs.io_stall_read_ms / NULLIF (vfs.num_of_reads, 0) AS 平均读延迟_ms, vfs.num_of_writes AS 写入次数,
            vfs.num_of_bytes_written / 1024 / 1024 AS 累计写入_MB, vfs.io_stall_write_ms AS 写入总延迟_ms,
            vfs.io_stall_write_ms / NULLIF (vfs.num_of_writes, 0) AS 平均写延迟_ms
FROM          sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs INNER JOIN
              sys.master_files AS mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
ORDER BY 写入总延迟_ms DESC