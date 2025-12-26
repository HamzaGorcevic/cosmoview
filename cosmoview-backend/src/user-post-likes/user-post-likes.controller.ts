import { Body, Controller, Delete, Get, Param, Post } from '@nestjs/common';
import { UserPostLikesService } from './user-post-likes.service';

@Controller('user-post-likes')
export class UserPostLikesController {
    constructor(private readonly userPostLikesService: UserPostLikesService) { }

    @Post()
    async likePost(@Body() body: { userId: string; postId: string }) {
        return this.userPostLikesService.likePost(body.userId, body.postId);
    }

    @Delete()
    async unlikePost(@Body() body: { userId: string; postId: string }) {
        return this.userPostLikesService.unlikePost(body.userId, body.postId);
    }

    @Get('post/:postId')
    async getPostLikes(@Param('postId') postId: string) {
        return this.userPostLikesService.getPostLikes(postId);
    }

    @Get('check/:userId/:postId')
    async checkIfLiked(
        @Param('userId') userId: string,
        @Param('postId') postId: string,
    ) {
        return this.userPostLikesService.checkIfLiked(userId, postId);
    }

    @Get('count/:postId')
    async getLikeCount(@Param('postId') postId: string) {
        return this.userPostLikesService.getLikeCount(postId);
    }
}
