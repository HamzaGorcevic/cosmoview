import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CreateUserPostDto {
    @IsString()
    @IsNotEmpty()
    title: string;

    @IsString()
    @IsNotEmpty()
    description: string;

    @IsUUID()
    @IsNotEmpty()
    user_id: string;
}