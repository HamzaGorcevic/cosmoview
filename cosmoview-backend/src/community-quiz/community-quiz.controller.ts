import { Controller, Get, Post, Body, Patch, Param, Delete, Query } from '@nestjs/common';
import { CommunityQuizService } from './community-quiz.service';
import { CreateCommunityQuizDto } from './dto/create-community-quiz.dto';
import { UpdateCommunityQuizDto } from './dto/update-community-quiz.dto';

@Controller('community-quiz')
export class CommunityQuizController {
  constructor(private readonly communityQuizService: CommunityQuizService) { }

  @Post()
  create(@Body() body: { userId: string; question: string; options: string[]; correct_answer: string }) {
    return this.communityQuizService.create(body.userId, body);
  }

  @Get()
  findAll(@Query('userId') userId?: string) {
    return this.communityQuizService.findAll(userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.communityQuizService.findOne(id);
  }

  @Post('submit')
  submit(@Body() body: { userId: string; quizId: string; answer: string }) {
    return this.communityQuizService.submitAnswer(body.userId, body.quizId, body.answer);
  }
}
