import SwiftUI

struct HomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAPOD = false
    @State private var showQuiz = false
    
    var body: some View {
        ZStack {
            // Background
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
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CosmoView")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        Text("Explore the cosmos")
                            .font(.system(size: 14))
                            .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // APOD Button
                    Button(action: { showAPOD = true }) {
                        VStack(spacing: 2) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20))
                            Text("Today")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Daily Quiz Banner
                Button(action: { showQuiz = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Cosmos Quiz")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Test your knowledge & earn points!")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        Spacer()
                        Image(systemName: "brain.head.profile")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: .indigo.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                // Posts List
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.isDarkMode ? .white : .black))
                        .scaleEffect(1.5)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    ErrorView(message: error) {
                        viewModel.loadPosts()
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                PostCard(post: post)
                                    .onAppear {
                                        if post.id == viewModel.posts.last?.id {
                                            viewModel.loadMorePosts()
                                        }
                                    }
                            }
                            
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: themeManager.isDarkMode ? .white : .black))
                                    .padding()
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
        .sheet(isPresented: $showAPOD) {
            APODView()
        }
        .sheet(isPresented: $showQuiz) {
            QuizView()
        }
        .onAppear {
            if viewModel.posts.isEmpty {
                viewModel.loadPosts()
            }
        }
    }
}

// MARK: - Post Card
struct PostCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let post: NASAPost
    @State private var showDetail = false
    
    var body: some View {
        Button(action: { showDetail = true }) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                if let urlString = post.url, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 240)
                                .frame(maxWidth: .infinity)
                                .clipped()
                        case .failure(_):
                            Color.gray.opacity(0.3)
                                .frame(height: 240)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.3))
                                )
                        case .empty:
                            Color.gray.opacity(0.3)
                                .frame(height: 240)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: themeManager.isDarkMode ? .white : .black))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    // No URL available
                    Color.gray.opacity(0.3)
                        .frame(height: 240)
                        .overlay(
                            Image(systemName: "photo.slash")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
                
                // Content
                VStack(alignment: .leading, spacing: 10) {
                    Text(post.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(themeManager.isDarkMode ? .white : .black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(post.date)
                            .font(.system(size: 14))
                        
                        if let copyright = post.copyright {
                            Spacer()
                            Text("© \(copyright)")
                                .font(.system(size: 12))
                                .lineLimit(1)
                        }
                    }
                    .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.6))
                    
                    Text(post.explanation)
                        .font(.system(size: 15))
                        .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.8) : .black.opacity(0.8))
                        .lineLimit(3)
                        .lineSpacing(4)
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: themeManager.isDarkMode ? [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.03)
                            ] : [
                                Color.white,
                                Color.white.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            PostDetailView(post: post)
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Oops!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.isDarkMode ? .white : .black)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.7) : .black.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: retry) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 150, height: 45)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ThemeManager.shared)
}
