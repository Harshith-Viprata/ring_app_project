import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class DevicesService {
    constructor(private prisma: PrismaService) { }

    async bindDevice(userId: string, deviceId: string, name: string) {
        return this.prisma.device.upsert({
            where: { id: deviceId },
            update: { userId, name },
            create: { id: deviceId, name, userId },
        });
    }

    async getUserDevices(userId: string) {
        return this.prisma.device.findMany({ where: { userId } });
    }
}
