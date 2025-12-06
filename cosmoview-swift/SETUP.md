# CosmoView iOS - Quick Setup Guide

## 🚀 Quick Start (5 minutes)

### Step 1: Configure API Endpoint

Open `CosmoView/Utilities/APIConfig.swift` and update the backend URL:

**For iOS Simulator:**
```swift
static let baseURL = "http://localhost:3000"
```

**For Physical iPhone/iPad:**
```swift
static let baseURL = "http://YOUR_COMPUTER_IP:3000"
```

To find your computer's IP:
- **macOS**: System Preferences → Network → Your connection
- **Windows**: Run `ipconfig` in Command Prompt
- Example: `http://192.168.1.100:3000`

### Step 2: Start Backend

Ensure your backend server is running:
```bash
cd c:\Users\gorce\cosmoview-backend\cosmoview-backend
pnpm start:dev
```

Look for: `Application is running on: http://localhost:3000`

### Step 3: Open in Xcode

```bash
cd c:\Users\gorce\cosmoview-backend\cosmoview-swift
open CosmoView.xcodeproj
```

Or open Xcode → File → Open → Select `CosmoView.xcodeproj`

### Step 4: Build and Run

1. Select your target device (iPhone 15 Pro recommended for simulator)
2. Press `Cmd + R` or click the Play button
3. Wait for the build to complete
4. App should launch automatically!

## 📱 Testing the App

### Create a Test Account

1. Launch the app
2. Tap "Sign up"
3. Enter:
   - **Username**: testuser
   - **Email**: test@example.com
   - **Password**: test123456
   - **Confirm Password**: test123456
4. Tap "Create Account"
5. Go back and login!

### Explore Features

✅ **Home Screen**
- View NASA posts in beautiful cards
- Tap "Today" button for APOD (Astronomy Picture of the Day)
- Scroll down to load more posts
- Pull down to refresh

✅ **Post Details**
- Tap any post card
- View HD images
- ❤️ Like the post
- ⭐ Add to favorites
- 💬 Add comments

✅ **Favorites**
- Tap star icon in bottom tab bar
- View all your favorited posts
- Pull down to refresh

✅ **Profile**
- Tap person icon in bottom tab bar
- Change your password
- Logout

## 🎨 What You'll See

### Beautiful UI Features
- 🌌 Animated starfield background
- 🎨 Blue-purple-pink gradients
- ✨ Glassmorphism design
- 📱 Custom tab bar
- 🔄 Smooth animations
- 💫 Loading states

## ⚠️ Common Issues

### Issue: "Cannot connect to backend"
**Solution**: 
- Check if backend is running on port 3000
- Verify APIConfig.baseURL matches your setup
- For physical devices, ensure iPhone and computer are on same WiFi

### Issue: "Images not loading"
**Solution**:
- Check internet connection
- Backend needs to fetch from NASA API
- Wait a moment for NASA API response

### Issue: "Build failed in Xcode"
**Solution**:
- Ensure Xcode 15.0+
- iOS Deployment Target: 17.0
- Try: Product → Clean Build Folder (Cmd + Shift + K)

### Issue: Keyboard covers input fields
**Solution**: This is handled automatically, tap outside to dismiss keyboard

## 🔧 Development Tips

### Viewing Network Requests
Add breakpoints in `APIService.swift` to debug API calls

### Changing Colors
Edit gradient colors in view files:
```swift
LinearGradient(
    colors: [.blue, .purple],  // Change these!
    startPoint: .leading,
    endPoint: .trailing
)
```

### Testing on Physical Device
1. Connect iPhone via USB
2. Trust the computer on your iPhone
3. Select your iPhone in Xcode device menu
4. Update APIConfig.baseURL to computer's IP
5. Ensure both on same WiFi network

## 📊 Project Statistics

- **Total Files**: 17
- **Lines of Code**: ~2000+
- **Views**: 11
- **ViewModels**: 2
- **API Endpoints**: 20+
- **Features**: Login, Register, Posts, Likes, Favorites, Comments, Profile

## 🎯 Next Steps

After basic testing, try:
1. Comment on multiple posts
2. Like and favorite different posts
3. Change your password
4. Test pull-to-refresh on Home and Favorites
5. Scroll through many posts (pagination)

## 💡 Pro Tips

- **Swipe down** on any list to refresh
- **Tap outside** text fields to dismiss keyboard
- **Long press** images to see them in detail (future feature)
- **Logout and login** to test persistence

## 📞 Need Help?

Check the main README.md for:
- Full architecture documentation
- API endpoint details
- Design system specifications
- Performance optimizations

---

**Enjoy exploring the cosmos! 🌌✨**
