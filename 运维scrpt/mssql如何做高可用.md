
配置步骤（极简版）
① 两台 Windows 建集群（WSFC）

文件共享仲裁（3 步搞定）

② 安装 SQL Server（同版本）
③ 勾选 Always On
SQL Server 配置管理器 → 启用 Always On

④ 新建 AG（向导）

同步提交

自动切换

建 Listener

👉 结束




常见误区（避免复杂化）

❌ 三节点（没必要）
❌ 加异步副本（需求不符）
❌ 上共享存储
❌ 手工切换脚本




退而求其次（如果你真要“更简单”）

日志传送 + 人工切换





一、HA 监控要盯什么？（先给结论）

只盯 5 件事，就够了

序号	监控项	说明
1️⃣	AG 副本状态	是否 Healthy
2️⃣	数据同步状态	是否同步中
3️⃣	角色变化	是否发生切换
4️⃣	同步延迟	是否积压
5️⃣	Listener 状态	应用是否还能连




正常状态应该是：
role_desc = PRIMARY / SECONDARY
connected_state_desc = CONNECTED
synchronization_health_desc = HEALTHY


🚨 只要不是 HEALTHY，就是告警

2️⃣ 数据库同步状态
SELECT
db_name(drs.database_id) AS db_name,
drs.synchronization_state_desc,
drs.synchronization_health_desc,
drs.is_suspended
FROM sys.dm_hadr_database_replica_states drs;

正常：
synchronization_state_desc = SYNCHRONIZED
synchronization_health_desc = HEALTHY
is_suspended = 0

3️⃣ 同步延迟（判断“假同步”）
SELECT
db_name(database_id) AS db_name,
log_send_queue_size,        -- 待发送日志(KB)
redo_queue_size             -- 待重做日志(KB)
FROM sys.dm_hadr_database_replica_states;


经验值：

log_send_queue_size > 100MB ⚠️

redo_queue_size > 100MB ⚠️

三、切换监控（你一定要知道什么时候切了）
查看最近是否发生故障切换
SELECT
ag.name,
ars.replica_server_name,
ars.role_desc,
ars.role_change_time
FROM sys.dm_hadr_availability_replica_states ars
JOIN sys.availability_groups ag
ON ars.group_id = ag.group_id
ORDER BY ars.role_change_time DESC;


📌 一旦发生切换，一定要告警 + 记录

四、Listener 监控（应用视角）
1️⃣ SQL 内部检查
SELECT dns_name, port
FROM sys.availability_group_listeners;

2️⃣ 运维侧建议

TCP 端口探活（1433/自定义）

应用定期执行：

SELECT 1;


📌 Listener 不通 = HA 失败

五、SQL Server 自带告警（最省事）
强烈推荐：SQL Agent 告警（不用写系统）
常用错误号：
错误号	含义
1480	AG 角色变化
35264	数据同步暂停
35265	数据同步恢复
创建告警（示例）
EXEC msdb.dbo.sp_add_alert
@name = N'AG Role Changed',
@message_id = 1480,
@severity = 0,
@enabled = 1;


📌 配合：

邮件

企业微信

钉钉

六、最简自动巡检脚本（推荐每天跑）
IF EXISTS (
SELECT 1
FROM sys.dm_hadr_availability_replica_states
WHERE synchronization_health_desc <> 'HEALTHY'
)
BEGIN
RAISERROR ('AG Health Check Failed', 16, 1);
END


放 SQL Agent Job

失败即告警

七、第三方监控（可选，但很好用）

如果你不想自己拼：

工具


八、最省运维的“黄金组合”

SQL Agent + DMV + 邮件