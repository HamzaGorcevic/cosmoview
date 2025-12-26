import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Favorites")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        Text("Your starred posts")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.6))
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
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.isDarkMode ? .white : .black))
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
    @EnvironmentObject var themeManager: ThemeManager
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
                .foregroundColor(themeManager.isDarkMode ? .white : .black)
            
            Text("Start exploring and save your favorite cosmic moments!")
                .font(.system(size: 16))
                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
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
                let favoritesResponse = try await APIService.shared.getUserFavorites(userId: userId)
                
                print("✅ Favorites response status: \(favoritesResponse.status)")
                print("✅ Favorites count: \(favoritesResponse.count ?? 0)")
                print("✅ Favorites data: \(String(describing: favoritesResponse.data))")
                
                if let favorites = favoritesResponse.data, !favorites.isEmpty {
                    let favoritePostIds = favorites.map { $0.postId }
                    print("✅ Post IDs: \(favoritePostIds)")
                    
                    let postsResponse = try await APIService.shared.getAllPosts(limit: 100, offset: 0)
                    
                    if let allPosts = postsResponse.data {
                        // Filter by favorites AND exclude posts with null URLs
                        favoritePosts = allPosts.filter { 
                            favoritePostIds.contains($0.id) && $0.url != nil
                        }
                        print("✅ Matched \(favoritePosts.count) posts")
                    }
                } else {
                    favoritePosts = []
                }
            } catch {
                print("❌ Favorites error: \(error)")
                if let decodingError = error as? DecodingError {
                    print("❌ Decoding error details: \(decodingError)")
                }
                favoritePosts = []
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
        .environmentObject(ThemeManager.shared)
}
