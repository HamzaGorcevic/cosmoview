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
    
    // MARK: - User Posts Endpoints
    func createUserPost(userId: String, title: String, description: String, imageData: Data) async throws -> UserPost {
        guard let url = URL(string: APIConfig.baseURL + APIConfig.Endpoints.userPosts) else {
            throw URLError(.badURL)
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add title
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(title)\r\n".data(using: .utf8)!)
        
        // Add description
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(description)\r\n".data(using: .utf8)!)
        
        // Add user_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)
        
        // Add file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"post.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(UserPost.self, from: data)
    }
    
    func getUserPosts(userId: String) async throws -> [UserPost] {
        let response: [UserPost] = try await request(endpoint: APIConfig.Endpoints.userPostsByUser(userId))
        return response
    }
    
    func getAllUserPosts() async throws -> [UserPost] {
        let response: [UserPost] = try await request(endpoint: APIConfig.Endpoints.userPosts)
        return response
    }
    
    // MARK: - User Post Likes
    func likeUserPost(userId: String, postId: String) async throws -> APIResponse<String> {
        let body: [String: Any] = ["userId": userId, "postId": postId]
        return try await request(endpoint: APIConfig.Endpoints.userPostLikes, method: "POST", body: body)
    }
    
    func unlikeUserPost(userId: String, postId: String) async throws -> APIResponse<String> {
        let body: [String: Any] = ["userId": userId, "postId": postId]
        return try await request(endpoint: APIConfig.Endpoints.userPostLikes, method: "DELETE", body: body)
    }
    
    func checkIfUserPostLiked(userId: String, postId: String) async throws -> UserPostLikeCheckResponse {
        return try await request(endpoint: APIConfig.Endpoints.checkUserPostLike(userId: userId, postId: postId))
    }
    
    func getUserPostLikeCount(postId: String) async throws -> UserPostCountResponse {
        return try await request(endpoint: APIConfig.Endpoints.userPostLikeCount(postId))
    }
    
    // MARK: - User Post Comments
    func createUserPostComment(userId: String, postId: String, content: String) async throws -> APIResponse<UserPostComment> {
        let body: [String: Any] = ["userId": userId, "postId": postId, "content": content]
        return try await request(endpoint: APIConfig.Endpoints.userPostComments, method: "POST", body: body)
    }
    
    func getUserPostComments(postId: String) async throws -> APIResponse<[UserPostComment]> {
        return try await request(endpoint: APIConfig.Endpoints.userPostCommentsForPost(postId))
    }
    
    func deleteUserPostComment(commentId: String, userId: String) async throws -> APIResponse<String> {
        let body: [String: Any] = ["userId": userId]
        return try await request(endpoint: APIConfig.Endpoints.userPostComment(commentId), method: "DELETE", body: body)
    }
    
    func getUserPostCommentCount(postId: String) async throws -> UserPostCountResponse {
        return try await request(endpoint: APIConfig.Endpoints.userPostCommentCount(postId))
    }
    
    // MARK: - AI Quiz
    func getDailyQuiz(userId: String? = nil) async throws -> Quiz {
        var endpoint = APIConfig.Endpoints.aiQuiz
        if let userId = userId {
            endpoint += "?userId=\(userId)"
        }
        return try await request(endpoint: endpoint)
    }
    
    func submitQuiz(userId: String, quizId: String, answer: String) async throws -> QuizSubmissionResponse {
        let body: [String: Any] = [
            "userId": userId,
            "quizId": quizId,
            "answer": answer
        ]
        return try await request(endpoint: APIConfig.Endpoints.submitQuiz, method: "POST", body: body)
    }
}
