import { Controller, Get, Param, Query } from '@nestjs/common';
import { NasaService } from './nasa.service';

@Controller('nasa')
export class NasaController {
    constructor(private readonly nasaService: NasaService) { }

    @Get('apod')
    async getAstronomyPictureOfTheDay(@Query('date') date?: string) {
        const data = await this.nasaService.getAstronomyPictureOfTheDay(date);
        return { status: true, data };
    }

    @Get('posts')
    async getAllPosts(@Query('limit') limit?: string, @Query('offset') offset?: string) {
        const limitNum = limit ? parseInt(limit, 10) : 10;
        const offsetNum = offset ? parseInt(offset, 10) : 0;
        const posts = await this.nasaService.getAllPosts(limitNum, offsetNum);
        return { status: true, data: posts, count: posts.length };
    }

    @Get('posts/:date')
    async getPostByDate(@Param('date') date: string) {
        const post = await this.nasaService.getPostByDate(date);
        return { status: true, data: post };
    }



}
