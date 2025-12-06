# CosmoView iOS - App Structure

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     CosmoViewApp.swift                      │
│                   (App Entry Point)                         │
│            Manages Authentication State                     │
└────────────────┬────────────────────────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
  ┌──────────┐     ┌──────────────┐
  │ LoginView│     │ MainTabView  │
  └──────────┘     └──────┬───────┘
        │                 │
        │           ┌─────┼─────┬─────────┐
        │           │     │     │         │
        ▼           ▼     ▼     ▼         ▼
  ┌──────────┐  ┌────┐ ┌───┐ ┌───────┐
  │Register  │  │Home│ │Fav│ │Profile│
  │View      │  │View│ │oritesView│
  └──────────┘  └─┬──┘ └───┘ └───┬───┘
                  │                │
                  ▼                ▼
           ┌──────────┐    ┌──────────────┐
           │PostDetail│    │ChangePassword│
           │View      │    │View          │
           └──────────┘    └──────────────┘
```

## 🗂️ File Organization

```
CosmoView/
│
├── 📱 App Entry
│   └── CosmoViewApp.swift
│
├── 📦 Models (Data Structures)
│   └── Models.swift
│       ├── User
│       ├── NASAPost
│       ├── Comment
│       ├── Like
│       ├── Favorite
│       └── API Response Types
│
├── 🔌 Services (Business Logic)
│   ├── APIService.swift
│   │   ├── Auth Endpoints
│   │   ├── NASA Endpoints
│   │   ├── Likes Endpoints
│   │   ├── Favorites Endpoints
│   │   └── Comments Endpoints
│   │
│   └── AuthenticationManager.swift
│       ├── Login/Logout
│       ├── Registration
│       ├── Session Management
│       └── Password Change
│
├── 🧠 ViewModels (UI State)
│   ├── HomeViewModel.swift
│   │   ├── Posts Loading
│   │   ├── Pagination
│   │   └── Pull-to-Refresh
│   │
│   └── PostDetailViewModel.swift
│       ├── Like Management
│       ├── Favorite Management
│       └── Comment Management
│
├── 🎨 Views (User Interface)
│   │
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   │   ├── Email/Password Fields
│   │   │   ├── Animated Background
│   │   │   └── Register Link
│   │   │
│   │   └── RegisterView.swift
│   │       ├── User Info Fields
│   │       ├── Password Validation
│   │       └── Account Creation
│   │
│   ├── Home/
│   │   ├── HomeView.swift
│   │   │   ├── Posts Feed
│   │   │   ├── APOD Button
│   │   │   └── Infinite Scroll
│   │   │
│   │   ├── PostDetailView.swift
│   │   │   ├── HD Image Display
│   │   │   ├── Like/Favorite Buttons
│   │   │   ├── Comments Section
│   │   │   └── Full Description
│   │   │
│   │   └── APODView.swift
│   │       └── Today's Picture
│   │
│   ├── Favorites/
│   │   └── FavoritesView.swift
│   │       ├── Saved Posts Grid
│   │       └── Empty State
│   │
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   │   ├── User Info
│   │   │   ├── Settings Menu
│   │   │   └── Logout Button
│   │   │
│   │   └── ChangePasswordView.swift
│   │       └── Password Update Form
│   │
│   └── MainTabView.swift
│       └── Custom Tab Bar
│
└── 🛠️ Utilities
    └── APIConfig.swift
        ├── Base URL
        └── Endpoint Definitions
```

## 🔄 Data Flow

```
┌──────────┐
│   User   │
│  Action  │
└────┬─────┘
     │
     ▼
┌──────────┐
│   View   │ ◄─── Displays UI
└────┬─────┘
     │
     ▼
┌──────────┐
│ViewModel │ ◄─── Manages State
└────┬─────┘
     │
     ▼
┌──────────┐
│ Service  │ ◄─── Business Logic
└────┬─────┘
     │
     ▼
┌──────────┐
│   API    │ ◄─── Network Calls
└────┬─────┘
     │
     ▼
┌──────────┐
│ Backend  │ ◄─── NestJS Server
└──────────┘
```

## 🎯 Feature Modules

### 🔐 Authentication Module
```
LoginView ──► AuthenticationManager ──► APIService
    │                                        │
    ▼                                        ▼
RegisterView                          Backend Auth
    │                                   Endpoints
    ▼
ChangePasswordView
```

### 🏠 Home Module
```
HomeView ──► HomeViewModel ──► APIService
    │              │               │
    ▼              ▼               ▼
PostDetailView  Posts State    NASA Posts
    │              │            Endpoints
    ▼              ▼
APODView      Pagination
```

### ⭐ Favorites Module
```
FavoritesView ──► FavoritesViewModel ──► APIService
                        │                      │
                        ▼                      ▼
                  Favorites State      Favorites
                                       Endpoints
```

### 💬 Interaction Module
```
PostDetailView ──► PostDetailViewModel ──► APIService
                          │                     │
                          ├─────────────────────┼── Likes
                          ├─────────────────────┼── Favorites
                          └─────────────────────┴── Comments
```

## 🎨 Component Hierarchy

```
LoginView
├── Background Gradient
├── Stars Animation
├── Logo & Title
├── CustomTextField (Email)
├── CustomSecureField (Password)
├── Login Button
└── Register Link

HomeView
├── Background Gradient
├── Header
│   ├── App Title
│   └── APOD Button
└── Posts List
    └── PostCard (Multiple)
        ├── Async Image
        ├── Title
        ├── Date
        └── Description Preview

PostDetailView
├── Background Gradient
├── Close Button
├── HD Image
├── Title & Info
├── Action Buttons
│   ├── Like Button
│   ├── Favorite Button
│   └── Comment Button
├── Description
└── Comments Section
    ├── Add Comment Field
    └── Comment List

MainTabView
├── Tab Content
│   ├── HomeView (Tab 0)
│   ├── FavoritesView (Tab 1)
│   └── ProfileView (Tab 2)
└── Custom Tab Bar
    ├── Home Button
    ├── Favorites Button
    └── Profile Button
```

## 🔗 API Integration Map

```
┌────────────────────────────────────────────┐
│            APIService.swift                │
├────────────────────────────────────────────┤
│                                            │
│  Authentication                            │
│  ├── /auth/register                        │
│  ├── /auth/login                           │
│  └── /auth/change-password                 │
│                                            │
│  NASA Content                              │
│  ├── /nasa/apod                            │
│  ├── /nasa/posts                           │
│  └── /nasa/posts/:date                     │
│                                            │
│  Likes                                     │
│  ├── POST /likes                           │
│  ├── DELETE /likes                         │
│  ├── GET /likes/post/:postId               │
│  └── GET /likes/check/:userId/:postId      │
│                                            │
│  Favorites                                 │
│  ├── POST /favorites                       │
│  ├── DELETE /favorites                     │
│  ├── GET /favorites/user/:userId           │
│  └── GET /favorites/check/:userId/:postId  │
│                                            │
│  Comments                                  │
│  ├── POST /comments                        │
│  ├── GET /comments/post/:postId            │
│  ├── PUT /comments/:commentId              │
│  └── DELETE /comments/:commentId           │
│                                            │
└────────────────────────────────────────────┘
```

## 📊 State Management

```
@Published Properties (Observable)
├── AuthenticationManager
│   ├── isAuthenticated: Bool
│   ├── currentUser: User?
│   └── userId: String?
│
├── HomeViewModel
│   ├── posts: [NASAPost]
│   ├── isLoading: Bool
│   ├── isLoadingMore: Bool
│   └── errorMessage: String?
│
└── PostDetailViewModel
    ├── isLiked: Bool
    ├── isFavorite: Bool
    ├── likesCount: Int
    ├── commentsCount: Int
    └── comments: [Comment]
```

---

This structure ensures:
- ✅ **Separation of Concerns**: Models, Views, ViewModels, Services
- ✅ **Reusability**: Shared components and utilities
- ✅ **Scalability**: Easy to add new features
- ✅ **Maintainability**: Clear organization and naming
- ✅ **Testability**: Isolated business logic
