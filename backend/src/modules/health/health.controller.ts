import { Controller, Post, Get, Body, UseGuards, Request } from '@nestjs/common';
import { HealthService } from './health.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('health')
@UseGuards(AuthGuard('jwt'))
export class HealthController {
    constructor(private readonly healthService: HealthService) { }

    @Post('sync')
    async logData(@Request() req, @Body() body: { data: any[] }) {
        // In a real app, 'data' would be validated against a DTO
        // Here we treat it as a generic JSON array
        return this.healthService.logData(req.user.userId, body.data);
    }

    @Get()
    async getLogs(@Request() req) {
        return this.healthService.getLogs(req.user.userId);
    }
}
