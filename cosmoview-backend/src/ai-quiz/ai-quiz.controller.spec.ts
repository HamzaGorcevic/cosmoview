import { Test, TestingModule } from '@nestjs/testing';
import { AiQuizController } from './ai-quiz.controller';

describe('AiQuizController', () => {
  let controller: AiQuizController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AiQuizController],
    }).compile();

    controller = module.get<AiQuizController>(AiQuizController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
