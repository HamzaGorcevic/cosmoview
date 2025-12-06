import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { LikesModule } from './likes/likes.module';
import { AuthService } from './auth/auth.service';
import { AuthController } from './auth/auth.controller';
import { AuthModule } from './auth/auth.module';
import { NasaModule } from './nasa/nasa.module';
import { FavoritesModule } from './favorites/favorites.module';
import { SupabaseModule } from './supabase/supabase.module';
import { ConfigModule } from '@nestjs/config';
import { UsersModule } from './users/users.module';
import { SupabaseService } from './supabase/supabase.service';
import { CommentsModule } from './comments/comments.module';
@Module({
  imports: [ConfigModule.forRoot({isGlobal:true}),LikesModule, AuthModule, NasaModule, FavoritesModule, SupabaseModule, UsersModule, CommentsModule],
  controllers: [AppController, AuthController],
  providers: [AppService, AuthService,SupabaseService],
})
export class AppModule {}
