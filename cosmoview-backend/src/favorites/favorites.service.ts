import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';

@Injectable()
export class FavoritesService {
    constructor(private readonly supabaseService: SupabaseService) {}

    async addToFavorites(userId: string, postId: string) {
        // Check if favorite already exists
        const { data: existingFavorite, error: checkError } = await this.supabaseService.getClient()
            .from('favorites')
            .select('id')
            .eq('user_id', userId)
            .eq('post_id', postId)
            .single();

        if (existingFavorite) {
            return 'Post already in favorites';
        }

        const { data, error } = await this.supabaseService.getClient()
            .from('favorites')
            .insert([{ user_id: userId, post_id: postId }])
            .select()
            .single();

        if (error) {
            console.error('Error adding to favorites:', error);
            return 'Failed to add to favorites';
        }

        return 'Post added to favorites successfully';
    }

    async removeFromFavorites(userId: string, postId: string) {
        const { error } = await this.supabaseService.getClient()
            .from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);

        if (error) {
            console.error('Error removing from favorites:', error);
            return 'Failed to remove from favorites';
        }

        return 'Post removed from favorites successfully';
    }

    async getUserFavorites(userId: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('favorites')
            .select('id, user_id, post_id, created_at')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) {
            console.error('Error fetching favorites:', error);
            return [];
        }

        return data || [];
    }

    async isPostInFavorites(userId: string, postId: string): Promise<boolean> {
        const { data, error } = await this.supabaseService.getClient()
            .from('favorites')
            .select('id')
            .eq('user_id', userId)
            .eq('post_id', postId)
            .single();

        return !error && !!data;
    }
}
