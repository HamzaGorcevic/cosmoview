import { Test, TestingModule } from '@nestjs/testing';
import { UserPostLikesController } from './user-post-likes.controller';

describe('UserPostLikesController', () => {
  let controller: UserPostLikesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UserPostLikesController],
    }).compile();

    controller = module.get<UserPostLikesController>(UserPostLikesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
