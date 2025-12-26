import { Inject, Injectable } from '@nestjs/common';

@Injectable()
export class SupabaseService {
    constructor(@Inject('SUPABASE_CLIENT') private readonly supabaseClient: any) { }

    getClient() {
        return this.supabaseClient;
    }
}
