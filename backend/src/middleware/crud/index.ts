import { Request } from 'express';
import { z, ZodSchema } from 'zod';
import { ApiError } from '@/middleware/error';

export interface CrudPermission {
  securable: string;
  permission: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE';
}

export interface ValidatedRequest<T = any> {
  credential: {
    idAccount: number;
    idUser: number;
  };
  params: T;
}

export class CrudController {
  private permissions: CrudPermission[];

  constructor(permissions: CrudPermission[]) {
    this.permissions = permissions;
  }

  async create<T>(
    req: Request,
    schema: ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | null, ApiError | null]> {
    return this.validateRequest(req, schema, 'CREATE');
  }

  async read<T>(
    req: Request,
    schema: ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | null, ApiError | null]> {
    return this.validateRequest(req, schema, 'READ');
  }

  async update<T>(
    req: Request,
    schema: ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | null, ApiError | null]> {
    return this.validateRequest(req, schema, 'UPDATE');
  }

  async delete<T>(
    req: Request,
    schema: ZodSchema<T>
  ): Promise<[ValidatedRequest<T> | null, ApiError | null]> {
    return this.validateRequest(req, schema, 'DELETE');
  }

  private async validateRequest<T>(
    req: Request,
    schema: ZodSchema<T>,
    permission: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE'
  ): Promise<[ValidatedRequest<T> | null, ApiError | null]> {
    try {
      const idAccount = 1;
      const idUser = 1;

      const params = await schema.parseAsync({
        ...req.params,
        ...req.query,
        ...req.body,
      });

      return [
        {
          credential: { idAccount, idUser },
          params,
        },
        null,
      ];
    } catch (error: any) {
      const apiError: ApiError = new Error('Validation failed');
      apiError.statusCode = 400;
      apiError.code = 'VALIDATION_ERROR';
      apiError.details = error.errors;
      return [null, apiError];
    }
  }
}

export function successResponse<T>(data: T, metadata?: any) {
  return {
    success: true,
    data,
    metadata: {
      ...metadata,
      timestamp: new Date().toISOString(),
    },
  };
}

export function errorResponse(message: string, code?: string) {
  return {
    success: false,
    error: {
      code: code || 'ERROR',
      message,
    },
    timestamp: new Date().toISOString(),
  };
}

export const StatusGeneralError: ApiError = {
  name: 'GeneralError',
  message: 'An unexpected error occurred',
  statusCode: 500,
  code: 'GENERAL_ERROR',
};
