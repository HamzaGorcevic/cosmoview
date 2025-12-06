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
    let url: String
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

// MARK: - Favorite Model
struct Favorite: Codable, Identifiable {
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

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let status: Bool
    let data: T?
    let message: String?
    let count: Int?
}

struct AuthResponse: Codable {
    let status: Bool
    let data: String
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
