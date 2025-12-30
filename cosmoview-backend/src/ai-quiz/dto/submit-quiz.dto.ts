import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class SubmitQuizDto {
    @IsUUID()
    @IsNotEmpty()
    userId: string;

    @IsUUID()
    @IsNotEmpty()
    quizId: string;

    @IsString()
    @IsNotEmpty()
    answer: string;
}
