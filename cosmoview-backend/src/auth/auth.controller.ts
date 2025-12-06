import { Body, Controller,Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
    constructor(private readonly authService:AuthService){}
    @Post('register')
    async register(@Body() body:{username:string,email:string,password:string}){
        const data =await this.authService.createUser(body.username,body.email,body.password);
        return {data:data,message:"User registration initiated",status:true};
    }
    @Post('login')
    async login(@Body() body:{email:string,password:string}){
        const data = await this.authService.loginUser(body.email,body.password);
        return {data:data,message:"User login initiated",status:true};
    }
    @Post('change-password')
    async changePassword(@Body() body:{userId:string,oldPassword:string,newPassword:string}){
        const data = await this.authService.changePassword(body.userId,body.oldPassword,body.newPassword);
        return {data:data,message:"Password change initiated",status:true};
    }
}
