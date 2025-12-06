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
        return { status: true, data: favorites, count: favorites.length };
    }

    @Get('check/:userId/:postId')
    async checkIfFavorite(@Param('userId') userId: string, @Param('postId') postId: string) {
        const isFavorite = await this.favoritesService.isPostInFavorites(userId, postId);
        return { status: true, isFavorite };
    }
}
