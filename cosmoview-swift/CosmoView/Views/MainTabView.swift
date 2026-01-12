import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                CommunityView()
                    .tag(1)
                
                FavoritesView()
                    .tag(2)
                
                ProfileView()
                    .tag(3)
                
                CommunityQuizListView()
                    .tag(4)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabBarButton(
                icon: "globe",
                title: "Community",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabBarButton(
                icon: "questionmark.circle.fill",
                title: "Quizzes",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
            
            TabBarButton(
                icon: "star.fill",
                title: "Favorites",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            TabBarButton(
                icon: "person.fill",
                title: "Profile",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(themeManager.isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.2) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        )
        .padding(.horizontal, 24)
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(
                        isSelected ?
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [themeManager.isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? (themeManager.isDarkMode ? .white : .black) : (themeManager.isDarkMode ? .white.opacity(0.5) : .black.opacity(0.5)))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? (themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05)) : Color.clear)
            )
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(ThemeManager.shared)
}
