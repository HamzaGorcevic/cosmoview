import { Test, TestingModule } from '@nestjs/testing';
import { UserPostCommentsController } from './user-post-comments.controller';

describe('UserPostCommentsController', () => {
  let controller: UserPostCommentsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserPostCommentsController],
    }).compile();

    controller = module.get<UserPostCommentsController>(UserPostCommentsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
