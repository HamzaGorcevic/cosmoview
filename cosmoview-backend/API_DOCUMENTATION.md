# CosmoView Backend API Documentation

## Overview
This backend API provides functionality for users to interact with NASA's Astronomy Picture of the Day (APOD) posts, including authentication, likes, favorites, and comments.

## Base URL
`http://localhost:3000` (or your configured port)

## Authentication Endpoints

### Register
- **POST** `/auth/register`
- **Body:**
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string"
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "message": "User registration initiated",
    "data": "User created successfully"
  }
  ```

### Login
- **POST** `/auth/login`
- **Body:**
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "message": "User login initiated",
    "data": "Login successful"
  }
  ```

### Change Password
- **POST** `/auth/change-password`
- **Body:**
  ```json
  {
    "userId": "uuid",
    "oldPassword": "string",
    "newPassword": "string"
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "message": "Password change initiated",
    "data": "Password changed successfully"
  }
  ```

## NASA Posts Endpoints

### Get Astronomy Picture of the Day
- **GET** `/nasa/apod?date=YYYY-MM-DD` (date is optional)
- **Response:**
  ```json
  {
    "status": true,
    "data": {
      "date": "2024-01-01",
      "title": "Title",
      "explanation": "Explanation",
      "url": "image_url",
      "hdurl": "hd_image_url",
      "media_type": "image",
      "service_version": "v1",
      "copyright": "Copyright info"
    }
  }
  ```

### Get All Posts
- **GET** `/nasa/posts?limit=10&offset=0`
- **Response:**
  ```json
  {
    "status": true,
    "data": [...],
    "count": 10
  }
  ```

### Get Post by Date
- **GET** `/nasa/posts/:date`
- **Response:**
  ```json
  {
    "status": true,
    "data": {...}
  }
  ```

## Likes Endpoints

### Like a Post
- **POST** `/likes`
- **Body:**
  ```json
  {
    "userId": "uuid",
    "postId": "uuid"
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "message": "Post liked successfully"
  }
  ```

### Unlike a Post
- **DELETE** `/likes`
- **Body:**
  ```json
  {
    "userId": "uuid",
    "postId": "uuid"
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "message": "Post unliked successfully"
  }
  ```

### Get Post Likes
- **GET** `/likes/post/:postId`
- **Response:**
  ```json
  {
    "status": true,
    "data": [...],
    "count": 5
  }
  ```

### Get User Liked Posts
- **GET** `/likes/user/:userId`
- **Response:**
  ```json
  {
    "status": true,
    "data": ["postId1", "postId2", ...]
  }
  ```

### Check if Post is Liked
- **GET** `/likes/check/:userId/:postId`
- **Response:**
  ```json
  {
    "status": true,
    "isLiked": true
  }
  ```

## Favorites Endpoints

### Add to Favorites
- **POST** `/favorites`
- **Body:**
  ```json
  {
    "userId": "uuid",
    "postId": "uuid"
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "message": "Post added to favorites successfully"
  }
  ```

### Remove from Favorites
- **DELETE** `/favorites`
- **Body:**
  ```json
  {
    "userId": "uuid",
    "postId": "uuid"
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "message": "Post removed from favorites successfully"
  }
  ```

### Get User Favorites
- **GET** `/favorites/user/:userId`
- **Response:**
  ```json
  {
    "status": true,
    "data": [...],
    "count": 3
  }
  ```

### Check if Post is Favorite
- **GET** `/favorites/check/:userId/:postId`
- **Response:**
  ```json
  {
    "status": true,
    "isFavorite": true
  }
  ```

## Comments Endpoints

### Create Comment
- **POST** `/comments`
- **Body:**
  ```json
  {
    "userId": "uuid",
    "postId": "uuid",
    "content": "string",
    "parentId": "uuid" // optional, for replies
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "data": {
      "id": "uuid",
      "user_id": "uuid",
      "post_id": "uuid",
      "parent_id": null,
      "content": "string",
      "created_at": "timestamp",
      "users": {
        "id": "uuid",
        "username": "string",
        "email": "string"
      }
    }
  }
  ```

### Get Post Comments
- **GET** `/comments/post/:postId`
- **Response:**
  ```json
  {
    "status": true,
    "data": [
      {
        "id": "uuid",
        "content": "string",
        "replies": [...]
      }
    ],
    "count": 5
  }
  ```

### Get Comment Replies
- **GET** `/comments/comment/:commentId/replies`
- **Response:**
  ```json
  {
    "status": true,
    "data": [...],
    "count": 2
  }
  ```

### Update Comment
- **PUT** `/comments/:commentId`
- **Body:**
  ```json
  {
    "userId": "uuid",
    "content": "string"
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "data": {...}
  }
  ```

### Delete Comment (User or Admin)
- **DELETE** `/comments/:commentId`
- **Body:**
  ```json
  {
    "userId": "uuid",
    "isAdmin": false // set to true for admin deletion
  }
  ```
- **Response:**
  ```json
  {
    "status": true,
    "message": "Comment deleted successfully"
  }
  ```

### Get Comment by ID
- **GET** `/comments/:commentId`
- **Response:**
  ```json
  {
    "status": true,
    "data": {...}
  }
  ```

## Database Schema

### Tables Created
1. **users** - User accounts with authentication
2. **nasa_posts** - NASA APOD posts
3. **likes** - User likes on posts
4. **favorites** - User favorite posts
5. **comments** - Comments and replies on posts

### Migrations
All migrations are located in `supabase/migrations/`:
- `20251115163237_create_users.sql`
- `20251115170000_create_nasa_posts.sql`
- `20251115170001_create_likes.sql`
- `20251115170002_create_favorites.sql`
- `20251115170003_create_comments.sql`

## Environment Variables
- `NASA_API_KEY` - Your NASA API key (get from https://api.nasa.gov/)
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_KEY` - Your Supabase anon key
- `PORT` - Server port (default: 3000)

## Notes
- All timestamps are in UTC
- User IDs and Post IDs are UUIDs
- Comments support nested replies via `parent_id`
- Admin users can delete any comment by setting `isAdmin: true`
- NASA posts are automatically stored in the database when fetched

