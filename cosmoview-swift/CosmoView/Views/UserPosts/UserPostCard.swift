import SwiftUI

struct UserPostCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager
    let post: UserPost
    
    @State private var isLiked = false
    @State private var likeCount = 0
    @State private var commentCount = 0
    @State private var showComments = false
    @State private var hasUserInteracted = false
    
    var body: some View {
            ZStack {
                // Background & Shadow
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(themeManager.isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color.white)
                    .shadow(color: Color.black.opacity(themeManager.isDarkMode ? 0.3 : 0.1), radius: 10, x: 0, y: 5)
                
                // Content
                VStack(alignment: .leading, spacing: 0) {
                    // Image Section
                    AsyncImage(url: URL(string: post.imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 280)
                                .clipped()
                        case .failure(_):
                            Rectangle()
                                .fill(themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                .frame(height: 280)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.largeTitle)
                                            .foregroundColor(.secondary)
                                        Text("Failed to load image")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        case .empty:
                            Rectangle()
                                .fill(themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                .frame(height: 280)
                                .overlay(ProgressView())
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(post.title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                            
                            Spacer()
                            
                            Text(formatDate(post.createdAt))
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(post.description)
                            .font(.system(size: 15))
                            .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text(post.users?.username.prefix(1).uppercased() ?? "?")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                Text(post.users?.username ?? "Unknown Explorer")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            // Like Button
                        Button(action: toggleLike) {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(isLiked ? .red : .secondary)
                                if likeCount > 0 {
                                    Text("\(likeCount)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                            
                            // Comment Button
                            Button(action: { showComments.toggle() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "bubble.right")
                                        .foregroundColor(.secondary)
                                    if commentCount > 0 {
                                        Text("\(commentCount)")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                    // Removed .background(...) here, relying on ZStack background
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 1)
            )
            .sheet(isPresented: $showComments, onDismiss: {
                fetchCounts()
                fetchLikeStatus()
            }) {
                UserPostCommentsView(post: post)
                    .environmentObject(themeManager)
                    .environmentObject(authManager)
            }
            .onAppear {
                fetchLikeStatus()
                fetchCounts()
            }
        }
        
        private func fetchLikeStatus() {
            guard let userId = authManager.userId else { return }
            
            Task {
                do {
                    let response = try await APIService.shared.checkIfUserPostLiked(userId: userId, postId: post.id)
                    await MainActor.run {
                        if !hasUserInteracted {
                            self.isLiked = response.isLiked
                        }
                    }
                } catch {
                    print("Error checking like status: \(error)")
                }
            }
        }
        
        private func fetchCounts() {
            Task {
                do {
                    async let likeCountResponse = APIService.shared.getUserPostLikeCount(postId: post.id)
                    async let commentCountResponse = APIService.shared.getUserPostCommentCount(postId: post.id)
                    
                    let (likes, comments) = try await (likeCountResponse, commentCountResponse)
                    
                    await MainActor.run {
                        // Only update like count if user hasn't interacted, to avoid jumps
                        // Or trust server count but adjust for local toggle?
                        // Simpler: Just update counts, but respect isLiked state
                        if !hasUserInteracted {
                            self.likeCount = likes.count
                        } else {
                            // If user interacted, our local count is more 'current' roughly speaking
                            // But server count might include OTHER users.
                            // Ideally we merge them. For now, let's just stick to local cached count if interacted
                        }
                        self.commentCount = comments.count
                    }
                } catch {
                    print("Error fetching counts: \(error)")
                }
            }
        }
        
        private func toggleLike() {
            guard let userId = authManager.userId else { return }
            print("❤️ Toggling like. Current state: \(isLiked)")
            
            hasUserInteracted = true
            let wasLiked = isLiked
            let previousCount = likeCount
            
            // Optimistic update
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isLiked.toggle()
                likeCount += isLiked ? 1 : -1
            }
            
            Task {
                do {
                    if wasLiked {
                        _ = try await APIService.shared.unlikeUserPost(userId: userId, postId: post.id)
                    } else {
                        _ = try await APIService.shared.likeUserPost(userId: userId, postId: post.id)
                    }
                } catch {
                    print("Error toggling like: \(error)")
                    // Revert on error
                    await MainActor.run {
                        self.isLiked = wasLiked
                        self.likeCount = previousCount
                        self.hasUserInteracted = false // Reset interaction flag on revert
                    }
                }
            }
        }
        
        private func formatDate(_ dateString: String) -> String {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateStyle = .medium
                displayFormatter.timeStyle = .none
                return displayFormatter.string(from: date)
            }
            return dateString
        }
}
