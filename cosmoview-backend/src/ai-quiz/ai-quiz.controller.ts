import { Body, Controller, Get, Post } from '@nestjs/common';
import { AiQuizService } from './ai-quiz.service';
import { SubmitQuizDto } from './dto/submit-quiz.dto';

@Controller('ai-quiz')
export class AiQuizController {
    constructor(private readonly aiQuizService: AiQuizService) { }

    @Get()
    async getDailyQuiz() {
        return this.aiQuizService.getAiQuiz();
    }

    @Post('submit')
    async submitQuiz(@Body() dto: SubmitQuizDto) {
        return this.aiQuizService.submitAnswer(dto.userId, dto.quizId, dto.answer);
    }
}
