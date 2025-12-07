import { Body, Controller, Delete, Get, Param, Post } from '@nestjs/common';
import { FavoritesService } from './favorites.service';

@Controller('favorites')
export class FavoritesController {
    constructor(private readonly favoritesService: FavoritesService) {}

    @Post()
    async addToFavorites(@Body() body: { userId: string; postId: string }) {
        const result = await this.favoritesService.addToFavorites(body.userId, body.postId);
        return { status: true, message: result };
    }

    @Delete()
    async removeFromFavorites(@Body() body: { userId: string; postId: string }) {
        const result = await this.favoritesService.removeFromFavorites(body.userId, body.postId);
        return { status: true, message: result };
    }

    @Get('user/:userId')
    async getUserFavorites(@Param('userId') userId: string) {
        const favorites = await this.favoritesService.getUserFavorites(userId);
        // Return with snake_case field names for Swift
        const transformedFavorites = favorites.map(fav => ({
            id: fav.id,
            user_id: fav.user_id || userId,
            post_id: fav.post_id,
            created_at: fav.created_at
        }));
        return { status: true, data: transformedFavorites, count: transformedFavorites.length };
    }

    @Get('check/:userId/:postId')
    async checkIfFavorite(@Param('userId') userId: string, @Param('postId') postId: string) {
        const isFavorite = await this.favoritesService.isPostInFavorites(userId, postId);
        return { status: true, isFavorite };
    }
}
