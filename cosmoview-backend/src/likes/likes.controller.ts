import { Body, Controller, Delete, Get, Param, Post } from '@nestjs/common';
import { LikesService } from './likes.service';

@Controller('likes')
export class LikesController {
    constructor(private readonly likesService: LikesService) {}

    @Post()
    async likePost(@Body() body: { userId: string; postId: string }) {
        const result = await this.likesService.likePost(body.userId, body.postId);
        return { status: true, message: result };
    }

    @Delete()
    async unlikePost(@Body() body: { userId: string; postId: string }) {
        const result = await this.likesService.unlikePost(body.userId, body.postId);
        return { status: true, message: result };
    }

    @Get('post/:postId')
    async getPostLikes(@Param('postId') postId: string) {
        const likes = await this.likesService.getPostLikes(postId);
        return { status: true, data: likes, count: likes.length };
    }

    @Get('user/:userId')
    async getUserLikedPosts(@Param('userId') userId: string) {
        const postIds = await this.likesService.getUserLikedPosts(userId);
        return { status: true, data: postIds };
    }

    @Get('check/:userId/:postId')
    async checkIfLiked(@Param('userId') userId: string, @Param('postId') postId: string) {
        const isLiked = await this.likesService.isPostLikedByUser(userId, postId);
        return { status: true, isLiked };
    }
}
