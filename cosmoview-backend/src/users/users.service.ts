import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';

@Injectable()
export class UsersService {
    constructor(private readonly supabaseService: SupabaseService) { }
    async findByUserEamil(email: string) {
        const user = await this.supabaseService.getClient().from("users").where("email", email).select("*").single();
        return user
    }

    async completeOnboarding(userId: string) {
        const { data, error } = await this.supabaseService.getClient()
            .from('users')
            .update({ has_completed_onboarding: true })
            .eq('id', userId)
            .select()
            .single();

        if (error) {
            console.error('Error completing onboarding:', error);
            return null;
        }
        return data;
    }
}
