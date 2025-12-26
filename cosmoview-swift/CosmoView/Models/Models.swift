import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - NASA Post Model
struct NASAPost: Codable, Identifiable {
    let id: String
    let date: String
    let title: String
    let explanation: String
    let url: String?  // Optional in case of null
    let mediaType: String
    let hdurl: String?
    let copyright: String?
    
    enum CodingKeys: String, CodingKey {
        case id, date, title, explanation, url, copyright
        case mediaType = "media_type"
        case hdurl
    }
}

// MARK: - Comment Model
struct Comment: Codable, Identifiable {
    let id: String
    let userId: String
    let postId: String
    let content: String
    let parentId: String?
    let createdAt: String
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, content
        case userId = "user_id"
        case postId = "post_id"
        case parentId = "parent_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Like Model
struct Like: Codable, Identifiable {
    let id: String
    let userId: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case createdAt = "created_at"
    }
}


// MARK: - Favorite Model
struct Favorite: Codable, Identifiable {
    let id: String
    let userId: String?
    let postId: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case postId = "post_id"
        case createdAt = "created_at"
    }
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let status: Bool
    let data: T?
    let message: String?
    let count: Int?
}

struct AuthResponse: Codable {
    let status: Bool
    let data: User?
    let message: String
}

struct LikeCheckResponse: Codable {
    let status: Bool
    let isLiked: Bool
}

struct FavoriteCheckResponse: Codable {
    let status: Bool
    let isFavorite: Bool
}

// MARK: - User Post Model
struct UserPost: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let imageUrl: String
    let userId: String
    let createdAt: String
    let users: UserSummary?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, users
        case imageUrl = "image_url"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct UserSummary: Codable {
    let username: String
}

// MARK: - User Post Like Model
struct UserPostLike: Codable, Identifiable {
    let id: String
    let userId: String
    let postId: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case postId = "post_id"
        case createdAt = "created_at"
    }
}

// MARK: - User Post Comment Model
struct UserPostComment: Codable, Identifiable {
    let id: String
    let userId: String
    let postId: String
    let content: String
    let createdAt: String
    let users: UserSummary?
    
    enum CodingKeys: String, CodingKey {
        case id, content, users
        case userId = "user_id"
        case postId = "post_id"
        case createdAt = "created_at"
    }
}

// MARK: - User Post Like Check Response
struct UserPostLikeCheckResponse: Codable {
    let status: Bool
    let isLiked: Bool
}

// MARK: - User Post Count Response
struct UserPostCountResponse: Codable {
    let status: Bool
    let count: Int
}
