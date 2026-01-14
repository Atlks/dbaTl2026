

# 一个节点 10tb

# 每天一个亿数据就是10g，每年3tb

# mssql 可以支持几十tb
普通数据库不超10tb

#  备份太大怎么办 分区备份

🪟 SQL Server (MSSQL)
支持 filegroup

每个分区可以放在不同 filegroup

可以只备份某个 filegroup

这是企业级数据库里最成熟的“按分区备份”方案。