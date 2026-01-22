import { Controller, Request, Post, UseGuards, Body, Get } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthGuard } from '@nestjs/passport';
import { Prisma } from '@prisma/client';

@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) { }

    @Post('login')
    async login(@Body() req) {
        return this.authService.validateUser(req.email, req.password).then((user) => {
            if (!user) {
                throw new Error('Invalid credentials');
            }
            return this.authService.login(user);
        });
    }

    @Post('register')
    async register(@Body() createUserDto: Prisma.UserCreateInput) {
        return this.authService.register(createUserDto);
    }

    @UseGuards(AuthGuard('jwt'))
    @Get('profile')
    getProfile(@Request() req) {
        return req.user;
    }
}
