import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { DevicesModule } from './modules/devices/devices.module';
import { HealthModule } from './modules/health/health.module';

@Module({
  imports: [AuthModule, UsersModule, DevicesModule, HealthModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
