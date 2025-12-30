import { Module } from '@nestjs/common';
import { AiQuizController } from './ai-quiz.controller';
import { AiQuizService } from './ai-quiz.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { ConfigModule } from '@nestjs/config';

@Module({
    imports: [SupabaseModule, ConfigModule],
    controllers: [AiQuizController],
    providers: [AiQuizService],
})
export class AiQuizModule { }
