import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    private func request<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("=== RAW RESPONSE ===")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON: \(jsonString)")
        }
        print("===================")
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password
        ]
        return try await request(endpoint: APIConfig.Endpoints.register, method: "POST", body: body)
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        return try await request(endpoint: APIConfig.Endpoints.login, method: "POST", body: body)
    }
    
    func changePassword(userId: String, oldPassword: String, newPassword: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "userId": userId,
            "oldPassword": oldPassword,
            "newPassword": newPassword
        ]
        return try await request(endpoint: APIConfig.Endpoints.changePassword, method: "POST", body: body)
    }
    
    func getAPOD(date: String? = nil) async throws -> APIResponse<NASAPost> {
        let endpoint = APIConfig.Endpoints.apod
        return try await request(endpoint: endpoint)
    }
            
    func getAllPosts(limit: Int = 10, offset: Int = 0) async throws -> APIResponse<[NASAPost]> {
        let endpoint = "\(APIConfig.Endpoints.posts)?limit=\(limit)&offset=\(offset)"
        return try await request(endpoint: endpoint)
    }
    
    func getPostByDate(date: String) async throws -> APIResponse<NASAPost> {
        return try await request(endpoint: APIConfig.Endpoints.postByDate(date))
    }
    
    func likePost(userId: String, postId: String) async throws -> APIResponse<String> {
        let body: [String: Any] = ["userId": userId, "postId": postId]
        return try await request(endpoint: APIConfig.Endpoints.likes, method: "POST", body: body)
    }
    
    func unlikePost(userId: String, postId: String) async throws -> APIResponse<String> {
        let body: [String: Any] = ["userId": userId, "postId": postId]
        return try await request(endpoint: APIConfig.Endpoints.likes, method: "DELETE", body: body)
    }
    
    func getPostLikes(postId: String) async throws -> APIResponse<[Like]> {
        return try await request(endpoint: APIConfig.Endpoints.postLikes(postId))
    }
    
    func getUserLikedPosts(userId: String) async throws -> APIResponse<[String]> {
        return try await request(endpoint: APIConfig.Endpoints.userLikes(userId))
    }
    
    func checkIfLiked(userId: String, postId: String) async throws -> LikeCheckResponse {
        return try await request(endpoint: APIConfig.Endpoints.checkLike(userId: userId, postId: postId))
    }
    
    func addToFavorites(userId: String, postId: String) async throws -> APIResponse<String> {
        let body: [String: Any] = ["userId": userId, "postId": postId]
        return try await request(endpoint: APIConfig.Endpoints.favorites, method: "POST", body: body)
    }
    
    func removeFromFavorites(userId: String, postId: String) async throws -> APIResponse<String> {
        let body: [String: Any] = ["userId": userId, "postId": postId]
        return try await request(endpoint: APIConfig.Endpoints.favorites, method: "DELETE", body: body)
    }
    
    func getUserFavorites(userId: String) async throws -> APIResponse<[Favorite]> {
        return try await request(endpoint: APIConfig.Endpoints.userFavorites(userId))
    }
    
    func checkIfFavorite(userId: String, postId: String) async throws -> FavoriteCheckResponse {
        return try await request(endpoint: APIConfig.Endpoints.checkFavorite(userId: userId, postId: postId))
    }
    
    func createComment(userId: String, postId: String, content: String, parentId: String? = nil) async throws -> APIResponse<Comment> {
        var body: [String: Any] = [
            "userId": userId,
            "postId": postId,
            "content": content
        ]
        if let parentId = parentId {
            body["parentId"] = parentId
        }
        return try await request(endpoint: APIConfig.Endpoints.comments, method: "POST", body: body)
    }
    
    func getPostComments(postId: String) async throws -> APIResponse<[Comment]> {
        return try await request(endpoint: APIConfig.Endpoints.postComments(postId))
    }
    
    func getCommentReplies(commentId: String) async throws -> APIResponse<[Comment]> {
        return try await request(endpoint: APIConfig.Endpoints.commentReplies(commentId))
    }
    
    func updateComment(commentId: String, userId: String, content: String) async throws -> APIResponse<Comment> {
        let body: [String: Any] = ["userId": userId, "content": content]
        return try await request(endpoint: APIConfig.Endpoints.comment(commentId), method: "PUT", body: body)
    }
    
    func deleteComment(commentId: String, userId: String, isAdmin: Bool = false) async throws -> APIResponse<String> {
        let body: [String: Any] = ["userId": userId, "isAdmin": isAdmin]
        return try await request(endpoint: APIConfig.Endpoints.comment(commentId), method: "DELETE", body: body)
    }
    
    func getComment(commentId: String) async throws -> APIResponse<Comment> {
        return try await request(endpoint: APIConfig.Endpoints.comment(commentId))
    }
}
