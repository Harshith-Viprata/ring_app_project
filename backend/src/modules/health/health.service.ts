import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class HealthService {
    constructor(private prisma: PrismaService) { }

    async logData(userId: string, data: Prisma.JsonArray) {
        return this.prisma.healthLog.create({
            data: {
                userId,
                data,
            },
        });
    }

    async getLogs(userId: string) {
        return this.prisma.healthLog.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: 20,
        });
    }
}
