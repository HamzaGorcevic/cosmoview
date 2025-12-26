import { Module } from '@nestjs/common';
import { UserPostLikesService } from './user-post-likes.service';
import { UserPostLikesController } from './user-post-likes.controller';
import { SupabaseModule } from 'src/supabase/supabase.module';

@Module({
  imports: [SupabaseModule],
  providers: [UserPostLikesService],
  controllers: [UserPostLikesController]
})
export class UserPostLikesModule { }
