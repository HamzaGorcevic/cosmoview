import { Module } from '@nestjs/common';
import { UserPostCommentsService } from './user-post-comments.service';
import { UserPostCommentsController } from './user-post-comments.controller';
import { SupabaseModule } from 'src/supabase/supabase.module';

@Module({
  imports: [SupabaseModule],
  providers: [UserPostCommentsService],
  controllers: [UserPostCommentsController]
})
export class UserPostCommentsModule { }
