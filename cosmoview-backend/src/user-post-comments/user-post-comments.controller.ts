import { Body, Controller, Delete, Get, Param, Post } from '@nestjs/common';
import { UserPostCommentsService } from './user-post-comments.service';

@Controller('user-post-comments')
export class UserPostCommentsController {
    constructor(
        private readonly userPostCommentsService: UserPostCommentsService,
    ) { }

    @Post()
    async createComment(
        @Body() body: { userId: string; postId: string; content: string },
    ) {
        return this.userPostCommentsService.createComment(
            body.userId,
            body.postId,
            body.content,
        );
    }

    @Get('post/:postId')
    async getPostComments(@Param('postId') postId: string) {
        return this.userPostCommentsService.getPostComments(postId);
    }

    @Delete(':commentId')
    async deleteComment(
        @Param('commentId') commentId: string,
        @Body() body: { userId: string },
    ) {
        return this.userPostCommentsService.deleteComment(commentId, body.userId);
    }

    @Get('count/:postId')
    async getCommentCount(@Param('postId') postId: string) {
        return this.userPostCommentsService.getCommentCount(postId);
    }
}
