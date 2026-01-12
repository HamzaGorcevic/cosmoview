import { HttpService } from '@nestjs/axios';
import { Injectable } from '@nestjs/common';
import { firstValueFrom } from 'rxjs';
import { SupabaseService } from 'src/supabase/supabase.service';

@Injectable()
export class NasaService {
    private readonly apiKey = process.env.NASA_API_KEY;
    private readonly baseUrl = 'https://api.nasa.gov/planetary'
    constructor(private readonly httpService: HttpService, private readonly supabaseService: SupabaseService) {
    }
    async getAstronomyPictureOfTheDay(date?: string) {
        let d = date || new Date().toISOString().split('T')[0];
        console.log(d);
        // 1. Try to get exact date from DB
        const existingPost = await this.getPostByDate(d);
        if (existingPost) return existingPost;

        // 2. If a specific date was requested (not today), we must wait for it.
        if (date) {
            return await this.fetchFromApi(d);
        }

        // 3. If "Today" (default) is requested but missing:
        // Try to get the latest available post to show immediately (Stale-while-revalidate)
        const { data: latest } = await this.supabaseService.getClient()
            .from('nasa_posts')
            .select('*')
            .order('date', { ascending: false })
            .limit(1)
            .maybeSingle();

        // Trigger background update for today's content
        // This runs without awaiting, so the user response is not blocked
        this.fetchFromApi(d).catch(err => console.warn(`Background fetch for ${d} failed: ${err.message}`));

        // Return latest if we have it, otherwise we have no choice but to wait
        if (latest) {
            return latest;
        } else {
            return await this.fetchFromApi(d);
        }
    }

    private async fetchFromApi(date: string) {
        try {
            let url = `${this.baseUrl}/apod?api_key=${this.apiKey}&thumbs=true&date=${date}`;
            // Long timeout (20s) is fine here because:
            // 1. If background, user doesn't wait.
            // 2. If foreground (first run), user NEEDS data so we wait.
            const response = await firstValueFrom(this.httpService.get(url, { timeout: 20000 }));
            const apodData = response.data;
            await this.storePost(apodData);
            return apodData;
        } catch (error) {
            console.warn(`NASA API fetch failed for ${date}: ${error.message}`);
            return null;
        }
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

        const { error } = await this.supabaseService.getClient()
            .from('nasa_posts')
            .upsert(postData, { onConflict: 'date' });

        if (error) {
            console.error('Error storing post:', error.message);
        }
    }

    async getPostByDate(date: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('nasa_posts')
            .select('*')
            .eq('date', date)
            .maybeSingle();

        if (error) {
            console.error('Error fetching post:', error.message);
            return null;
        }
        return data;
    }

    async getAllPosts(limit: number = 10, offset: number = 0) {
        const { data, error } = await this.supabaseService.getClient()
            .from('nasa_posts')
            .select('*')
            .order('date', { ascending: false })
            .range(offset, offset + limit - 1);

        if (error) {
            console.error('Error fetching posts:', error.message);
            return [];
        }

        let posts = data || [];
        const minimumPosts = 5; // Reduced requirement

        if (offset === 0 && posts.length < minimumPosts) {
            console.log(`Fetching minimal range from NASA API...`);

            const today = new Date();
            const endDate = today.toISOString().split('T')[0];
            // Fetch only last 3 days to be very fast
            const startDate = new Date(today.getTime() - 3 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

            try {
                const url = `${this.baseUrl}/apod?api_key=${this.apiKey}&start_date=${startDate}&end_date=${endDate}&thumbs=true`;

                // Short timeout to return cached data quickly if API stalls
                const response = await firstValueFrom(this.httpService.get(url, { timeout: 5000 }));
                const apodList = Array.isArray(response.data) ? response.data : [response.data];

                const upsertData = apodList.map(apodData => ({
                    date: apodData.date,
                    title: apodData.title || '',
                    explanation: apodData.explanation || null,
                    url: apodData.url || null,
                    hdurl: apodData.hdurl || null,
                    media_type: apodData.media_type || null,
                    service_version: apodData.service_version || null,
                    copyright: apodData.copyright || null,
                }));

                const { error: upsertError } = await this.supabaseService.getClient()
                    .from('nasa_posts')
                    .upsert(upsertData, { onConflict: 'date' });

                if (upsertError) {
                    console.error('Error batch storing posts:', upsertError.message);
                }
            } catch (err) {
                // Determine if it was a timeout or other error
                const isTimeout = err.code === 'ECONNABORTED';
                console.error(`Quick fetch skipped: ${isTimeout ? 'Timeout' : err.message}`);
            }

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
