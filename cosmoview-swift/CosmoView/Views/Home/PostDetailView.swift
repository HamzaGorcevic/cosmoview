import SwiftUI

struct PostDetailView: View {
    let post: NASAPost
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: PostDetailViewModel
    @State private var commentText = ""
    @State private var showComments = false
    
    init(post: NASAPost) {
        self.post = post
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(postId: post.id))
    }
    
    // Use HD URL if available, otherwise standard URL
    private var imageURL: URL? {
        if let hdurl = post.hdurl, !hdurl.isEmpty, let url = URL(string: hdurl) {
            return url
        }
        return URL(string: post.url)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.0, green: 0.0, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Close Button
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                    // Image
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                        case .failure(let error):
                            VStack(spacing: 12) {
                                Color.gray.opacity(0.3)
                                    .frame(height: 300)
                                    .cornerRadius(20)
                                    .overlay(
                                        VStack(spacing: 12) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.yellow)
                                            Text("Image not available")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.7))
                                            Text(error.localizedDescription)
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.5))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                        }
                                    )
                            }
                        case .empty:
                            Color.gray.opacity(0.3)
                                .frame(height: 300)
                                .cornerRadius(20)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Title and Date
                    VStack(alignment: .leading, spacing: 12) {
                        Text(post.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                            Text(post.date)
                                .font(.system(size: 16))
                            
                            if let copyright = post.copyright {
                                Spacer()
                                Text("© \(copyright)")
                                    .font(.system(size: 14))
                                    .lineLimit(1)
                            }
                        }
                        .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 24)
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        // Like Button
                        ActionButton(
                            icon: viewModel.isLiked ? "heart.fill" : "heart",
                            count: viewModel.likesCount,
                            isActive: viewModel.isLiked,
                            color: .red
                        ) {
                            viewModel.toggleLike()
                        }
                        
                        // Favorite Button
                        ActionButton(
                            icon: viewModel.isFavorite ? "star.fill" : "star",
                            count: nil,
                            isActive: viewModel.isFavorite,
                            color: .yellow
                        ) {
                            viewModel.toggleFavorite()
                        }
                        
                        // Comment Button
                        ActionButton(
                            icon: "message",
                            count: viewModel.commentsCount,
                            isActive: showComments,
                            color: .blue
                        ) {
                            showComments.toggle()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(post.explanation)
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(6)
                    }
                    .padding(.horizontal, 24)
                    
                    // Comments Section
                    if showComments {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Comments")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            // Add Comment
                            HStack(spacing: 12) {
                                TextField("Add a comment...", text: $commentText)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.1))
                                    )
                                
                                Button(action: {
                                    viewModel.addComment(content: commentText)
                                    commentText = ""
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Circle())
                                }
                                .disabled(commentText.isEmpty)
                                .opacity(commentText.isEmpty ? 0.5 : 1.0)
                            }
                            
                            // Comments List
                            ForEach(viewModel.comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let count: Int?
    let isActive: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? color : .white.opacity(0.6))
                
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? color.opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isActive ? color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .animation(.spring(response: 0.3), value: isActive)
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("User \(comment.userId.prefix(8))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(formatDate(comment.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
            }
            
            Text(comment.content)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
                .padding(.leading, 36)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Simple date formatting
        let components = dateString.split(separator: "T")
        return String(components.first ?? "")
    }
}

#Preview {
    PostDetailView(post: NASAPost(
        id: "1",
        date: "2024-01-01",
        title: "Sample Post",
        explanation: "This is a sample explanation",
        url: "https://apod.nasa.gov/apod/image/2401/sample.jpg",
        mediaType: "image",
        hdurl: nil,
        copyright: nil
    ))
}
