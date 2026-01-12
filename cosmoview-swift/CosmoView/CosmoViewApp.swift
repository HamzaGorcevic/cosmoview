import SwiftUI

@main
struct CosmoViewApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    if let user = authManager.currentUser, user.hasCompletedOnboarding != true {
                         OnboardingView()
                             .environmentObject(authManager)
                             .environmentObject(themeManager)
                    } else {
                        MainTabView()
                            .environmentObject(authManager)
                            .environmentObject(themeManager)
                    }
                } else {
                    LoginView()
                        .environmentObject(authManager)
                        .environmentObject(themeManager)
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}
