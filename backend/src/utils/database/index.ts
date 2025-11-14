import { getPool } from '@/instances/database';
import sql from 'mssql';

export enum ExpectedReturn {
  Single = 'single',
  Multi = 'multi',
  None = 'none',
}

export interface IRecordSet<T = any> {
  recordset: T[];
  rowsAffected: number[];
}

export async function dbRequest(
  routine: string,
  parameters: Record<string, any>,
  expectedReturn: ExpectedReturn,
  transaction?: sql.Transaction,
  resultSetNames?: string[]
): Promise<any> {
  const pool = await getPool();
  const request = transaction ? new sql.Request(transaction) : pool.request();

  Object.entries(parameters).forEach(([key, value]) => {
    request.input(key, value);
  });

  const result = await request.execute(routine);

  if (expectedReturn === ExpectedReturn.None) {
    return null;
  }

  if (expectedReturn === ExpectedReturn.Single) {
    return result.recordset;
  }

  if (resultSetNames && resultSetNames.length > 0) {
    const namedResults: Record<string, any> = {};
    resultSetNames.forEach((name, index) => {
      namedResults[name] = result.recordsets[index];
    });
    return namedResults;
  }

  return result.recordsets;
}

export async function beginTransaction(): Promise<sql.Transaction> {
  const pool = await getPool();
  const transaction = new sql.Transaction(pool);
  await transaction.begin();
  return transaction;
}

export async function commitTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.commit();
}

export async function rollbackTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.rollback();
}
