


3. 让恢复速度快很多
   如果数据库崩了：

你可以先恢复 PRIMARY（小）

业务先恢复运行

再慢慢恢复大 filegroup（后台进行）

这叫 piecemeal restore，是 SQL Server 的杀手级功能。



🧨 那什么时候一个表一个 Filegroup？
只有一种情况：

你想让某个表可以单独备份、单独恢复、单独放磁盘。

例如：

一个 500GB 的大表

其他表都很小

你想让备份更快

你想让恢复更快

这时才会给它一个独立 filegroup。

🎯 最终结论（非常明确）
一个 filegroup 可以放多个表（最常见）
一个表也可以独占一个 filegroup（大表场景）

一个表也可以放在多个 filegroup（如果是分区表）

