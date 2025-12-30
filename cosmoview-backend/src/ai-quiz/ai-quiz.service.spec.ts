import { Test, TestingModule } from '@nestjs/testing';
import { AiQuizService } from './ai-quiz.service';

describe('AiQuizService', () => {
  let service: AiQuizService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AiQuizService],
    }).compile();

    service = module.get<AiQuizService>(AiQuizService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
