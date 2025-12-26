import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';

@Injectable()
export class UserPostLikesService {
    constructor(private readonly supabaseService: SupabaseService) { }

    async likePost(userId: string, postId: string) {
        const client = this.supabaseService.getClient();

        // Check if already liked
        const { data: existing } = await client
            .from('user_post_likes')
            .select('id')
            .eq('user_id', userId)
            .eq('post_id', postId)
            .single();

        if (existing) {
            return { status: true, message: 'Already liked' };
        }

        const { data, error } = await client
            .from('user_post_likes')
            .insert([{ user_id: userId, post_id: postId }])
            .select()
            .single();

        if (error) {
            throw new Error(error.message);
        }

        return { status: true, message: 'Post liked successfully', data };
    }

    async unlikePost(userId: string, postId: string) {
        const client = this.supabaseService.getClient();

        const { error } = await client
            .from('user_post_likes')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);

        if (error) {
            throw new Error(error.message);
        }

        return { status: true, message: 'Post unliked successfully' };
    }

    async getPostLikes(postId: string) {
        const client = this.supabaseService.getClient();

        const { data, error } = await client
            .from('user_post_likes')
            .select('id, user_id, created_at, users(username)')
            .eq('post_id', postId)
            .order('created_at', { ascending: false });

        if (error) {
            throw new Error(error.message);
        }

        return { status: true, data, count: data.length };
    }

    async checkIfLiked(userId: string, postId: string) {
        const client = this.supabaseService.getClient();

        const { data, error } = await client
            .from('user_post_likes')
            .select('id')
            .eq('user_id', userId)
            .eq('post_id', postId)
            .single();

        if (error && error.code !== 'PGRST116') {
            throw new Error(error.message);
        }

        return { status: true, isLiked: !!data };
    }

    async getLikeCount(postId: string) {
        const client = this.supabaseService.getClient();

        const { count, error } = await client
            .from('user_post_likes')
            .select('*', { count: 'exact', head: true })
            .eq('post_id', postId);

        if (error) {
            throw new Error(error.message);
        }

        return { status: true, count: count || 0 };
    }
}
