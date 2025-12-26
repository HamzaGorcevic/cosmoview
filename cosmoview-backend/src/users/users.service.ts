import { Injectable } from '@nestjs/common';
import { SupabaseService } from 'src/supabase/supabase.service';

@Injectable()
export class UsersService {
    constructor(private readonly supabaseService: SupabaseService) { }
    async findByUserEamil(email: string) {
        const user = await this.supabaseService.getClient().from("users").where("email", email).select("*").single();
        return user

    }
}
