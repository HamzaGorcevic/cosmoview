import { Controller, Patch, Param, Body, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Patch(':id/onboarding')
    async completeOnboarding(@Param('id') id: string) {
        const result = await this.usersService.completeOnboarding(id);
        if (!result) {
            throw new NotFoundException('User not found or update failed');
        }
        return { message: 'Onboarding completed', status: true };
    }
}
