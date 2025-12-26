import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';
import * as fs from 'fs';
@Injectable()
export class StorageServiceService {
    private readonly bucketName = 'user_posts';
    private readonly supabaseStorageClient;
    constructor(private readonly supabaseService: SupabaseService) {
        this.supabaseStorageClient = this.supabaseService.getClient().storage.from(this.bucketName);
    }

    async uploadFile(file: Express.Multer.File) {
        const fileName = `${Date.now()}_${file.originalname}`;
        const fileBody = file.buffer || fs.readFileSync(file.path);

        const { data, error } = await this.supabaseService.getClient().storage
            .from(this.bucketName)
            .upload(fileName, fileBody, {
                contentType: file.mimetype,
                cacheControl: '3600',
                upsert: false,
            });

        if (error) {
            throw error;
        }

        return {
            ...data,
            fileName
        };
    }

    getPublicUrl(path: string) {
        const { data } = this.supabaseService.getClient().storage
            .from(this.bucketName)
            .getPublicUrl(path);
        return data.publicUrl;
    }
}
