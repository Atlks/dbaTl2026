
qidong

tiup playground  ...only mem 

🟦 单机模式（非 TiUP 集群）如何启动 TiDB
你只需要启动 一个进程：

bash
tidb-server --store=mocktikv --log-file=tidb.log &
这是 TiDB 的 内置单机模式（不需要 PD、不需要 TiKV）。

你之前能连上 4000 端口，就是因为你跑的是这个模式。



🟦 tidb-server 本身只有两种模式
tidb-server 是 TiDB 的 SQL 层，它本身不存储数据。
它有两种运行方式：

① 真实集群模式（生产模式）
Code
tidb-server --store=tikv --path="127.0.0.1:2379"