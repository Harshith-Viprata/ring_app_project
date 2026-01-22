import { HealthService } from './health.service';
export declare class HealthController {
    private readonly healthService;
    constructor(healthService: HealthService);
    logData(req: any, body: {
        data: any[];
    }): Promise<{
        id: string;
        data: import("@prisma/client/runtime/library").JsonValue;
        userId: string;
        createdAt: Date;
    }>;
    getLogs(req: any): Promise<{
        id: string;
        data: import("@prisma/client/runtime/library").JsonValue;
        userId: string;
        createdAt: Date;
    }[]>;
}
