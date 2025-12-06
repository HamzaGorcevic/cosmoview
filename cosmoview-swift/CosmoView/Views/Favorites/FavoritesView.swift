import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.0, green: 0.0, blue: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Favorites")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Your starred posts")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Spacer()
                } else if viewModel.favoritePosts.isEmpty {
                    Spacer()
                    EmptyFavoritesView()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.favoritePosts) { post in
                                PostCard(post: post)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadFavorites()
        }
    }
}

// MARK: - Empty Favorites View
struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow.opacity(0.5), .orange.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("No Favorites Yet")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Start exploring and save your favorite cosmic moments!")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoritePosts: [NASAPost] = []
    @Published var isLoading = false
    
    private var userId: String {
        AuthenticationManager.shared.userId ?? ""
    }
    
    func loadFavorites() {
        guard !userId.isEmpty else { return }
        guard !isLoading else { return }
        
        isLoading = true
        
        Task {
            do {
                // First get favorite IDs
                let favoritesResponse = try await APIService.shared.getUserFavorites(userId: userId)
                
                if let favorites = favoritesResponse.data {
                    var posts: [NASAPost] = []
                    
                    for favorite in favorites {
                        let postsResponse = try await APIService.shared.getAllPosts(limit: 100, offset: 0)
                        if let allPosts = postsResponse.data {
                            if let post = allPosts.first(where: { $0.id == favorite.postId }) {
                                posts.append(post)
                            }
                        }
                    }
                    
                    favoritePosts = posts
                }
            } catch {
                print("Failed to load favorites: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    func refresh() async {
        await MainActor.run {
            loadFavorites()
        }
    }
}

#Preview {
    FavoritesView()
}
