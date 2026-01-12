import { Module } from '@nestjs/common';
import { CommunityQuizService } from './community-quiz.service';
import { CommunityQuizController } from './community-quiz.controller';

import { SupabaseModule } from 'src/supabase/supabase.module';

@Module({
  imports: [SupabaseModule],
  controllers: [CommunityQuizController],
  providers: [CommunityQuizService],
})
export class CommunityQuizModule { }
