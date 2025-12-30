import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { AiQuizService } from './ai-quiz.service';
import { SubmitQuizDto } from './dto/submit-quiz.dto';

@Controller('ai-quiz')
export class AiQuizController {
    constructor(private readonly aiQuizService: AiQuizService) { }

    @Get()
    async getDailyQuiz(@Query('userId') userId?: string) {
        return this.aiQuizService.getAiQuiz(userId);
    }

    @Post('submit')
    async submitQuiz(@Body() dto: SubmitQuizDto) {
        return this.aiQuizService.submitAnswer(dto.userId, dto.quizId, dto.answer);
    }
}
