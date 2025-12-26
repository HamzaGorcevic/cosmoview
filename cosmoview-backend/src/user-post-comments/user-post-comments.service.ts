import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';

@Injectable()
export class UserPostCommentsService {
    constructor(private readonly supabaseService: SupabaseService) { }

    async createComment(userId: string, postId: string, content: string) {
        const client = this.supabaseService.getClient();

        const { data, error } = await client
            .from('user_post_comments')
            .insert([
                {
                    user_id: userId,
                    post_id: postId,
                    content: content,
                },
            ])
            .select('*, users(username)')
            .single();

        if (error) {
            throw new Error(error.message);
        }

        return { status: true, message: 'Comment created successfully', data };
    }

    async getPostComments(postId: string) {
        const client = this.supabaseService.getClient();

        const { data, error } = await client
            .from('user_post_comments')
            .select('*, users(username)')
            .eq('post_id', postId)
            .order('created_at', { ascending: false });

        if (error) {
            throw new Error(error.message);
        }

        return { status: true, data, count: data.length };
    }

    async deleteComment(commentId: string, userId: string) {
        const client = this.supabaseService.getClient();

        // Verify the comment belongs to the user
        const { data: comment } = await client
            .from('user_post_comments')
            .select('user_id')
            .eq('id', commentId)
            .single();

        if (!comment || comment.user_id !== userId) {
            throw new Error('Unauthorized to delete this comment');
        }

        const { error } = await client
            .from('user_post_comments')
            .delete()
            .eq('id', commentId);

        if (error) {
            throw new Error(error.message);
        }

        return { status: true, message: 'Comment deleted successfully' };
    }

    async getCommentCount(postId: string) {
        const client = this.supabaseService.getClient();

        const { count, error } = await client
            .from('user_post_comments')
            .select('*', { count: 'exact', head: true })
            .eq('post_id', postId);

        if (error) {
            throw new Error(error.message);
        }

        return { status: true, count: count || 0 };
    }
}
