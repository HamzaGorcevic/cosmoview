import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { SupabaseModule } from 'src/supabase/supabase.module';
import { SupabaseService } from 'src/supabase/supabase.service';

@Module({
  imports:[SupabaseModule],
  providers: [UsersService,SupabaseService]
})
export class UsersModule {}
