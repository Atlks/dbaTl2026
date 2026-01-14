

SELECT TOP 10
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time_ms,
    qs.total_elapsed_time AS total_elapsed_time_ms,
       qs.execution_count,
       qs.max_elapsed_time AS max_elapsed_time_ms,
       qs.min_elapsed_time AS min_elapsed_time_ms,
       DB_NAME(qp.dbid) AS db_name,
       SUBSTRING(st.text,
                 (qs.statement_start_offset/2) + 1,
                 ((CASE qs.statement_end_offset
                       WHEN -1 THEN DATALENGTH(st.text)
                       ELSE qs.statement_end_offset
                       END - qs.statement_start_offset)/2) + 1) AS sql_text,
       qp.query_plan
FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY avg_elapsed_time_ms DESC;
