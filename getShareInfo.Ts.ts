import { Parser } from "node-sql-parser";
import { Pool } from "mysql2/promise";

interface ShardInfo {
    uid: number;
    node_ip: string;
    table_name: string;
}

const shardConfigDB = new Pool({
    host: "config-db-ip",
    user: "root",
    password: "xxx",
    database: "shard_meta",
});

const shardNodes = [
    { ip: "10.0.0.1", pool: new Pool({ host: "10.0.0.1", user: "root", database: "app" }) },
    { ip: "10.0.0.2", pool: new Pool({ host: "10.0.0.2", user: "root", database: "app" }) },
];

async function routeSQL(sql: string) {
    const ast = parse(sql);
    const uid = extractUid(ast);

    if (!uid) throw new Error("SQL 中没有 uid，无法分片");

    let shard = await getShard(uid);

    if (!shard) {
        shard = await createShard(uid);
    }

    const node = shardNodes.find(n => n.ip === shard.node_ip);
    if (!node) throw new Error("找不到分片节点");

    const realSQL = sql.replace(/user_table/g, shard.table_name);
    return node.pool.query(realSQL);
}

routeSQL("insert ords(uid,oid)values('007',202601111").then(r => console.log(r))


async function getShard(uid: number): Promise<ShardInfo | null> {
    const [rows] = await shardConfigDB.query(
        "SELECT * FROM shard_map WHERE uid = ? LIMIT 1",
        [uid]
    );
    return rows[0] || null;
}


//并发安全（唯一约束 + 重试）
async function createShard(uid: number): Promise<ShardInfo> {
    const node = shardNodes[Math.floor(Math.random() * shardNodes.length)];
    const tableName = "user_" + getCurrentMonth();

    try {
        await shardConfigDB.query(
            "INSERT INTO shard_map(uid, node_ip, table_name) VALUES(?,?,?)",
            [uid, node.ip, tableName]
        );
    } catch (e) {
        // 并发写入时，另一条已经插入 → 重试获取
        return await getShard(uid);
    }

    return { uid, node_ip: node.ip, table_name: tableName };
}

function getCurrentMonth() {
    const d = new Date();
    return `${d.getFullYear()}_${d.getMonth() + 1}`;
}

function extractUid(ast: any): number {
    // 简化版：从 WHERE uid = xxx 中提取
    // 真实项目建议使用完整 SQL parser
    const where = ast.where;
    if (where && where.left?.name === "uid") {
        return Number(where.right.value);
    }
    return 0;
}
