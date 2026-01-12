import SwiftUI

struct OnboardingInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var currentPage = 0
    @State private var isCompleting = false
    
    let pages: [OnboardingInfo] = [
        OnboardingInfo(
            title: "Join the Cosmos",
            description: "View the Astronomy Picture of the Day directly from NASA.",
            imageName: "star.fill"
        ),
        OnboardingInfo(
            title: "Test Knowledge",
            description: "Take daily AI-generated quizzes and climb the leaderboard.",
            imageName: "lightbulb.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.0, blue: 0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(info: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
                
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
                                .foregroundColor(.white)
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
            // No need to set isCompleting = false because view will dismiss
        } catch {
            print("Failed to complete onboarding: \(error)")
            isCompleting = false
        }
    }
}

struct OnboardingPageView: View {
    let info: OnboardingInfo
    
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
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(info.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}
