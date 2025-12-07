import Foundation
import SwiftUI
import Combine

@MainActor
class PostDetailViewModel: ObservableObject {
    let postId: String
    
    @Published var isLiked = false
    @Published var isFavorite = false
    @Published var likesCount = 0
    @Published var commentsCount = 0
    @Published var comments: [Comment] = []
    
    private var userId: String {
        AuthenticationManager.shared.userId ?? ""
    }
    
    init(postId: String) {
        self.postId = postId
    }
    
    func loadData() {
        Task {
            await loadLikeStatus()
            await loadFavoriteStatus()
            await loadComments()
            await loadLikesCount()
        }
    }
    
    // MARK: - Likes
    private func loadLikeStatus() async {
        guard !userId.isEmpty else { return }
        
        do {
            let response = try await APIService.shared.checkIfLiked(userId: userId, postId: postId)
            isLiked = response.isLiked
        } catch {
            print("Failed to load like status")
        }
    }
    
    private func loadLikesCount() async {
        do {
            let response = try await APIService.shared.getPostLikes(postId: postId)
            if let likes = response.data {
                likesCount = likes.count
            }
        } catch {
            print("Failed to load likes count")
        }
    }
    
    func toggleLike() {
        guard !userId.isEmpty else { return }
        
        Task {
            do {
                if isLiked {
                    _ = try await APIService.shared.unlikePost(userId: userId, postId: postId)
                    isLiked = false
                    likesCount = max(0, likesCount - 1)
                } else {
                    _ = try await APIService.shared.likePost(userId: userId, postId: postId)
                    isLiked = true
                    likesCount += 1
                }
            } catch {
                print("Failed to toggle like: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Favorites
    private func loadFavoriteStatus() async {
        guard !userId.isEmpty else { return }
        
        do {
            let response = try await APIService.shared.checkIfFavorite(userId: userId, postId: postId)
            isFavorite = response.isFavorite
        } catch {
            print("Failed to load favorite status: \(error.localizedDescription)")
        }
    }
    
    func toggleFavorite() {
        guard !userId.isEmpty else { return }
        
        Task {
            do {
                if isFavorite {
                    _ = try await APIService.shared.removeFromFavorites(userId: userId, postId: postId)
                    isFavorite = false
                } else {
                    _ = try await APIService.shared.addToFavorites(userId: userId, postId: postId)
                    isFavorite = true
                }
            } catch {
                print("Failed to toggle favorite: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Comments
    private func loadComments() async {
        do {
            let response = try await APIService.shared.getPostComments(postId: postId)
            if let fetchedComments = response.data {
                comments = fetchedComments
                commentsCount = fetchedComments.count
            }
        } catch {
            print("Failed to load comments: \(error.localizedDescription)")
        }
    }
    
    func addComment(content: String) {
        guard !userId.isEmpty, !content.isEmpty else { return }
        
        Task {
            do {
                let response = try await APIService.shared.createComment(
                    userId: userId,
                    postId: postId,
                    content: content
                )
                if let newComment = response.data {
                    comments.insert(newComment, at: 0)
                    commentsCount += 1
                }
            } catch {
                print("Failed to add comment: \(error.localizedDescription)")
            }
        }
    }
}
