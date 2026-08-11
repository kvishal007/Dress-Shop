import { AuditLog, IAuditLog } from './audit.model';

export interface ICreateAuditLogInput {
  userId?: string;
  userName?: string;
  userRole?: string;
  action: string;
  entity: string;
  entityId?: string;
  oldValue?: any;
  newValue?: any;
  ipAddress?: string;
  userAgent?: string;
}

export class AuditService {
  static async log(input: ICreateAuditLogInput): Promise<IAuditLog> {
    try {
      const logEntry = new AuditLog(input);
      return await logEntry.save();
    } catch (error) {
      console.error('[Audit Log Error]: Failed to create audit log', error);
      // Non-blocking audit failure
      return null as any;
    }
  }
}
