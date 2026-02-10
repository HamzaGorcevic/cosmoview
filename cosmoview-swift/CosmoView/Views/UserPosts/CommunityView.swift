import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var posts: [UserPost] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                ZStack {
                    // Base gradient
                    LinearGradient(
                        colors: themeManager.isDarkMode ? [
                            Color(red: 0.05, green: 0.05, blue: 0.2),
                            Color(red: 0.0, green: 0.0, blue: 0.1)
                        ] : [
                            Color(red: 0.95, green: 0.95, blue: 1.0),
                            Color(red: 0.9, green: 0.9, blue: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    // Soft top highlight for depth
                    LinearGradient(
                        colors: [Color.white.opacity(themeManager.isDarkMode ? 0.06 : 0.15), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                    .ignoresSafeArea()

                    // Subtle vignette in dark mode
                    if themeManager.isDarkMode {
                        RadialGradient(
                            colors: [.clear, Color.black.opacity(0.4)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 900
                        )
                        .blendMode(.multiply)
                        .ignoresSafeArea()
                    }
                }
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        Text("Community")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [themeManager.primaryTextColor, themeManager.accentColor.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Spacer()
                        
                        Image(systemName: "globe.americas.fill")
                            .font(.title)
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .background(Color.clear)
                    
                    if isLoading && posts.isEmpty {
                        Spacer()
                        ProgressView("Loading community posts...")
                            .tint(themeManager.primaryTextColor)
                        Spacer()
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
                            Spacer()
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(themeManager.secondaryTextColor)
                            
                            Text("No posts yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.primaryTextColor)
                            
                            Text("Be the first to share something with the community!")
                                .foregroundColor(themeManager.secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 24) {
                                ForEach(posts) { post in
                                    UserPostCard(post: post)
                                        .padding(.horizontal, 16) // Padding applied to card container
                                }
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 100) // Extra padding for bottom tab bar
                        }
                        .refreshable {
                            fetchAllPosts()
                        }
                    }
                }
            }
            .navigationBarHidden(true) // We use custom header
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
