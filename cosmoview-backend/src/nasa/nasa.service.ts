import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { firstValueFrom } from 'rxjs';
import { SupabaseService } from 'src/supabase/supabase.service';
@Injectable()
export class NasaService {
    private readonly apiKey = process.env.NASA_API_KEY;
    private readonly baseUrl = 'https://api.nasa.gov/planetary'
    constructor(private readonly httpService: HttpService,private readonly supabaseService:SupabaseService) {
    }
    async getAstronomyPictureOfTheDay(date?: string) {
        let url = `${this.baseUrl}/apod?api_key=${this.apiKey}`;
        if (date) {
            url += `&date=${date}`;
        }
        const response = await firstValueFrom(this.httpService.get(url));
        const apodData = response.data;
        
        await this.storePost(apodData);
        
        return apodData;
    }

    async storePost(apodData: any) {
        const postData = {
            date: apodData.date,
            title: apodData.title || '',
            explanation: apodData.explanation || null,
            url: apodData.url || null,
            hdurl: apodData.hdurl || null,
            media_type: apodData.media_type || null,
            service_version: apodData.service_version || null,
            copyright: apodData.copyright || null,
        };

        // Check if post already exists
        const { data: existingPost } = await this.supabaseService.getClient()
            .from('nasa_posts')
            .select('id')
            .eq('date', postData.date)
            .single();

        if (existingPost) {
            // Update existing post
            const { error } = await this.supabaseService.getClient()
                .from('nasa_posts')
                .update({ ...postData, updated_at: new Date().toISOString() })
                .eq('date', postData.date);
            
            if (error) {
                console.error('Error updating post:', error);
            }
        } else {
            // Insert new post
            const { error } = await this.supabaseService.getClient()
                .from('nasa_posts')
                .insert([postData]);
            
            if (error) {
                console.error('Error storing post:', error);
            }
        }
    }

    async getPostByDate(date: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('nasa_posts')
            .select('*')
            .eq('date', date)
            .single();

        if (error) {
            console.error('Error fetching post:', error);
            return null;
        }

        return data;
    }

    async getAllPosts(limit: number = 10, offset: number = 0) {
        // First, get posts from database
        const { data, error } = await this.supabaseService.getClient()
            .from('nasa_posts')
            .select('*')
            .order('date', { ascending: false })
            .range(offset, offset + limit - 1);

        if (error) {
            console.error('Error fetching posts:', error);
            return [];
        }

        let posts = data || [];
        
        // If we don't have enough posts, fetch more from NASA API
        const minimumPosts = 20;
        if (offset === 0 && posts.length < minimumPosts) {
            console.log(`Only ${posts.length} posts in DB, fetching more from NASA API...`);
            
            const today = new Date();
            const promises: Promise<any>[] = [];
            
            for (let i = 1; i <= 30; i++) {
                const date = new Date(today);
                date.setDate(date.getDate() - i);
                const dateString = date.toISOString().split('T')[0];
                
                const exists = posts.some(p => p.date === dateString);
                if (!exists) {
                    promises.push(
                        this.getAstronomyPictureOfTheDay(dateString).catch(err => {
                            console.error(`Failed to fetch APOD for ${dateString}:`, err.message);
                            return null;
                        })
                    );
                }
            }
            
            // Wait for all fetches
            await Promise.all(promises);
            
            // Re-fetch from database
            const { data: updatedData } = await this.supabaseService.getClient()
                .from('nasa_posts')
                .select('*')
                .order('date', { ascending: false })
                .range(offset, offset + limit - 1);
            
            posts = updatedData || posts;
        }

        return posts;
    }

}
