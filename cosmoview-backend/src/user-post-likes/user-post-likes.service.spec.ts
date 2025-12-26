import { Test, TestingModule } from '@nestjs/testing';
import { UserPostLikesService } from './user-post-likes.service';

describe('UserPostLikesService', () => {
  let service: UserPostLikesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UserPostLikesService],
    }).compile();

    service = module.get<UserPostLikesService>(UserPostLikesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
