import { Module } from '@nestjs/common';
import { AiQuizController } from './ai-quiz.controller';
import { AiQuizService } from './ai-quiz.service';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
    imports: [SupabaseModule],
    controllers: [AiQuizController],
    providers: [AiQuizService],
})
export class AiQuizModule { }
