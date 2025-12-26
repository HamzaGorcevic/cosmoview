import { Module } from '@nestjs/common';
import { NasaController } from './nasa.controller';
import { NasaService } from './nasa.service';
import { HttpModule } from '@nestjs/axios';
import { SupabaseModule } from 'src/supabase/supabase.module';
import { SupabaseService } from 'src/supabase/supabase.service';
@Module({
  imports: [HttpModule, SupabaseModule],
  controllers: [NasaController],
  providers: [NasaService]
})
export class NasaModule { }
