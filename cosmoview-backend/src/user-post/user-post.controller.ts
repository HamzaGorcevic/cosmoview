
import { UserPostService } from './user-post.service';
import { CreateUserPostDto } from './dto/create-user-post.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { Body, Controller, Get, Param, Post, UploadedFile, UseInterceptors } from '@nestjs/common';

@Controller('user-post')
export class UserPostController {
    constructor(private readonly userPostService: UserPostService) { }

    @Post()
    @UseInterceptors(FileInterceptor('file'))
    async create(
        @Body() createUserPostDto: CreateUserPostDto,
        @UploadedFile() file: Express.Multer.File,
    ) {
        return this.userPostService.create(createUserPostDto, file);
    }

    @Get()
    async findAll() {
        return this.userPostService.findAll();
    }

    @Get('user/:userId')
    async findByUser(@Param('userId') userId: string) {
        return this.userPostService.findByUser(userId);
    }
}
