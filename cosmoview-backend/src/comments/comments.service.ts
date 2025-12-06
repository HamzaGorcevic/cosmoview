import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';

@Injectable()
export class CommentsService {
    constructor(private readonly supabaseService: SupabaseService) {}

    async createComment(userId: string, postId: string, content: string, parentId?: string) {
        const commentData: any = {
            user_id: userId,
            post_id: postId,
            content: content
        };

        if (parentId) {
            commentData.parent_id = parentId;
        }

        const { data, error } = await this.supabaseService.getClient()
            .from('comments')
            .insert([commentData])
            .select(`
                id,
                user_id,
                post_id,
                parent_id,
                content,
                created_at,
                updated_at,
                users:user_id (
                    id,
                    username,
                    email
                )
            `)
            .single();

        if (error) {
            console.error('Error creating comment:', error);
            return null;
        }

        return data;
    }

    async getPostComments(postId: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('comments')
            .select(`
                id,
                user_id,
                post_id,
                parent_id,
                content,
                created_at,
                updated_at,
                users:user_id (
                    id,
                    username,
                    email
                )
            `)
            .eq('post_id', postId)
            .is('parent_id', null)
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching comments:', error);
            return [];
        }

        // Fetch replies for each comment
        const commentsWithReplies = await Promise.all(
            (data || []).map(async (comment) => {
                const replies = await this.getCommentReplies(comment.id);
                return { ...comment, replies };
            })
        );

        return commentsWithReplies;
    }

    async getCommentReplies(commentId: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('comments')
            .select(`
                id,
                user_id,
                post_id,
                parent_id,
                content,
                created_at,
                updated_at,
                users:user_id (
                    id,
                    username,
                    email
                )
            `)
            .eq('parent_id', commentId)
            .order('created_at', { ascending: true });

        if (error) {
            console.error('Error fetching replies:', error);
            return [];
        }

        return data || [];
    }

    async updateComment(commentId: string, userId: string, content: string) {
        // Verify the comment belongs to the user
        const { data: comment, error: fetchError } = await this.supabaseService.getClient()
            .from('comments')
            .select('user_id')
            .eq('id', commentId)
            .single();

        if (fetchError || !comment) {
            return null;
        }

        if (comment.user_id !== userId) {
            return null; // User doesn't own this comment
        }

        const { data, error } = await this.supabaseService.getClient()
            .from('comments')
            .update({ content, updated_at: new Date().toISOString() })
            .eq('id', commentId)
            .select()
            .single();

        if (error) {
            console.error('Error updating comment:', error);
            return null;
        }

        return data;
    }

    async deleteComment(commentId: string, userId: string, isAdmin: boolean = false) {
        // Verify the comment belongs to the user or user is admin
        const { data: comment, error: fetchError } = await this.supabaseService.getClient()
            .from('comments')
            .select('user_id')
            .eq('id', commentId)
            .single();

        if (fetchError || !comment) {
            return 'Comment not found';
        }

        if (!isAdmin && comment.user_id !== userId) {
            return 'Unauthorized: You can only delete your own comments';
        }

        const { error } = await this.supabaseService.getClient()
            .from('comments')
            .delete()
            .eq('id', commentId);

        if (error) {
            console.error('Error deleting comment:', error);
            return 'Failed to delete comment';
        }

        return 'Comment deleted successfully';
    }

    async getCommentById(commentId: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('comments')
            .select(`
                id,
                user_id,
                post_id,
                parent_id,
                content,
                created_at,
                updated_at,
                users:user_id (
                    id,
                    username,
                    email
                )
            `)
            .eq('id', commentId)
            .single();

        if (error) {
            console.error('Error fetching comment:', error);
            return null;
        }

        return data;
    }
}

