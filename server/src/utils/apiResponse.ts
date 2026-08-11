import { Response } from 'express';

export interface IApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  meta?: any;
}

export class ApiResponse {
  static success<T>(
    res: Response,
    message: string,
    data?: T,
    statusCode = 200,
    meta?: any
  ): Response {
    const payload: IApiResponse<T> = {
      success: true,
      message,
      ...(data !== undefined && { data }),
      ...(meta !== undefined && { meta }),
    };
    return res.status(statusCode).json(payload);
  }

  static created<T>(res: Response, message: string, data?: T): Response {
    return ApiResponse.success(res, message, data, 201);
  }

  static error(
    res: Response,
    message: string,
    statusCode = 500,
    errors: any[] = []
  ): Response {
    return res.status(statusCode).json({
      success: false,
      message,
      ...(errors.length > 0 && { errors }),
    });
  }
}
