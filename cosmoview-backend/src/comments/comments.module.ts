import { Module } from '@nestjs/common';
import { CommentsController } from './comments.controller';
import { CommentsService } from './comments.service';
import { SupabaseModule } from 'src/supabase/supabase.module';
import { SupabaseService } from 'src/supabase/supabase.service';

@Module({
  imports: [SupabaseModule],
  controllers: [CommentsController],
  providers: [CommentsService, SupabaseService]
})
export class CommentsModule {}

