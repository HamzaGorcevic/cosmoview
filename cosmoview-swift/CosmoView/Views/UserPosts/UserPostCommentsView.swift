import SwiftUI

struct UserPostCommentsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    let post: UserPost
    
    @State private var commentText = ""
    @State private var comments: [UserPostComment] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.isDarkMode ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Post Preview
                    VStack(alignment: .leading, spacing: 12) {
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
                                Text(post.users?.username ?? "Unknown")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
                                Text(post.title)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding()
                        .background(themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    }
                    
                    Divider()
                    
                    // Comments List
                    if isLoading && comments.isEmpty {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if comments.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No comments yet")
                                .font(.headline)
                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                            Text("Be the first to comment!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 16) {
                                ForEach(comments) { comment in
                                    HStack(alignment: .top, spacing: 12) {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Text(comment.users?.username.prefix(1).uppercased() ?? "?")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(comment.users?.username ?? "Unknown")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
                                                
                                                Spacer()
                                                
                                                Text(formatDate(comment.createdAt))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Text(comment.content)
                                                .font(.system(size: 14))
                                                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                                        }
                                        
                                        if comment.userId == authManager.userId {
                                            Button(action: { deleteComment(commentId: comment.id) }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                                    .font(.caption)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    
                    // Comment Input
                    HStack(spacing: 12) {
                        TextField("Add a comment...", text: $commentText)
                            .padding(12)
                            .background(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                            .cornerRadius(20)
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        
                        Button(action: postComment) {
                            if isLoading {
                                ProgressView()
                                    .frame(width: 44, height: 44)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(commentText.isEmpty ? Color.gray : Color.blue)
                                    )
                            }
                        }
                        .disabled(commentText.isEmpty || isLoading)
                    }
                    .padding()
                    .background(themeManager.isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.15) : Color.white)
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.isDarkMode ? Color.black : Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                fetchComments()
            }
        }
    }
    
    private func fetchComments() {
        isLoading = true
        Task {
            do {
                let response = try await APIService.shared.getUserPostComments(postId: post.id)
                await MainActor.run {
                    self.comments = response.data ?? []
                    self.isLoading = false
                }
            } catch {
                print("Error fetching comments: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func postComment() {
        guard !commentText.isEmpty, let userId = authManager.userId else { return }
        
        let content = commentText
        commentText = "" // Clear input immediately
        
        Task {
            do {
                let response = try await APIService.shared.createUserPostComment(userId: userId, postId: post.id, content: content)
                if let newComment = response.data {
                    await MainActor.run {
                        // Prepend the new comment directly instead of refetching
                        withAnimation {
                            self.comments.insert(newComment, at: 0)
                        }
                    }
                } else {
                    // Fallback to refetching if no data returned
                    fetchComments()
                }
            } catch {
                print("Error posting comment: \(error)")
                // Restore text on failure
                await MainActor.run {
                    self.commentText = content
                }
            }
        }
    }
    
    private func deleteComment(commentId: String) {
        guard let userId = authManager.userId else { return }
        
        // Optimistic delete
        let previousComments = comments
        withAnimation {
            comments.removeAll { $0.id == commentId }
        }
        
        Task {
            do {
                _ = try await APIService.shared.deleteUserPostComment(commentId: commentId, userId: userId)
            } catch {
                print("Error deleting comment: \(error)")
                // Restore on failure
                await MainActor.run {
                    self.comments = previousComments
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
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}
