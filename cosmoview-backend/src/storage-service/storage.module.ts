import { Module } from '@nestjs/common';
import { StorageServiceService } from './storage-service.service';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
    imports: [SupabaseModule],
    providers: [StorageServiceService],
    exports: [StorageServiceService],
})
export class StorageModule { }
