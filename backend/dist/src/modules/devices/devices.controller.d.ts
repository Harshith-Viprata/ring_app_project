import { DevicesService } from './devices.service';
export declare class DevicesController {
    private readonly devicesService;
    constructor(devicesService: DevicesService);
    bindDevice(req: any, body: {
        deviceId: string;
        name: string;
    }): Promise<{
        name: string;
        id: string;
        userId: string;
    }>;
    getDevices(req: any): Promise<{
        name: string;
        id: string;
        userId: string;
    }[]>;
}
