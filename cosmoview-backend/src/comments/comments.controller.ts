import { Body, Controller, Delete, Get, Param, Post, Put } from '@nestjs/common';
import { CommentsService } from './comments.service';

@Controller('comments')
export class CommentsController {
    constructor(private readonly commentsService: CommentsService) {}

    @Post()
    async createComment(@Body() body: { userId: string; postId: string; content: string; parentId?: string }) {
        const comment = await this.commentsService.createComment(
            body.userId,
            body.postId,
            body.content,
            body.parentId
        );
        return { status: true, data: comment };
    }

    @Get('post/:postId')
    async getPostComments(@Param('postId') postId: string) {
        const comments = await this.commentsService.getPostComments(postId);
        return { status: true, data: comments, count: comments.length };
    }

    @Get('comment/:commentId/replies')
    async getCommentReplies(@Param('commentId') commentId: string) {
        const replies = await this.commentsService.getCommentReplies(commentId);
        return { status: true, data: replies, count: replies.length };
    }

    @Put(':commentId')
    async updateComment(
        @Param('commentId') commentId: string,
        @Body() body: { userId: string; content: string }
    ) {
        const comment = await this.commentsService.updateComment(commentId, body.userId, body.content);
        if (!comment) {
            return { status: false, message: 'Failed to update comment or unauthorized' };
        }
        return { status: true, data: comment };
    }

    @Delete(':commentId')
    async deleteComment(
        @Param('commentId') commentId: string,
        @Body() body: { userId: string; isAdmin?: boolean }
    ) {
        const result = await this.commentsService.deleteComment(commentId, body.userId, body.isAdmin || false);
        return { status: true, message: result };
    }

    @Get(':commentId')
    async getComment(@Param('commentId') commentId: string) {
        const comment = await this.commentsService.getCommentById(commentId);
        return { status: true, data: comment };
    }
}

