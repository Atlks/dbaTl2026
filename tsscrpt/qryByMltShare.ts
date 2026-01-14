/**
 *
 *
 * npm install mssql
 * npm install --save-dev @types/mssql
 */

import sql from 'mssql';

interface QueryOptions {
    fromTables: string;        // 'orders_202601,orders_202602'
    whereExpression?: string;  // 'WHERE status=1'
    orderbyExprs?: string;     // 'ORDER BY id DESC'
    size: number;              // 15
}


/**
 * 判断是否本地节点
 * 外部节点格式示例：
 *   Node2026.hxpay.dbo.pay_in_order_202601
 * 规则：
 *   - 本地表：没有 4 个句号
 *   - 外部表：有 4 个句号
 */
function localNode(tbl: string): boolean {
    if (!tbl) return true; // 空字符串当成本地

    const dotCount = tbl.split('.').length - 1;

    // 外部节点有 4 个句号 → 5 段
    return dotCount !== 4;
}

export async function qryWithMltShare( opts: QueryOptions) {
    const {
        fromTables,
        whereExpression = '',
        orderbyExprs = '',
        size
    } = opts;

    // 1. 拆分表名
    const tables = fromTables
        .split(',')
        .map(t => t.trim())
        .filter(t => t.length > 0);

    if (tables.length === 0) {
        throw new Error('fromTables 不能为空');
    }


    // 2. 拼接内部 UNION ALL SQL
    const innerSql = tables
        .map(tbl => {
            const baseSql = `SELECT TOP ${size} * FROM ${tbl} ${whereExpression} ${orderbyExprs}`;

            if (localNode(tbl)) {
                // 本地表
                return baseSql;
            } else {
                // 远程表 → 需要转义内部单引号
                const escaped = baseSql.replace(/'/g, "''");

                return `SELECT * FROM OPENQUERY(MyMachineName, '${escaped}')`;
            }
        })
        .join(' UNION ALL ');


    // 3. 外层再包一层 TOP + ORDER BY
    const finalSql = `
    SELECT TOP ${size} * 
    FROM (${innerSql}) AS t2 
    ${orderbyExprs}
  `;

    console.log('Generated SQL:\n', finalSql);

    // 4. 执行 SQL

    return finalSql;
}
