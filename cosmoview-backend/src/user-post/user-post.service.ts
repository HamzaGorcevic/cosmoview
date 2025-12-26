import { SupabaseService } from 'src/supabase/supabase.service';
import { CreateUserPostDto } from './dto/create-user-post.dto';
import * as fs from 'fs';
import { Injectable } from '@nestjs/common';
import { StorageServiceService } from '../storage-service/storage-service.service';

@Injectable()
export class UserPostService {
    constructor(
        private readonly supabaseService: SupabaseService,
        private readonly storageService: StorageServiceService,
    ) { }

    async create(createUserPostDto: CreateUserPostDto, file: Express.Multer.File) {
        let imageUrl = '';

        if (file) {
            try {
                const uploadData = await this.storageService.uploadFile(file);
                imageUrl = this.storageService.getPublicUrl(uploadData.path);

                // Cleanup file if it was saved to disk by multer
                if (file.path) {
                    try {
                        fs.unlinkSync(file.path);
                    } catch (err) {
                        console.error('Error deleting temp file:', err);
                    }
                }
            } catch (error) {
                throw new Error(`Upload failed: ${error.message}`);
            }
        }

        const client = this.supabaseService.getClient();
        const { data, error } = await client
            .from('user_post')
            .insert([
                {
                    title: createUserPostDto.title,
                    description: createUserPostDto.description,
                    user_id: createUserPostDto.user_id,
                    image_url: imageUrl,
                },
            ])
            .select()
            .single();

        if (error) {
            throw new Error(error.message);
        }

        return data;
    }

    async findAll() {
        const client = this.supabaseService.getClient();
        const { data, error } = await client
            .from('user_post')
            .select('*, users(username)')
            .order('created_at', { ascending: false });

        if (error) {
            throw new Error(error.message);
        }

        return data;
    }

    async findByUser(userId: string) {
        const client = this.supabaseService.getClient();
        const { data, error } = await client
            .from('user_post')
            .select('*, users(username)')
            .eq('user_id', userId)
            .order('created_at', { ascending: false });

        if (error) {
            throw new Error(error.message);
        }

        return data;
    }
}
