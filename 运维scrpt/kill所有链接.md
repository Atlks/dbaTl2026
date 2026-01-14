


你必须让数据库里没有任何活动会话，才能成功启用 RCSI。

🧭 如何解决（非常实用的步骤）
✔️ 方案 1：在业务低峰期，强制断开所有连接（推荐）
sql
ALTER DATABASE hxpay SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE hxpay SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE hxpay SET MULTI_USER;
解释：

SINGLE_USER 会断开所有连接

ROLLBACK IMMEDIATE 会回滚所有未提交事务

然后你就能成功启用 RCSI

最后再切回 MULTI_USER

⚠️ 注意：这会中断业务，需要在低峰期执行



🎯 最终解决方案（你必须做的）
要启用 RCSI，你必须让数据库里 没有任何连接。

最干净的方式：

sql
