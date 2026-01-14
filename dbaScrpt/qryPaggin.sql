
USE [HxPay]
GO
/****** Object:  StoredProcedure [dbo].[qryByMonthShareV2]    Script Date: 1/14/2026 2:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[qryByMonthShareV2]
    @fromTables      NVARCHAR(MAX),   -- 分片表名字符串，例如 'orders_202601,orders_202602'
    @whereExpression NVARCHAR(MAX) = '', -- 附加条件，例如 'WHERE status=1'
    @orderbyExprs    NVARCHAR(MAX) = '', -- 排序表达式，例如 'ORDER BY id DESC'
    @size      int       -- 查询字段列表，例如 '15'
  --  ,@lastid BIGINT   --pagging currse 翻页游标
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);

    ;WITH tbl AS (
    SELECT LTRIM(RTRIM(value)) AS tblname
    FROM STRING_SPLIT(@fromTables, ',')
    WHERE LTRIM(RTRIM(value)) <> ''
)
     SELECT @sql = STRING_AGG(
             'SELECT top ' + CAST(@size AS NVARCHAR(20))+ ' *  FROM ' + QUOTENAME(tblname) + ' '
                 + ISNULL(@whereExpression,'') + ' ' + ISNULL(@orderbyExprs,''),
             ' UNION ALL '
                   )
     FROM tbl;

-- 外层再包一层查询，便于统一排序或分页
SET @sql = 'SELECT top ' + CAST(@size AS NVARCHAR(20)) + ' *  FROM (' + @sql + ') AS t2 ' + ISNULL(@orderbyExprs,'');

    PRINT @sql;  -- 调试用，输出最终 SQL

EXEC sp_executesql @sql;
END

