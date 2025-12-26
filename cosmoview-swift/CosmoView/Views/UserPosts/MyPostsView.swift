import SwiftUI

struct MyPostsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var posts: [UserPost] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    @State private var showingCreatePost = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView("Loading your posts...")
                } else if let errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                        Button("Retry") {
                            fetchPosts()
                        }
                        .padding()
                    }
                } else if posts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No posts yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Share your space discoveries with the community!")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { showingCreatePost = true }) {
                            Text("Create First Post")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(posts) { post in
                                UserPostCard(post: post)
                                    .environmentObject(AuthenticationManager.shared)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        fetchPosts()
                    }
                }
            }
            .navigationTitle("My Posts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Close")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreatePost = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView()
                .onDisappear {
                    fetchPosts()
                }
        }
        .onAppear {
            print("MyPostsView appeared")
            fetchPosts()
        }
    }
    
    private func fetchPosts() {
        guard let userId = authManager.userId else {
            print("❌ No user ID found for fetching posts")
            errorMessage = "Please log in to view your posts"
            return
        }
        
        print("🔍 Fetching posts for user: \(userId)")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedPosts = try await APIService.shared.getUserPosts(userId: userId)
                print("✅ Fetched \(fetchedPosts.count) posts")
                await MainActor.run {
                    self.posts = fetchedPosts
                    self.isLoading = false
                }
            } catch {
                print("❌ Error fetching user posts: \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct MyPostsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPostsView()
    }
}
