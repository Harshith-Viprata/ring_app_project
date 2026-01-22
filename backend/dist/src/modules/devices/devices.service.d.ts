import { PrismaService } from '../../prisma/prisma.service';
export declare class DevicesService {
    private prisma;
    constructor(prisma: PrismaService);
    bindDevice(userId: string, deviceId: string, name: string): Promise<{
        name: string;
        id: string;
        userId: string;
    }>;
    getUserDevices(userId: string): Promise<{
        name: string;
        id: string;
        userId: string;
    }[]>;
}
