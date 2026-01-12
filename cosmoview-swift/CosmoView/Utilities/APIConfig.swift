import Foundation

struct APIConfig {
    // Change this to your backend URL
    static let baseURL = "http://localhost:3000"
    
    struct Endpoints {
        // Auth
        static let register = "/auth/register"
        static let login = "/auth/login"
        static let changePassword = "/auth/change-password"
        
        static func completeOnboarding(_ userId: String) -> String {
            "/users/\(userId)/onboarding"
        }
        
        // NASA
        static let apod = "/nasa/apod"
        static let posts = "/nasa/posts"
        static func postByDate(_ date: String) -> String {
            "/nasa/posts/\(date)"
        }
        
        // Likes
        static let likes = "/likes"
        static func postLikes(_ postId: String) -> String {
            "/likes/post/\(postId)"
        }
        static func userLikes(_ userId: String) -> String {
            "/likes/user/\(userId)"
        }
        static func checkLike(userId: String, postId: String) -> String {
            "/likes/check/\(userId)/\(postId)"
        }
        
        // Favorites
        static let favorites = "/favorites"
        static func userFavorites(_ userId: String) -> String {
            "/favorites/user/\(userId)"
        }
        static func checkFavorite(userId: String, postId: String) -> String {
            "/favorites/check/\(userId)/\(postId)"
        }
        
        // Comments
        static let comments = "/comments"
        static func postComments(_ postId: String) -> String {
            "/comments/post/\(postId)"
        }
        static func commentReplies(_ commentId: String) -> String {
            "/comments/comment/\(commentId)/replies"
        }
        static func comment(_ commentId: String) -> String {
            "/comments/\(commentId)"
        }
        
        // User Posts
        static let userPosts = "/user-post"
        static func userPostsByUser(_ userId: String) -> String {
            "/user-post/user/\(userId)"
        }
        
        // User Post Likes
        static let userPostLikes = "/user-post-likes"
        static func userPostLikesForPost(_ postId: String) -> String {
            "/user-post-likes/post/\(postId)"
        }
        static func checkUserPostLike(userId: String, postId: String) -> String {
            "/user-post-likes/check/\(userId)/\(postId)"
        }
        static func userPostLikeCount(_ postId: String) -> String {
            "/user-post-likes/count/\(postId)"
        }
        
        // User Post Comments
        static let userPostComments = "/user-post-comments"
        static func userPostCommentsForPost(_ postId: String) -> String {
            "/user-post-comments/post/\(postId)"
        }
        static func userPostCommentCount(_ postId: String) -> String {
            "/user-post-comments/count/\(postId)"
        }
        static func userPostComment(_ commentId: String) -> String {
            "/user-post-comments/\(commentId)"
        }
        
        // AI Quiz
        static let aiQuiz = "/ai-quiz"
        static let submitQuiz = "/ai-quiz/submit"
        
        // Community Quiz
        static let communityQuiz = "/community-quiz"
        static let submitCommunityQuiz = "/community-quiz/submit"
    }
}
    		
