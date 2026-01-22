import { Controller, Post, Get, Body, UseGuards, Request } from '@nestjs/common';
import { DevicesService } from './devices.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('devices')
@UseGuards(AuthGuard('jwt'))
export class DevicesController {
    constructor(private readonly devicesService: DevicesService) { }

    @Post('bind')
    async bindDevice(@Request() req, @Body() body: { deviceId: string; name: string }) {
        return this.devicesService.bindDevice(req.user.userId, body.deviceId, body.name);
    }

    @Get()
    async getDevices(@Request() req) {
        return this.devicesService.getUserDevices(req.user.userId);
    }
}
