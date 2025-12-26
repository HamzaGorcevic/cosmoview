import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var themeManager: ThemeManager
    enum ProfileSheet: Identifiable {
        case changePassword
        case myPosts
        case accountDetails
        
        var id: Int {
            switch self {
            case .changePassword: return 1
            case .myPosts: return 2
            case .accountDetails: return 3
            }
        }
    }
    
    @State private var activeSheet: ProfileSheet?
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 4) {
                            Text("Profile")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(themeManager.isDarkMode ? .white : .black)
                            Text("Manage your account")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // Profile Avatar
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: .blue.opacity(0.3), radius: 20)
                            
                            VStack(spacing: 4) {
                                Text(authManager.currentUser?.username ?? "Explorer")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
                                
                                Text(authManager.currentUser?.email ?? "No email")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.6))
                            }
                        }
                        .padding(.vertical, 20)
                        
                        // Menu Items
                        VStack(spacing: 12) {
                            // Appearance Toggle
                            HStack(spacing: 16) {
                                Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.yellow)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.yellow.opacity(0.2))
                                    )
                                
                                Text("Dark Mode")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
                                
                                Spacer()
                                
                                Toggle("", isOn: $themeManager.isDarkMode)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            
                            ProfileMenuItem(
                                icon: "person.text.rectangle.fill",
                                title: "Account Details",
                                color: .orange
                            ) {
                                activeSheet = .accountDetails
                            }
                            
                            ProfileMenuItem(
                                icon: "photo.on.rectangle.angled",
                                title: "My Posts",
                                color: .green
                            ) {
                                activeSheet = .myPosts
                            }
                            
                            ProfileMenuItem(
                                icon: "key.fill",
                                title: "Change Password",
                                color: .blue
                            ) {
                                activeSheet = .changePassword
                            }
                            
                            ProfileMenuItem(
                                icon: "arrow.right.square.fill",
                                title: "Logout",
                                color: .red
                            ) {
                                showLogoutAlert = true
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // App Info
                        VStack(spacing: 8) {
                            Text("CosmoView")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.6) : .black.opacity(0.6))
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.4) : .black.opacity(0.4))
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .changePassword:
                ChangePasswordView()
                    .environmentObject(authManager)
                    .environmentObject(themeManager)
            case .myPosts:
                MyPostsView()
                    .environmentObject(authManager)
                    .environmentObject(themeManager)
            case .accountDetails:
                AccountDetailsView()
                    .environmentObject(authManager)
                    .environmentObject(themeManager)
            }
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authManager.logout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.isDarkMode ? .white.opacity(0.3) : .black.opacity(0.3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(ThemeManager.shared)
}
