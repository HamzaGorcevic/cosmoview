import { Module } from '@nestjs/common';
import { FavoritesService } from './favorites.service';
import { FavoritesController } from './favorites.controller';
import { SupabaseModule } from 'src/supabase/supabase.module';
import { SupabaseService } from 'src/supabase/supabase.service';

@Module({
  imports: [SupabaseModule],
  providers: [FavoritesService, SupabaseService],
  controllers: [FavoritesController]
})
export class FavoritesModule {}
