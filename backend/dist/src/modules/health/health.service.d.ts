import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';
export declare class HealthService {
    private prisma;
    constructor(prisma: PrismaService);
    logData(userId: string, data: Prisma.JsonArray): Promise<{
        id: string;
        data: Prisma.JsonValue;
        userId: string;
        createdAt: Date;
    }>;
    getLogs(userId: string): Promise<{
        id: string;
        data: Prisma.JsonValue;
        userId: string;
        createdAt: Date;
    }[]>;
}
