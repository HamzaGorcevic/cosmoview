import { Test, TestingModule } from '@nestjs/testing';
import { UserPostCommentsService } from './user-post-comments.service';

describe('UserPostCommentsService', () => {
  let service: UserPostCommentsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UserPostCommentsService],
    }).compile();

    service = module.get<UserPostCommentsService>(UserPostCommentsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
