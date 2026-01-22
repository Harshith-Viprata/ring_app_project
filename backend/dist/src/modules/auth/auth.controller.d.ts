import { AuthService } from './auth.service';
import { Prisma } from '@prisma/client';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    login(req: any): Promise<{
        access_token: string;
    }>;
    register(createUserDto: Prisma.UserCreateInput): Promise<{
        access_token: string;
    }>;
    getProfile(req: any): any;
}
