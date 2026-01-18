import SwiftUI

struct OnboardingInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var currentPage = 0
    @State private var isCompleting = false
    
    let pages: [OnboardingInfo] = [
        OnboardingInfo(
            title: "Explore the Universe",
            description: "Discover the Astronomy Picture of the Day directly from NASA.",
            imageName: "safari.fill" // Safer icon for Explore
        ),
        OnboardingInfo(
            title: "Join the Community",
            description: "Share your thoughts, create posts, and connect with fellow astronomy enthusiasts.",
            imageName: "globe.americas.fill"
        ),
        OnboardingInfo(
            title: "Test Your Knowledge",
            description: "Challenge yourself with AI-generated quizzes and community-created tests.",
            imageName: "brain.head.profile"
        ),
        OnboardingInfo(
            title: "Curate Collection",
            description: "Save your favorite cosmic views and build your personal gallery.",
            imageName: "star.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // Dynamic Background
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(info: pages[index])
                            .environmentObject(themeManager) // Explicitly pass to ensure update inside TabView
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
                .indexViewStyle(.page(backgroundDisplayMode: .always)) // Makes dots more visible
                
                // Bottom Controls
                VStack(spacing: 20) {
                    if currentPage == pages.count - 1 {
                        Button(action: {
                            Task {
                                await completeOnboarding()
                            }
                        }) {
                            HStack {
                                if isCompleting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Get Started")
                                        .fontWeight(.bold)
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white) // Ensure text is white despite theme
                            .cornerRadius(12)
                            .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isCompleting)
                        .padding(.horizontal, 30)
                        
                    } else {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.primaryTextColor)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    func completeOnboarding() async {
        guard let user = authManager.currentUser else { return }
        isCompleting = true
        do {
            try await authManager.completeOnboarding(userId: user.id)
        } catch {
            print("Failed to complete onboarding: \(error)")
            isCompleting = false
        }
    }
}

struct OnboardingPageView: View {
    let info: OnboardingInfo
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: info.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundStyle(
                    LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .padding(.bottom, 30)
            
            Text(info.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.primaryTextColor)
                .multilineTextAlignment(.center)
            
            Text(info.description)
                .font(.body)
                .foregroundColor(themeManager.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}
