import { Body, Controller, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() body: { username: string; email: string; password: string }) {
    return this.authService.createUser(body.username, body.email, body.password);
  }

  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    return this.authService.loginUser(body.email, body.password);
  }

  @Post('change-password')
  async changePassword(@Body() body: { userId: string; oldPassword: string; newPassword: string }) {
    return this.authService.changePassword(body.userId, body.oldPassword, body.newPassword);
  }
}