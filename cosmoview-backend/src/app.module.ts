import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { LikesModule } from './likes/likes.module';
import { AuthModule } from './auth/auth.module';
import { NasaModule } from './nasa/nasa.module';
import { FavoritesModule } from './favorites/favorites.module';
import { SupabaseModule } from './supabase/supabase.module';
import { ConfigModule } from '@nestjs/config';
import { UsersModule } from './users/users.module';
import { CommentsModule } from './comments/comments.module';
import { UserPostModule } from './user-post/user-post.module';
import { MulterModule } from '@nestjs/platform-express/multer';
import { StorageModule } from './storage-service/storage.module';
import { UserPostLikesModule } from './user-post-likes/user-post-likes.module';
import { UserPostCommentsModule } from './user-post-comments/user-post-comments.module';
import { AiQuizModule } from './ai-quiz/ai-quiz.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ScheduleModule.forRoot(),
    LikesModule,
    AuthModule,
    NasaModule,
    FavoritesModule,
    SupabaseModule,
    UsersModule,
    CommentsModule,
    UserPostModule,
    StorageModule,
    MulterModule.register({
      dest: './uploads',
    }),
    UserPostLikesModule,
    UserPostCommentsModule,
    AiQuizModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    AppService,
  ],
})
export class AppModule { }
