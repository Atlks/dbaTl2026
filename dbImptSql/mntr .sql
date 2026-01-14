


写个视图，，列出每个数据库文件大小，数据实际占用的体积，空余体积
下面给你一段可直接创建视图的 MSSQL 脚本，能列出每个数据库文件的：

文件大小（MB）

已使用空间（MB）

空余空间（MB）

这是 DBA 最常用的写法，适合开发自查和监控。

📌 视图：列出每个数据库文件大小 / 已用 / 空余
sql
CREATE VIEW dbo.v_DatabaseFileUsage
AS
SELECT
    DB_NAME(database_id) AS DatabaseName,
    name AS FileName,
    type_desc AS FileType,
        size * 8 / 1024 AS FileSizeMB,
        FILEPROPERTY(name, 'SpaceUsed') * 8 / 1024 AS UsedSpaceMB,
        (size - FILEPROPERTY(name, 'SpaceUsed')) * 8 / 1024 AS FreeSpaceMB,
        physical_name AS PhysicalPath
        FROM sys.master_files;
GO
📊 查询视图
sql
SELECT *
FROM dbo.v_DatabaseFileUsage
ORDER BY DatabaseName, FileType;
🧠 字段说明（开发者易懂版）
size：文件当前大小（单位：8KB 页）

FILEPROPERTY(name, 'SpaceUsed')：实际使用的页数

8 / 1024：把页数转换成 MB