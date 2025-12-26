import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var posts: [UserPost] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.isDarkMode ? Color.black.ignoresSafeArea() : Color.white.ignoresSafeArea()
                
                Group {
                    if isLoading {
                        ProgressView("Loading community posts...")
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                    } else if let errorMessage {
                        VStack {
                            Text(errorMessage)
                                .foregroundColor(.red)
                            Button("Retry") {
                                fetchAllPosts()
                            }
                            .padding()
                        }
                    } else if posts.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("No posts yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                            
                            Text("Be the first to share something with the community!")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 25) {
                                ForEach(posts) { post in
                                    UserPostCard(post: post)
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            fetchAllPosts()
                        }
                    }
                }
            }
            .navigationTitle("Community")
            .onAppear {
                fetchAllPosts()
            }
        }
    }
    
    private func fetchAllPosts() {
        isLoading = true
        errorMessage = nil
        
        print("🔍 Fetching all user posts...")
        
        Task {
            do {
                // Fetch all user posts from the community
                let response = try await APIService.shared.getAllUserPosts()
                print("✅ Successfully fetched \(response.count) posts")
                await MainActor.run {
                    self.posts = response
                    self.isLoading = false
                }
            } catch {
                print("❌ Error fetching posts: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = "Failed to load posts: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
            .environmentObject(ThemeManager.shared)
    }
}
