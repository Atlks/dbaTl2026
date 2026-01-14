


一步到位：部署一个真正持久化的单机 TiDB
下面这套流程只需要做一次，以后你就能：

tiup cluster start tidb-local 启动

tiup cluster stop tidb-local 停止

重启 Windows 后也能恢复

这是你要的“持久化”。

① 创建拓扑文件（topology.yaml）
在 WSL 中创建：

Code
nano topology.yaml
内容：yaml

 
global:
user: root

pd_servers:
- host: 127.0.0.1

tikv_servers:
- host: 127.0.0.1

tidb_servers:
- host: 127.0.0.1
  这是一个完整的单机 TiDB。

② 部署（只需一次）
Code
tiup cluster deploy tidb-local v7.5.0 topology.yaml --user root
TiUP 会自动安装：

pd-server

tikv-server

tidb-server

并把它们放到持久化目录。

③ 启动（每次重启 Windows 后执行）
Code
tiup cluster start tidb-local
④ 连接
Code
mysql -h 127.0.0.1 -P 4000 -u root





...prblm

grep -E "PubkeyAuthentication" /etc/ssh/sshd_config
如果没有，手动加上：

Code
PubkeyAuthentication yes