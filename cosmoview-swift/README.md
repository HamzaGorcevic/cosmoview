# CosmoView iOS App 🌌

A beautiful iOS mobile application for exploring NASA's Astronomy Picture of the Day and cosmic content, built with SwiftUI and integrated with the CosmoView backend.

## Features ✨

### Authentication
- **Login**: Secure user authentication
- **Register**: Create new account with validation
- **Change Password**: Update password securely
- **Auto-login**: Persistent authentication state

### NASA Content
- **Home Feed**: Browse astronomy posts with infinite scroll
- **APOD**: View today's Astronomy Picture of the Day
- **Post Details**: Full-screen image viewing with descriptions
- **HD Images**: Automatic high-definition image loading

### Social Features
- **Likes**: Like/unlike posts with real-time counter
- **Favorites**: Save favorite posts for later viewing
- **Comments**: Add and view comments on posts
- **User Profile**: Manage your account

## Architecture 🏗️

### Project Structure
```
CosmoView/
├── CosmoViewApp.swift          # Main app entry point
├── Models/
│   └── Models.swift            # Data models (User, Post, Comment, etc.)
├── Services/
│   ├── APIService.swift        # API networking layer
│   └── AuthenticationManager.swift  # Auth state management
├── ViewModels/
│   ├── HomeViewModel.swift     # Home feed logic
│   └── PostDetailViewModel.swift   # Post detail logic
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift     # Login screen
│   │   └── RegisterView.swift  # Registration screen
│   ├── Home/
│   │   ├── HomeView.swift      # Main feed
│   │   ├── PostDetailView.swift    # Post details
│   │   └── APODView.swift      # Daily APOD
│   ├── Favorites/
│   │   └── FavoritesView.swift # Saved favorites
│   ├── Profile/
│   │   ├── ProfileView.swift   # User profile
│   │   └── ChangePasswordView.swift  # Password change
│   └── MainTabView.swift       # Tab navigation
└── Utilities/
    └── APIConfig.swift         # API configuration

```

## Design System 🎨

### Color Palette
- **Primary**: Blue-Purple gradient (`#0052D4` → `#6D28D9`)
- **Secondary**: Purple-Pink gradient (`#6D28D9` → `#EC4899`)
- **Accent**: Yellow-Orange gradient (`#F59E0B` → `#F97316`)
- **Background**: Dark cosmic gradient
  - Top: `rgb(13, 13, 51)` 
  - Bottom: `rgb(0, 0, 26)`

### Components
- **Custom Text Fields**: Glassmorphism design with icons
- **Custom Buttons**: Gradient backgrounds with shadows
- **Post Cards**: Elevated cards with rounded corners
- **Tab Bar**: Custom bottom navigation with smooth animations
- **Stars Background**: Animated particle effects

### Typography
- **Headers**: SF Rounded Bold (32-42pt)
- **Body**: SF Pro Regular (14-16pt)
- **Buttons**: SF Pro Semibold (16-18pt)

## API Integration 🔌

The app connects to your NestJS backend with the following endpoints:

### Authentication
- `POST /auth/register` - Create new user
- `POST /auth/login` - User login
- `POST /auth/change-password` - Update password

### NASA Content
- `GET /nasa/apod` - Get today's APOD
- `GET /nasa/posts?limit=10&offset=0` - Get posts with pagination
- `GET /nasa/posts/:date` - Get post by specific date

### Likes
- `POST /likes` - Like a post
- `DELETE /likes` - Unlike a post
- `GET /likes/post/:postId` - Get post likes
- `GET /likes/user/:userId` - Get user's liked posts
- `GET /likes/check/:userId/:postId` - Check if user liked post

### Favorites
- `POST /favorites` - Add to favorites
- `DELETE /favorites` - Remove from favorites
- `GET /favorites/user/:userId` - Get user favorites
- `GET /favorites/check/:userId/:postId` - Check if favorited

### Comments
- `POST /comments` - Create comment
- `GET /comments/post/:postId` - Get post comments
- `GET /comments/comment/:commentId/replies` - Get comment replies
- `PUT /comments/:commentId` - Update comment
- `DELETE /comments/:commentId` - Delete comment

## Setup Instructions 📱

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later
- Running CosmoView backend server

### Configuration

1. **Update API URL**
   
   Open `CosmoView/Utilities/APIConfig.swift` and update the base URL:
   ```swift
   static let baseURL = "http://YOUR_IP:3000"
   ```
   
   For iOS Simulator: Use `http://localhost:3000`
   For Physical Device: Use your computer's IP address, e.g., `http://192.168.1.100:3000`

2. **Backend Setup**
   
   Ensure your backend is running:
   ```bash
   cd cosmoview-backend
   pnpm start:dev
   ```

3. **Build and Run**
   
   - Open `CosmoView.xcodeproj` in Xcode
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

## Features by Screen 📱

### Login Screen
- Email & password authentication
- Animated star background
- Gradient design
- Form validation
- Error handling
- Link to registration

### Register Screen
- Username, email, password fields
- Password confirmation
- Real-time password matching
- Email validation
- Success/error alerts

### Home Feed
- Infinite scroll posts
- Pull-to-refresh
- Loading states
- Error handling with retry
- Beautiful post cards
- APOD quick access

### Post Detail
- Full HD image viewing
- Like/unlike functionality
- Add to favorites
- Comment system
- Like counter
- Date and copyright info
- Full description

### Favorites
- View saved posts
- Empty state design
- Pull-to-refresh
- Post removal

### Profile
- User information
- Change password
- Logout functionality
- App version info

## Key Technologies 💻

- **SwiftUI**: Modern declarative UI framework
- **Async/Await**: Modern concurrency for API calls
- **Combine**: Reactive programming with @Published properties
- **URLSession**: Native networking
- **Codable**: JSON encoding/decoding
- **UserDefaults**: Persistent authentication state

## Design Highlights 🎨

1. **Glassmorphism**: Semi-transparent backgrounds with blur
2. **Gradient Overlays**: Vibrant blue-purple-pink gradients
3. **Smooth Animations**: Spring animations for interactions
4. **Custom Tab Bar**: Unique bottom navigation design
5. **Dynamic States**: Loading, error, and empty states
6. **Dark Theme**: Cosmic-inspired dark color scheme
7. **Micro-interactions**: Button scales, icon animations

## Performance Optimizations ⚡

- **Lazy Loading**: LazyVStack for efficient scrolling
- **Image Caching**: AsyncImage with automatic caching
- **Pagination**: Load posts in batches of 10
- **Background Tasks**: API calls on background threads
- **Memory Management**: Proper cleanup and deallocation

## Testing Credentials 🔑

For testing, you can create a new account or use:
```
Email: test@example.com
Password: test123
```
(If already created in your database)

## Future Enhancements 🚀

- [ ] Search functionality
- [ ] User profiles with avatars
- [ ] Push notifications
- [ ] Share posts to social media
- [ ] Dark/Light mode toggle
- [ ] Post filtering by date
- [ ] Offline mode support
- [ ] Image download feature
- [ ] Comment replies
- [ ] User mentions

## Troubleshooting 🔧

### Can't connect to backend
- Ensure backend is running on port 3000
- Check firewall settings
- Update APIConfig.baseURL with correct IP
- For physical devices, iOS and backend must be on same network

### Images not loading
- Check internet connection
- Verify NASA API is accessible
- Check backend logs for errors

### Login fails
- Verify user exists in database
- Check backend console for errors
- Ensure correct email/password format

## License 📄

This project is part of the CosmoView application suite.

## Credits 🙏

- NASA APOD API for amazing space imagery
- SF Symbols for beautiful icons
- SwiftUI for modern UI framework

---

**Built with ❤️ for space enthusiasts**
