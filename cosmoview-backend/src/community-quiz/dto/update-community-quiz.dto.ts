import { PartialType } from '@nestjs/mapped-types';
import { CreateCommunityQuizDto } from './create-community-quiz.dto';

export class UpdateCommunityQuizDto extends PartialType(CreateCommunityQuizDto) {}
