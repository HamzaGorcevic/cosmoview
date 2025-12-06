import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';

@Injectable()
export class LikesService {
    constructor(private readonly supabaseService: SupabaseService) {}

    async likePost(userId: string, postId: string) {
        // Check if like already exists
        const { data: existingLike, error: checkError } = await this.supabaseService.getClient()
            .from('likes')
            .select('id')
            .eq('user_id', userId)
            .eq('post_id', postId)
            .single();

        if (existingLike) {
            return 'Post already liked';
        }

        const { data, error } = await this.supabaseService.getClient()
            .from('likes')
            .insert([{ user_id: userId, post_id: postId }])
            .select()
            .single();

        if (error) {
            console.error('Error liking post:', error);
            return 'Failed to like post';
        }

        return 'Post liked successfully';
    }

    async unlikePost(userId: string, postId: string) {
        const { error } = await this.supabaseService.getClient()
            .from('likes')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);

        if (error) {
            console.error('Error unliking post:', error);
            return 'Failed to unlike post';
        }

        return 'Post unliked successfully';
    }

    async getPostLikes(postId: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('likes')
            .select('id, user_id, created_at')
            .eq('post_id', postId);

        if (error) {
            console.error('Error fetching likes:', error);
            return [];
        }

        return data || [];
    }

    async getUserLikedPosts(userId: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('likes')
            .select('post_id')
            .eq('user_id', userId);

        if (error) {
            console.error('Error fetching user likes:', error);
            return [];
        }

        return data?.map(like => like.post_id) || [];
    }

    async isPostLikedByUser(userId: string, postId: string): Promise<boolean> {
        const { data, error } = await this.supabaseService.getClient()
            .from('likes')
            .select('id')
            .eq('user_id', userId)
            .eq('post_id', postId)
            .single();

        return !error && !!data;
    }
}
