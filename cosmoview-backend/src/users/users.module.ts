import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { SupabaseModule } from 'src/supabase/supabase.module';
import { SupabaseService } from 'src/supabase/supabase.service';

import { UsersController } from './users.controller';

@Module({
  imports: [SupabaseModule],
  controllers: [UsersController],
  providers: [UsersService, SupabaseService],
  exports: [UsersService]
})
export class UsersModule { }
