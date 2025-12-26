import { Module } from '@nestjs/common';
import { UserPostController } from './user-post.controller';
import { UserPostService } from './user-post.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { StorageModule } from '../storage-service/storage.module';

@Module({
    imports: [SupabaseModule, StorageModule],
    controllers: [UserPostController],
    providers: [UserPostService],
})
export class UserPostModule { }
