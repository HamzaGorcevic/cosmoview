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
        VStack(spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(post.users?.username.prefix(1).uppercased() ?? "?")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.users?.username ?? "Unknown Explorer")
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                    
                    Text(formatDate(post.createdAt))
                        .font(.caption)
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                
                Spacer()
            }
            .padding(12)
            
            // Image
            Color.clear
                .aspectRatio(4/3, contentMode: .fit)
                .overlay(
                    AsyncImage(url: URL(string: post.imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure(_):
                            ZStack {
                                themeManager.isDarkMode ? Color(white: 0.1) : Color(white: 0.9)
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.secondary)
                                    Text("Failed to load")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        case .empty:
                            ZStack {
                                themeManager.isDarkMode ? Color(white: 0.1) : Color(white: 0.9)
                                ProgressView()
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                )
                .clipped()
                .frame(maxWidth: .infinity)
            
            // Content
            VStack(alignment: .leading, spacing: 10) {
                // Title & Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.title)
                        .font(.headline)
                        .foregroundColor(themeManager.primaryTextColor)
                        .lineLimit(1)
                    
                    Text(post.description)
                        .font(.body)
                        .foregroundColor(themeManager.primaryTextColor.opacity(0.9))
                        .lineLimit(3)
                }
                
                Divider()
                    .background(themeManager.secondaryTextColor.opacity(0.2))
                
                // Actions
                HStack(spacing: 20) {
                    Button(action: toggleLike) {
                        HStack(spacing: 6) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(isLiked ? .red : themeManager.primaryTextColor)
                                .scaleEffect(isLiked ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3), value: isLiked)
                            
                            if likeCount > 0 {
                                Text("\(likeCount)")
                                    .font(.subheadline)
                                    .foregroundColor(themeManager.primaryTextColor)
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: { showComments.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.primaryTextColor)
                            
                            if commentCount > 0 {
                                Text("\(commentCount)")
                                    .font(.subheadline)
                                    .foregroundColor(themeManager.primaryTextColor)
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
            .padding(12)
        }
        .background(themeManager.cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showComments, onDismiss: {
            // Re-sync on dismiss
            hasUserInteracted = false
            fetchLikeStatus()
            fetchCounts()
        }) {
            UserPostCommentsView(post: post)
                .environmentObject(themeManager)
                .environmentObject(authManager)
        }
        .onAppear {
            if !hasUserInteracted {
                fetchLikeStatus()
                fetchCounts()
            }
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
                    let likeCountResponse = try await APIService.shared.getUserPostLikeCount(postId: post.id)
                    let commentCountResponse = try await APIService.shared.getUserPostCommentCount(postId: post.id)
                    
                    await MainActor.run {
                        if !hasUserInteracted {
                            self.likeCount = likeCountResponse.count
                        }
                        self.commentCount = commentCountResponse.count
                    }
                } catch {
                    print("Error fetching counts: \(error)")
                }
            }
        }
        
        private func toggleLike() {
            guard let userId = authManager.userId else { return }
            
            // Flag interaction
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
                    // Slight debounce
                    try await Task.sleep(nanoseconds: 50_000_000) // 0.05s
                    
                    if wasLiked {
                        _ = try await APIService.shared.unlikeUserPost(userId: userId, postId: post.id)
                    } else {
                        _ = try await APIService.shared.likeUserPost(userId: userId, postId: post.id)
                    }
                } catch {
                    print("Error toggling like: \(error). Validating state...")
                    
                    // Instead of blind revert, we un-flag and re-fetch.
                    // This allows the server truth to correct us, 
                    // managing cases where we were out of sync or 409 duplicated.
                    await MainActor.run {
                        self.hasUserInteracted = false 
                    }
                    // Fetch real status
                    self.fetchLikeStatus()
                    self.fetchCounts()
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
